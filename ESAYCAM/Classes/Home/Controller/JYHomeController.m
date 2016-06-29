//
//  JYHomeController.m
//  ESAYCAM
//
//  Created by Sept on 16/4/22.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYHomeController.h"
//#import "JYCameraManager.h"
#import "JYPhotosCamera.h"
#import "JYVideoView.h"
#import "JYVideoTimeView.h"
#import "JYShowInfoView.h"
#import "JYLeftTopView.h"
#import "DWBubbleMenuButton.h"
#import "JYSliderImageView.h"
#import "JYContenView.h"
#import "JYBlueManager.h"
#import "JYCoreBlueView.h"
#import "JYWebViewController.h"
#import "JYInfoLogView.h"
#import "JYCollectionView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JYVideosCamera.h"
#import "JYFormats.h"
#import "MBProgressHUD+JYExtension.h"

//static const float kExposureMinimumDuration = 1.0/1000;
//static const float kExposureDurationPower = 5;
CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;}

@interface JYHomeController () <JYVideoCameraDelegate, JYVideoViewDelegate, JYLeftTopViewDelegate, MWPhotoBrowserDelegate, DWBubbleMenuViewDelegate, JYSliderImageViewDelegate, JYContentViewDelegate, JYBlueManagerDelegate, JYCoreBlueViewDelegate, UIGestureRecognizerDelegate, JYCollectionViewDelegate, JYCaptureManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSTimer *_timer;
}

@property (strong, nonatomic) UIView *subView;
@property (strong, nonatomic) JYVideosCamera *videoCamera;
@property (strong, nonatomic) JYPhotosCamera *photoCamera;
@property (strong, nonatomic) UIView *bottomPreview;

@property (strong, nonatomic) JYVideoView *videoView;
@property (strong, nonatomic) JYVideoTimeView *videoTimeView;

@property (strong, nonatomic) UIView *ruleBottomView;
@property (strong, nonatomic) CALayer *layer;
@property (strong, nonatomic) CALayer *focusView;
@property (strong, nonatomic) CALayer *zoomView;

@property (strong, nonatomic) JYShowInfoView *infoView;
@property (strong, nonatomic) JYLeftTopView *leftTopView;

@property (strong, nonatomic) DWBubbleMenuButton *menuBtn;

//@property (strong, nonatomic) JYSliderImageView *sliderImageView;

@property (strong, nonatomic) JYContenView *myContentView;

@property (strong, nonatomic) JYCoreBlueView *coreBlueView;
@property (strong, nonatomic) JYBlueManager *blueManager;

@property (assign, nonatomic) CGFloat focusNum;
@property (assign, nonatomic) CGFloat zoomNum;

/** 拍照状态 */
@property (assign, nonatomic) BOOL photoSuccess;

@property (assign, nonatomic) CGFloat saveNum;

@property (assign, nonatomic) NSInteger timeNum;

@property (assign, nonatomic) CGFloat saveFocusNum;
@property (assign, nonatomic) CGFloat saveVideoZoom;

@property (strong, nonatomic) UIImageView *grladView;

@property (strong, nonatomic) UIButton *mainBtn;
@property (strong, nonatomic) UIButton *videoBtn;
@property (strong, nonatomic) UIButton *phtotBtn;
@property (strong, nonatomic) UIButton *enlargeBtn;
//@property (strong, nonatomic) UIButton *timesBtn;

@property (assign, nonatomic) BOOL tempAuto;
@property (assign, nonatomic) BOOL tintAuto;
@property (assign, nonatomic) BOOL isoAuto;
@property (assign, nonatomic) BOOL timeAuto;

@property (assign, nonatomic) CGFloat temp;
@property (assign, nonatomic) CGFloat tint;

@property (assign, nonatomic) BOOL isHidden;

@property (strong, nonatomic) JYInfoLogView *logView;

@property (nonatomic) dispatch_queue_t sessionQueue;

@property (copy, nonatomic) NSString *perName;

@property (strong, nonatomic) NSMutableArray *fpsArray;

@property (strong, nonatomic) UITableView *fpsView;

@property (assign, nonatomic) BOOL isCan;

@property (strong, nonatomic) JYCollectionView *collectionView;
@property (strong, nonatomic) UISlider *soundSlider;

@property (copy, nonatomic) NSString *preSession;

@property (strong, nonatomic) UIImageView *exposureView;

@property (strong, nonatomic) NSMutableArray *imgsArray;

@property (strong, nonatomic) CALayer *faceLayer;

@property (assign, nonatomic) CGPoint foucuPoint;

@end

@implementation JYHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL);
    self.navigationController.navigationBarHidden = YES;
    
    self.connectSucces = [NSString titleChinese:@"连接成功" english:@"Successful Connection"];
    self.disConnect = [NSString titleChinese:@"连接中断" english:@"Bluetooth connection interrupt"];
    self.nowSace = [NSString titleChinese:@"保存成功" english:@"Save success"];
    
    self.altTitle = [NSString titleChinese:@"参数重置" english:@"Parameter Reset"];
    self.altMesage = [NSString titleChinese:@"所有设置将全部恢复为默认设置" english:@"All settings will be restored to default settings"];
    self.altSure = [NSString titleChinese:@"是" english:@"Yes"];
    self.altCancel = [NSString titleChinese:@"否" english:@"No"];
    
    self.sizeTitle = [NSString titleChinese:@"温馨提示" english:@"Reminder"];
    self.sizeMesage = [NSString titleChinese:@"您好，当前设备不支持3840x2160" english:@"Hello, the current device does not support 3840x2160"];
    self.sizeOk = [NSString titleChinese:@"好的" english:@"OK"];
    
    self.lensMesage = [NSString titleChinese:@"是否变更了镜头" english:@"Whether to change the lens"];
    
    self.direction = [NSString titleChinese:@"蓝牙设备未连接" english:@"Bluetooth device not connected"];
    
    self.changeName = [NSString titleChinese:@"修改名称" english:@"Modify name"];
    self.nameMsg = [NSString titleChinese:@"请输入你要修改的名字, 不支持中文名字" english:@"Please enter the name you want to modify, do not support the Chinese name"];
    self.nameplace = [NSString titleChinese:@"长度小于12的英文或数字" english:@"Length less than 12 of the English or number"];
    
    self.noperName = [NSString titleChinese:@"未连接" english:@"Not connected"];

    
    [self homeOfFirstConnectPeripheral];
    [self.blueManager findBLKAppPeripherals:0];
    
    [NSTimer scheduledTimerWithTimeInterval:20.0/1000 target:self selector:@selector(ruleImgViewTimer) userInfo:nil repeats:YES];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.28 target:self selector:@selector(longExposure) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    
//    [self addObservers];
    
//    [self getFpsAtNowResolution];
    
    self.soundSlider = [self createSlider];
    
    self.preSession = [[JYResolutionData sharedManager] resolutionBackSessionPresionWith:[[NSUserDefaults standardUserDefaults] integerForKey:@"imageViewSeleted"]];
    
    self.imgsArray = [NSMutableArray array];
    
    self.cameraType = [[NSUserDefaults standardUserDefaults] boolForKey:@"video"];
}

- (void)longExposure
{
//    [self.videoCamera takePhotoWithArray];
}

- (UISlider *)createSlider
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    volumeView.hidden = NO;
    volumeView.frame = CGRectMake(-1000, -1000, 100, 100);
    
    [self.subView addSubview:volumeView];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    return volumeViewSlider;
}

- (void)videoCameraWillCompera
{
    [self.soundSlider setValue:0.8f animated:NO];
    [self.soundSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)videoCameraCompera
{
//    [_timer setFireDate:[NSDate distantFuture]];
//    
//    UIImageWriteToSavedPhotosAlbum([self createLongExposure:self.videoCamera.imgsArray], nil, nil, nil);
//    self.videoView.image = [self createLongExposure:self.videoCamera.imgsArray];
//    [self.videoCamera.imgsArray removeAllObjects];
}

- (NSMutableArray *)fpsArray
{
    if (!_fpsArray) {
        _fpsArray = [NSMutableArray array];
        _fpsArray = [self getFpsAtNowResolution];
    }
    return _fpsArray;
}

- (UITableView *)fpsView
{
    if (!_fpsView) {
        
        _fpsView = [[UITableView alloc] init];
        
        _fpsView.backgroundColor = [UIColor clearColor];
        _fpsView.delegate = self;
        _fpsView.dataSource = self;
        _fpsView.hidden = YES;
        _fpsView.separatorColor = [UIColor yellowColor];
//        _fpsView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _fpsView.rowHeight = 50;
        
        [self.subView addSubview:_fpsView];
    }
    return _fpsView;
}

- (void)restoreDefaults
{
    self.ruleBottomView.layer.opacity = 1;
    self.videoTimeView.layer.opacity = 1;
    self.leftTopView.layer.opacity = 1;
    self.infoView.layer.opacity = 1;
    self.videoView.layer.opacity = 1;
    
    // 分辨率恢复1920x1080
//    [self.videoCamera cameraManagerEffectqualityWithTag:62 withBlock:nil];
//    
//    // 编码质量恢复到标准
//    self.videoCamera.quality = 5.0f;
//    [[NSUserDefaults standardUserDefaults] setFloat:self.videoCamera.quality forKey:@"CodingQuality"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 手轮方向
    self.blueManager.derection = CoreBlueDerectionClockwise;
    [[NSUserDefaults standardUserDefaults] setFloat:self.blueManager.derection forKey:BlueDerection];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 自动重复
    self.blueManager.videoType = JYResetVideoTypeTwo;
    [[NSUserDefaults standardUserDefaults] setFloat:self.blueManager.videoType forKey:@"ResetVideo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 闪关灯
//    [self.videoCamera flashModel:AVCaptureFlashModeAuto];
    
    // 前置录像灯
    self.blueManager.isFalsh = NO;
}

- (void)changeLanguage
{
    self.connectSucces = [[JYLanguageTool bundle] localizedStringForKey:@"连接成功" value:nil table:@"Localizable"];
    self.disConnect = [[JYLanguageTool bundle] localizedStringForKey:@"连接中断" value:nil table:@"Localizable"];
    self.nowSace = [[JYLanguageTool bundle] localizedStringForKey:@"保存成功" value:nil table:@"Localizable"];
    
    self.altTitle = [[JYLanguageTool bundle] localizedStringForKey:@"参数重置" value:nil table:@"Localizable"];
    self.altMesage = [[JYLanguageTool bundle] localizedStringForKey:@"所有设置将全部恢复为默认设置" value:nil table:@"Localizable"];
    self.altSure = [[JYLanguageTool bundle] localizedStringForKey:@"是" value:nil table:@"Localizable"];
    self.altCancel = [[JYLanguageTool bundle] localizedStringForKey:@"否" value:nil table:@"Localizable"];
    
    self.sizeTitle = [[JYLanguageTool bundle] localizedStringForKey:@"温馨提示" value:nil table:@"Localizable"];
    self.sizeMesage = [[JYLanguageTool bundle] localizedStringForKey:@"您好，当前设备不支持3840x2160" value:nil table:@"Localizable"];
    self.sizeOk = [[JYLanguageTool bundle] localizedStringForKey:@"好的" value:nil table:@"Localizable"];
    
    self.lensMesage = [[JYLanguageTool bundle] localizedStringForKey:@"是否变更了镜头" value:nil table:@"Localizable"];
    
    self.direction = [[JYLanguageTool bundle] localizedStringForKey:@"蓝牙设备未连接" value:nil table:@"Localizable"];
    
    self.noperName = [[JYLanguageTool bundle] localizedStringForKey:@"未连接" value:nil table:@"Localizable"];
}

#pragma mark -------------------------> 相机操作
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addObservers];
    switch (self.cameraType) {
        case JYCameraTypePhoto:
            [self.photoCamera startCamera];
            break;
        case JYCameraTypeVideo:
            [self.videoCamera startSession];
            break;
    }
    [self.subView addSubview:self.menuBtn];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
    switch (self.cameraType) {
        case JYCameraTypePhoto:
            [self.photoCamera stopCamera];
            break;
        case JYCameraTypeVideo:
            [self.videoCamera stopSession];
            break;
    }
}

#pragma mark ---> 视频管理
- (JYVideosCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[JYVideosCamera alloc] initWithPreviewView:self.view withSub:self.bottomPreview];
//        [_videoCamera flashModel:AVCaptureFlashModeAuto];
        _videoCamera.delegate = self;
    }
    return _videoCamera;
}

#pragma mark ---> JYVideosCameraDelegate
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error
{
    if (!error) {   // 保存成功
        self.videoView.imgUrl = outputFileURL;
        [SVProgressHUD showSuccessWithStatus:self.nowSace duration:2.0f style:SVProgressHUDMaskTypeNone];
    } else {
        [SVProgressHUD showErrorWithStatus:@"保存失败" duration:2.0f style:SVProgressHUDMaskTypeNone];
    }
}

// 设置分辨率失败
- (void)videoCameraSetQuatilyError
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertController];
    });
}

- (void)videoCameraSaveImageAtData:(NSData *)data error:(NSError *)error
{
    if (!error) {
        self.videoView.imageData = data;
    } else {
        [SVProgressHUD showErrorWithStatus:@"拍照失败" duration:1.0f style:SVProgressHUDMaskTypeBlack];
    }
}

- (void)videoCameraChangePrivacySettings
{
    NSString *message = NSLocalizedString( @"AVCam doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    // Provide quick access to Settings.
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:settingsAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ---> 拍照管理
- (JYPhotosCamera *)photoCamera {
    if (!_photoCamera) {
        _photoCamera = [[JYPhotosCamera alloc] initWithSuperView:self.view];
        _photoCamera.delegate = self;
        [self.bottomPreview addSubview:_photoCamera.scaleView];
    }
    return _photoCamera;
}

- (void)cameraManageTakingPhotoSucuess:(UIImage *)image
{
    
//    self.videoView.image = image;
//    [_timer setFireDate:[NSDate distantFuture]];
    
    
    switch (self.takeType) {
        case JYTakePhotosTypeResetExposure:
            [self.imgsArray addObject:image];
            if (self.imgsArray.count == 1) {
                [SVProgressHUD showInfoWithStatus:@"再拍一张" duration:2.0f style:SVProgressHUDMaskTypeNone];
                self.exposureView.hidden = NO;
                self.exposureView.image = image;
            } else if (self.imgsArray.count == 2) {
                self.exposureView.hidden = YES;
                self.videoView.image = [self createLongExposure:self.imgsArray];
                UIImageWriteToSavedPhotosAlbum([self createLongExposure:self.imgsArray], nil, nil, nil);
                [self.imgsArray removeAllObjects];
            }
            break;
        default:
            self.videoView.image = image;
            break;
    }
}

//- (void)didOutputMetadataObjects:(NSArray *)metadataObjects previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
//{
//    if (metadataObjects.count != 0)
//    {
//        //在这里执行检测到人脸后要执行的代码
//        /*人脸数据存在metadataObjects这个数组里，数组中每一个元素对应一个metadataObject对象，该对象的各种属性对应人脸各种信息，具体可以查看API*/
//        //        NSLog(@"%@", metadataObjects);
//        AVMetadataFaceObject *faceObject = metadataObjects.firstObject;
//        
//        [CATransaction begin];
//        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//        
//        if (self.faceLayer == nil) {
//            self.faceLayer = [CALayer layer];
//            self.faceLayer.borderColor = [UIColor redColor].CGColor;
//            self.faceLayer.borderWidth = 1;
//            [self.subView.layer addSublayer:self.faceLayer];
//        }
//        
//        
//        AVMetadataFaceObject * adjusted = (AVMetadataFaceObject*)[previewLayer transformedMetadataObjectForMetadataObject:faceObject];
//        
//        self.foucuPoint = adjusted.bounds.origin;
////        NSLog(@"%@", NSStringFromCGRect(adjusted.bounds));
////        [self.videoCamera videoCameraFoucusPoint:self.foucuPoint];
//        
//        CATransform3D transform = CATransform3DIdentity;
//        [self.faceLayer setTransform:transform]; // reset identity before setting frame
//        [self.faceLayer setFrame:adjusted.bounds];
//        transform = CATransform3DRotate(transform, DegreesToRadians(adjusted.rollAngle), 0, 0, 1);
//        [self.faceLayer setTransform:transform];
//        
//        [CATransaction commit];
//    } else {
//        self.faceLayer = nil;
//    }
//}

#pragma mark ------------------------->JYBlueManagerDelegate 蓝牙管理者和蓝牙界面显示
- (void)blueManagerToTableViewReloadData
{
    // 1.判断当前连接蓝牙是否为空 --- 为空的话就去解挡
    if (self.blueManager.connectPeripheral == nil) {
        
        // 2.解挡遍历保存的蓝牙数据
        [[NSKeyedUnarchiver unarchiveObjectWithFile:path_encode] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
//                        NSLog(@"解挡数组  %@", [NSKeyedUnarchiver unarchiveObjectWithFile:path_encode]);
            
            JYPeripheral *codePer = obj;
//            NSLog(@"%@", self.blueManager.peripherals);
            // 3.遍历蓝牙数据中的数据
            for (CBPeripheral *isPer in self.blueManager.peripherals) {
                JYPeripheral *mPer = [[JYPeripheral alloc] initWithPeripheral:isPer];
                // 3.1判断是否相同
                if ([codePer.identifier isEqualToString:mPer.identifier]) {
                    // 3.2相同的话说明之前连接过此蓝牙  直接连接
                    if (self.blueManager.connectPeripheral == nil) {
                        [self.blueManager connect:isPer];
                        self.blueManager.connectPeripheral = isPer;
                    }
                    // 3.3保存当前连接的蓝牙名称
                    [JYSeptManager sharedManager].perName = codePer.name;
                }
            }
        }];
    }
    
    [self.coreBlueView.tableView reloadData];
}

- (void)takeVideoing
{
    [self.menuBtn menuButtonSeleted:NO andTag:101];
    self.videoView.isVideo = NO;
    [self.videoCamera startRecoding];
    [self.videoTimeView startTimer];
}

- (void)stopVideoing
{
    [self.videoTimeView stopTimer];
    [self.videoCamera stopRecodeing];
//    [SVProgressHUD showWithStatus:self.nowSace];
//    [SVProgressHUD showSuccessWithStatus:self.connectSucces duration:2.0f style:SVProgressHUDMaskTypeBlack];
}

/** 蓝牙发送的指令和查询指令 */
- (void)blueManagerOthersCommandWith:(NSInteger)num
{
    switch (num) {
        case 201:   // 拍照
            [self startPhoto];
//            [self.videoCamera takePhotoWithArray];
            break;
        case 301:   // 录像开始
            if (self.cameraType == JYCameraTypeVideo) {
                [self takeVideoing];
                if (self.useModel == CoreBlueUseModelRepeatRecording) {
                    [self.videoView startResetVideoing];
                }
                self.videoView.btnSeleted = YES;
            }
            break;
        case 302:   // 录像停止
            
            if (self.cameraType == JYCameraTypeVideo) {
                [self stopVideoing];
                if (self.useModel == CoreBlueUseModelRepeatRecording) {
                    [self.videoView stopResetVideoing];
                }
                self.videoView.btnSeleted = NO;
            }
            break;
        case 501:   // 查询当前对焦值
            [self.blueManager blueToolWriteValue:[NSString stringWithFormat:@"a050%db", (int)(10000 + ((1- (-self.focusNum + SHOW_Y) / (screenH - 30)) - 0.5) * 1000)]];
//            NSLog(@"%@", [NSString stringWithFormat:@"a050%db", (int)(10000 + ((1- (-self.focusNum + SHOW_Y) / (screenH - 30)) - 0.5) * 1000)]);
            break;
        case 502:   // 查询当前相机状态
            // 返回拍照成功状态
            if (self.photoSuccess == 1) {
                [self.blueManager blueToolWriteValue:@"a05020001b"];  // 拍照完成
                self.photoSuccess = 0;
            }
            
            if (self.videoTimeView.hidden == 0) {
                [self.blueManager blueToolWriteValue:@"a05020002b"];  // 录像中
            } else if (self.videoTimeView.hidden == 1)
            {
                [self.blueManager blueToolWriteValue:@"a05020000b"];  // 空闲中
            }
            break;
        case 506:   // 查询当前手机系统当前界面
            switch (self.useModel) {
                case CoreBlueUseModelFocus:
                    [self.blueManager blueToolWriteValue:@"a05110002b"];  // 调焦
                    break;
                case CoreBlueUseModelZOOM:
                    [self.blueManager blueToolWriteValue:@"a05110003b"];  // ZOOM
                    break;
                    //                case CoreBlueUseModel1Duration:
                    //                    [self.blueManager blueToolWriteValue:@"a05110000b"];  // 对焦
                    break;
                case CoreBlueUseModelDurationAndZoom:
                    [self.blueManager blueToolWriteValue:@"a05110001b"];  // 快+ZOOM
                    break;
                case CoreBlueUseModelDurationAndFucus:
                    [self.blueManager blueToolWriteValue:@"a05110000b"];  // 快+Focus
                    break;
                    
                default:
                    [self.blueManager blueToolWriteValue:@"a99010506b"];  // 错误
                    break;
            }
            break;
        case 507:   // 查询当前ZOOM
            [self.blueManager blueToolWriteValue:[NSString stringWithFormat:@"a051%db", (int)(20000 + self.zoomNum / (screenH - 30) * 1000)]];
            break;
        case 601:   // 重复录制开始
            self.useModel = CoreBlueUseModelRepeatRecording;
            break;
        case 602:   // 重复录制结束
            if (self.focusView.hidden == NO) {
                self.useModel = CoreBlueUseModelFocus;
            } else{
                self.useModel = CoreBlueUseModelZOOM;
            }
            break;
        case 511:   // 查询手轮方向
            switch (self.blueManager.derection) {
                case CoreBlueDerectionClockwise:
                    [self.blueManager blueToolWriteValue:@"a05160000b"];
                    break;
                case CoreBlueDerectionAntiClockwise:
                    [self.blueManager blueToolWriteValue:@"a05160001b"];
                    break;
                    
                default:
                    break;
            }
            break;
        case 1001:   // 蓝牙手轮速率（显示）
            self.infoView.raNum = self.blueManager.speed;
            
            break;
        default:
            break;
    }
}

- (void)blueManagerPeripheralConnectSuccess
{
    self.infoView.image = @"home_core_blue_normal";
    
    [SVProgressHUD showSuccessWithStatus:self.connectSucces duration:2.0f style:SVProgressHUDMaskTypeBlack];
}

- (void)coreBlueAddOrMinus:(CoreBlueType)type
{
    switch (type) {
        case CoreBlueTypeAdd:
            // 当前在调焦模式和ZOOM模式时 界面 +1的话 就是处于调焦模式
            if (self.useModel == CoreBlueUseModelFocus || self.useModel == CoreBlueUseModelZOOM)
            {
                self.useModel = CoreBlueUseModelZOOM;
                self.zoomView.hidden = NO;
                self.focusView.hidden = YES;
//                self.sliderImageView.hidden = YES;
                
                [self.menuBtn menuButtonSeleted:NO andTag:100];
//                [self.menuBtn menuButtonsetImg:@"home_photo_icon" andTag:102];
//                [self.menuBtn menuButtonSeleted:YES andTag:101];
            }
//            else if (self.useModel == CoreBlueUseModelDurationAndFucus)  // 当前在快门时间模式时 界面 -1的话  就是处于ZOOM模式
//            {
//                if (self.videoTimeView.hidden == YES) {
//                    self.useModel = CoreBlueUseModelDurationAndZoom;
//                    self.zoomView.hidden = NO;
//                    self.focusView.hidden = YES;
////                    self.sliderImageView.hidden = NO;
//                    self.videoView.isVideo = YES;
////                    [self.menuBtn menuButtonsetImg:@"home_photo_tv_click_icon" andTag:102];
////                    self.imgModel = JYPhotoImgTVPhtoto;
////                    [self.menuBtn menuButtonSeleted:NO andTag:101];
////                    
//                    [self.menuBtn menuButtonSeleted:NO andTag:100];
//                }
//            } else if (self.useModel == CoreBlueUseModelDurationAndZoom)  // 当前在快门时间模式时 界面 -1的话  就是处于ZOOM模式
//            {
//                if (self.videoTimeView.hidden == YES) {
//                    self.useModel = CoreBlueUseModelFocus;
//                    self.focusView.hidden = NO;
//                    self.zoomView.hidden = YES;
////                    self.sliderImageView.hidden = YES;
//                    self.videoView.isVideo = NO;
//                    
//                    [self.menuBtn menuButtonSeleted:YES andTag:100];
////                    [self.menuBtn menuButtonsetImg:@"home_photo_icon" andTag:102];
////                    [self.menuBtn menuButtonSeleted:YES andTag:101];
//                }
//            }
            break;
        case CoreBlueTypeMinus:
            //             当前在调焦模式和ZOOM模式时 界面 -1的话 就是处于调焦模式
//            if (self.useModel == CoreBlueUseModelDurationAndZoom || self.useModel == CoreBlueUseModelDurationAndFucus)
//            {
//                if (self.videoTimeView.hidden == YES) {
//                    self.useModel = CoreBlueUseModelDurationAndFucus;
//                    self.zoomView.hidden = YES;
//                    self.focusView.hidden = NO;
////                    self.sliderImageView.hidden = NO;
//                    self.videoView.isVideo = YES;
////                    [self.menuBtn menuButtonsetImg:@"home_photo_tv_click_icon" andTag:102];
////                    self.imgModel = JYPhotoImgTVPhtoto;
////                    [self.menuBtn menuButtonSeleted:NO andTag:101];
////                    
//                    [self.menuBtn menuButtonSeleted:YES andTag:100];
//                }
//            } else if (self.useModel == CoreBlueUseModelFocus)  // 当前在快门时间模式和ZOOM时 界面 -1的话  就是处于快门时间模式
//            {
//                if (self.videoTimeView.hidden == YES) {
//                    self.useModel = CoreBlueUseModelDurationAndZoom;
//                    self.zoomView.hidden = NO;
//                    self.focusView.hidden = YES;
////                    self.sliderImageView.hidden = NO;
//                    self.videoView.isVideo = YES;
////                    [self.menuBtn menuButtonsetImg:@"home_photo_tv_click_icon" andTag:102];
////                    self.imgModel = JYPhotoImgTVPhtoto;
////                    [self.menuBtn menuButtonSeleted:NO andTag:101];
////                    
//                    [self.menuBtn menuButtonSeleted:NO andTag:100];
//                }
//            } else
            if (self.useModel == CoreBlueUseModelZOOM)  // 当前在快门时间模式和ZOOM时 界面 -1的话  就是处于快门时间模式
            {
                self.useModel = CoreBlueUseModelFocus;
                self.zoomView.hidden = YES;
                self.focusView.hidden = NO;
//                self.sliderImageView.hidden = YES;
                
                [self.menuBtn menuButtonSeleted:YES andTag:100];
//                [self.menuBtn menuButtonsetImg:@"home_photo_icon" andTag:102];
//                [self.menuBtn menuButtonSeleted:YES andTag:101];
            }
            break;
            
        default:
            break;
    }
}

/** 提示用户设备断开 */
- (void)blueManagerPeripheralDidConnect
{
    [SVProgressHUD showErrorWithStatus:self.disConnect duration:2.0f style:SVProgressHUDMaskTypeBlack];
    self.infoView.image = @"home_core_blue_error";
    self.infoView.raNum = 10.0;
    [JYSeptManager sharedManager].perName = self.noperName ;
    
    // 移除短线后的蓝牙
    
//    for (CBPeripheral *pre in self.blueManager.peripherals) {
//        if ([[pre.identifier UUIDString] isEqualToString:self.blueManager.removePer]) {
//            [self.blueManager.peripherals removeObject:pre];
//        }
//    }
//    [self.blueManager.peripherals removeAllObjects];
//    [self.coreBlueView.peripherals removeAllObjects];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.blueManager.connectPeripheral == nil)
        {
            self.infoView.image = @"home_core_blue_disconnect";
        }
    });
}
- (JYBlueManager *)blueManager
{
    if (!_blueManager) {
        
        _blueManager = [[JYBlueManager alloc] init];
        
        _blueManager.delegate = self;
    }
    return _blueManager;
}

/** 程序已启动自动去数据库中查找蓝牙 */
- (void)homeOfFirstConnectPeripheral
{
    if ([self.blueManager connectPeripheral]) {
        if (self.blueManager.connectPeripheral.state == CBPeripheralStateConnected) {
            [self.blueManager.centralManager cancelPeripheralConnection:self.blueManager.connectPeripheral];
            self.blueManager.connectPeripheral = nil;
        }
    }
    
    if ([self.blueManager peripherals]) {
        self.blueManager.peripherals = nil;
    }
}

#pragma mark ---> 获取当前分辨率下所支持的fps 
- (NSMutableArray *)getFpsAtNowResolution
{
    NSMutableArray *fpsArr = [NSMutableArray array];
    // 创建一个临时变量，防止数据重复添加到数组中
    Float64 maxWidth = 0.0;
    
    for (AVCaptureDeviceFormat *format in [self.videoCamera.videoDevice formats]) {
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
        
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
//            NSLog(@"width = %d", dimensions.width);
            if (width == self.videoCamera.videoWidth && range.maxFrameRate > maxWidth) {
//                NSLog(@"%f", range.maxFrameRate);
                
                JYFormats *seleFormat = [[JYFormats alloc] init];
                seleFormat.fpsStr = [NSString stringWithFormat:@"%.f", range.maxFrameRate];
                seleFormat.format = format;
                
                [fpsArr addObject:seleFormat];
                maxWidth = range.maxFrameRate;
            }
        }
    }
    return fpsArr;
}

/** 九宫格 */
- (UIImageView *)grladView
{
    if (!_grladView) {
        _grladView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_grid_icon"]];
        _grladView.hidden = NO;
        _grladView.alpha = 0.3;
        
        [self.view insertSubview:_grladView belowSubview:self.subView];
    }
    return _grladView;
}

/** 局部放大的背景View */
- (UIView *)bottomPreview
{
    if (!_bottomPreview) {
        
        _bottomPreview = [[UIView alloc] init];
        _bottomPreview.hidden = YES;
        _bottomPreview.clipsToBounds = YES;
        _bottomPreview.backgroundColor = [UIColor yellowColor];
//        [_bottomPreview addSubview:self.videoCamera.scaleView];
        
        [self.view addSubview:_bottomPreview];
    }
    return _bottomPreview;
}

- (void)scalingWithFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue
{
    CABasicAnimation *animation=[CABasicAnimation animation];
    
    animation.delegate = self;
    animation.keyPath = @"transform.scale";
    // 动画选项设定
    animation.duration = 0.3; // 动画持续时间
    animation.repeatCount = 1; // 重复次数
    //    animation.autoreverses = YES; // 动画结束时执行逆动画
    
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:fromValue]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:toValue]; // 结束时的倍率
    //1.3设置保存动画的最新状态
    animation.fillMode=kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    // 添加动画
    [self.bottomPreview.layer addAnimation:animation forKey:@"scale-layer"];
}

/** 动画结束后掩藏局部放大 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.isHidden == YES) {
        self.bottomPreview.hidden = YES;
        self.isHidden = NO;
    } else
    {
        self.timeNum = 100;
    }
}

#pragma mark -------------------------> JYCoreBlueViewDelegate
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification
{
    UITextField *textField = notification.object;
    
    NSString *toBeString = textField.text;
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    
    //下面的方法是iOS7被废弃的，注释
    //    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 12) {
                textField.text = [toBeString substringToIndex:12];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 12) {
            textField.text = [toBeString substringToIndex:12];
        }
    }
    self.perName = textField.text;
}

- (void)coreBlueViewChangePerName:(JYPeripheral *)per
{
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:self.changeName message:self.nameMsg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = self.nameplace;
//        [textField markedTextRange];
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        
        [textField positionFromPosition:[textField markedTextRange].start offset:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    UIAlertAction *okAciton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // 显示当前修改的名字
        [JYSeptManager sharedManager].perName = self.perName;
        // 遍历数组中的数据，把相同identifier的名字替换掉
        for (JYPeripheral *mPer in self.coreBlueView.perArrays) {
            
            if ([mPer.identifier isEqualToString:per.identifier]) {
                mPer.name = [JYSeptManager sharedManager].perName;
            }
        }
        
        [[JYSeptManager sharedManager] saveCoreBlueWith:per];
        
        [self.coreBlueView.tableView reloadData];
    }];
    
    UIAlertAction *cancleAciton = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertCtl.textFields.firstObject];
    }];
    
    [alertCtl addAction:okAciton];
    [alertCtl addAction:cancleAciton];
    
    [self presentViewController:alertCtl animated:YES completion:nil];
}

- (BOOL)IsChinese:(NSString *)str
{
    for(int i=0; i< [str length];i++) {
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff) {
            return YES;
        }
    } return NO;
}

- (void)coreBlueViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.coreBlueView.perArrays.count > 0) {
        if (self.blueManager.peripherals) {
            
            if (self.blueManager.connectPeripheral == nil) {
                // 2.2 连接选中的蓝牙
                [self.blueManager connect:self.blueManager.peripherals[indexPath.row]];
            } else
            {
                if (self.blueManager.connectPeripheral != self.blueManager.peripherals[indexPath.row]) {
                    // 2.1 断开当前连接的设备
                    [self.blueManager disconnect:self.blueManager.connectPeripheral];
                    
                    // 2.2 连接选中的蓝牙
                    [self.blueManager connect:self.blueManager.peripherals[indexPath.row]];
                }
            }
            // 保存当前连接的蓝牙名称，
            CBPeripheral *pper = self.blueManager.peripherals[indexPath.row];
            [JYSeptManager sharedManager].perName = pper.name;
        }
    }
    self.coreBlueView.hidden = YES;
    self.myContentView.scrollView.hidden = NO;
}

/** 蓝牙显示的View */
- (JYCoreBlueView *)coreBlueView
{
    if (!_coreBlueView) {
        
        _coreBlueView = [[JYCoreBlueView alloc] init];
        _coreBlueView.peripherals = self.blueManager.peripherals;
        _coreBlueView.hidden = YES;
        _coreBlueView.delegate = self;
        
        [self.subView addSubview:_coreBlueView];
    }
    return _coreBlueView;
}

#pragma mark -------------------------> 刻度尺滑动手势监听事件
- (void)ruleImgViewGesture:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateChanged || panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [panGesture translationInView:self.ruleBottomView];
        switch (self.useModel) {
            case CoreBlueUseModelFocus:
                self.blueManager.moveDistance += translation.y;
                break;
            case CoreBlueUseModelZOOM:
                self.blueManager.videoZoom += translation.y;
                break;
            case CoreBlueUseModelDurationAndZoom:
                self.blueManager.videoZoom += translation.y;
                break;
            case CoreBlueUseModelDurationAndFucus:
                self.blueManager.moveDistance += translation.y;
                break;
            default:
                break;
        }
        
        [panGesture setTranslation:CGPointMake(0, 0) inView:self.ruleBottomView];
    }
}

- (void)ruleImgViewTimer
{
    self.focusNum = [self blueManagerType:self.blueManager.moveDistance andNum:0 qubie:1];
    self.zoomNum = [self blueManagerType:self.blueManager.videoZoom andNum:0 qubie:0];
    switch (self.useModel) {
        case CoreBlueUseModelFocus:
            [self timerClickView:self.focusView type:1 translation:self.focusNum];
            break;
        case CoreBlueUseModelZOOM:
            [self timerClickView:self.zoomView type:0 translation:self.zoomNum];
            break;
        case CoreBlueUseModelDurationAndFucus:
            [self timerClickView:self.focusView type:1 translation:self.focusNum];
            break;
        case CoreBlueUseModelDurationAndZoom:
            [self timerClickView:self.zoomView type:0 translation:self.zoomNum];
            break;
        case CoreBlueUseModelRepeatRecording:
        {
            // 调焦
            if (self.saveFocusNum != self.blueManager.moveDistance) {
                self.focusView.hidden = NO;
                self.zoomView.hidden = YES;
                //                NSLog(@"self.iFocusView.y = %f", self.iFocusView.y);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [UIView animateWithDuration:AnimationTime/1000 animations:^{
//                        self.focusView.transform = CGAffineTransformMakeTranslation(0, self.focusNum);
//                    }];
//                });
                [self animationWith:self.focusNum layer:self.focusView];
                // 30是showView的高度   -- 调节微距
                [self.videoCamera videCameraChangeFoucus:(1 - (-self.focusNum + SHOW_Y) / (screenH - 30))];
                // 3.保存最后一次的移动距离
                self.saveFocusNum = self.blueManager.moveDistance;
            }
            
            if (self.saveVideoZoom != self.blueManager.videoZoom) {
                self.focusView.hidden = YES;
                self.zoomView.hidden = NO;
                
                [self animationWith:self.zoomNum layer:self.zoomView];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [UIView animateWithDuration:AnimationTime/1000 animations:^{
//                        self.zoomView.transform = CGAffineTransformMakeTranslation(0, self.zoomNum);
//                    }];
//                });
                
                if (self.cameraType == JYCameraTypeVideo) {
//                    [self.videoCamera vi:(-self.zoomNum + SHOW_Y) / (screenH - 30)];
                } else {
//                    [self.captureManager cameraManagerVideoZoom:(-self.zoomNum + SHOW_Y) / (screenH - 30)];
                }
                self.saveVideoZoom = self.blueManager.videoZoom;
            }
        }
            break;
    }
}

- (void)animationWith:(CGFloat)value layer:(CALayer *)layer
{
    CABasicAnimation *anima=[CABasicAnimation animation];
    
    //1.1告诉系统要执行什么样的动画
    anima.keyPath=@"position";
    //设置通过动画，将layer从哪儿移动到哪儿
    anima.toValue = [NSValue valueWithCGPoint:CGPointMake(25, value + 15)];
    //    NSLog(@"%@", anima.toValue);
    
    //1.2设置动画执行完毕之后不删除动画
    anima.removedOnCompletion=NO;
    //1.3设置保存动画的最新状态
    anima.fillMode=kCAFillModeForwards;
    //2.添加核心动画到layer
    [layer addAnimation:anima forKey:nil];
    
}

- (CGFloat) getZoomSliderValue:(CGFloat)value {
    // slightly fancy math to provide a linear feel to the slider
    return pow( [self.videoCamera getMaxZoom], value );
}

//- (void) setZoomSliderValue:(CGFloat)value {
//    // inverse of above: log base max of value
//    self.subSlider.value = log(value) / log([self.videoCamera getMaxZoom]);
//    NSLog(@"%f", self.subSlider.value);
//}

- (void)timerClickView:(CALayer *)clickView type:(NSInteger)type translation:(CGFloat)y
{
    if (self.saveNum != y) {
        
        [self animationWith:y layer:clickView];
        
        if (type == 0) {
            dispatch_async(self.sessionQueue, ^{
                if (self.cameraType == JYCameraTypeVideo) {
                    
                    [self.videoCamera videoZoomWithValue:[self getZoomSliderValue:0.5 - (-y + SHOW_Y) / (screenH - 30)]];
                } else {
                    [self.photoCamera photosCameraWithZoom:[self getZoomSliderValue:0.5 - (-y + SHOW_Y) / (screenH - 30)]];
                }
            });
            
        }else
        {
//            dispatch_async(self.sessionQueue, ^{
//                self.logView.myText.text = [NSString stringWithFormat:@"%f", (0.5 - (-y + SHOW_Y) / (screenH - 30))];
                // 2.1 30是showView的高度   -- 调节微距
                
            
            dispatch_async(self.sessionQueue, ^{
                if (self.cameraType == JYCameraTypeVideo) {
                    [self.videoCamera videCameraChangeFoucus:(0.5 - (-y + SHOW_Y) / (screenH - 30))];
                } else {
                    [self.photoCamera photosCameraChangeFoucus:(1 - (-y + SHOW_Y) / (screenH - 30))];
                }
            });
                
                // 2.2显示放大的View和sliderView
                if (self.enlargeBtn.selected == YES) {
                    self.bottomPreview.hidden = NO;
                    self.timeNum = 50;
                }
//            });
        
        }
        self.saveNum = y;
    }
//    self.logView.camereText.text = [NSString stringWithFormat:@"%f", self.videoCamera.inputCamera.lensPosition];
    // 3.控制放大view的显示与掩藏
    self.timeNum--;
//    dispatch_async(self.sessionQueue, ^{
        if (self.timeNum == 0) {
            self.bottomPreview.hidden = YES;
            self.timeNum = 0;
        }
//    });
}

- (CGFloat)blueManagerType:(CGFloat)type andNum:(CGFloat)num qubie:(NSInteger)qubie
{
    if (type <= 0) {
        type = 0;
    }
    if (type >= 2 * SHOW_Y) {
        type = 2 * SHOW_Y;
    }
    if (qubie == 1) {
        self.blueManager.moveDistance = type;
//                NSLog(@"moveDistance = %f", self.blueManager.moveDistance);
    } else
    {
        self.blueManager.videoZoom = type;
//                NSLog(@"videoZoom = %f", self.blueManager.videoZoom);
    }
    CGFloat realNum = type + num;
    return realNum;
}

#pragma mark -------------------------> JYContenViewDelegate
/** 显示蓝牙界面 */
- (void)contentViewLabelDirectionBtnOnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 50:  // 蓝牙界面显示
        {
            self.coreBlueView.peripherals = self.blueManager.peripherals;
            
            self.myContentView.scrollView.hidden = YES;
            self.coreBlueView.hidden = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.coreBlueView.tableView reloadData];
            });
        }
            break;
        case 53:   // 手轮方向
            if (self.blueManager.connectPeripheral == nil) {
                [self resetVideoAndHandwheelAlert];
            } else {
                self.myContentView.handBool = YES;
            }
            break;
        case 56:   // 自动重复
            if (self.blueManager.connectPeripheral == nil) {
                [self resetVideoAndHandwheelAlert];
            }else {
                self.myContentView.handBool = YES;
            }
            break;
        case 58:   // fps
            self.fpsArray = [self getFpsAtNowResolution];
            [self.fpsView reloadData];
            self.myContentView.scrollView.hidden = YES;
            self.fpsView.hidden = NO;
            break;
        default:
            break;
    }
}

/**  摄像头，闪光灯，九宫格 */
- (void)contentViewSwitchOnClick:(UISwitch *)mSwitch
{
    switch (mSwitch.tag) {
        case 42:    // 前置录像灯
            self.blueManager.isFalsh = mSwitch.on;
            [[NSUserDefaults standardUserDefaults] setBool:mSwitch.on forKey:@"videoFalsh"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case 41:    // 九宫格
            self.grladView.hidden = !mSwitch.on;
            break;
        default:
            break;
    }
}

/** 恢复默认设置 */
- (void)contentViewResetBtnOnClick:(UIButton *)btn
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.altTitle message:self.altMesage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:self.altCancel style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:self.altSure style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //改变完成之后发送通知，告诉其他页面修改完成，提示刷新界面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RestoreDefaults" object:nil];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/** JYResolutionViewDelegate  相机质量选择 */
- (void)contentViewDirectionCellBtnOnClick:(UIButton *)btn
{
    [self.videoCamera videoCameraQualityWithTag:btn.tag];
}

/** 设置对比度 */
- (void)contentViewCustomSliderValueChange:(UISlider *)slider
{
    self.ruleBottomView.layer.opacity = slider.value;
    self.videoTimeView.layer.opacity = slider.value;
    self.infoView.layer.opacity = slider.value;
    self.leftTopView.layer.opacity = slider.value;
    self.layer.opacity = slider.value;
    self.videoView.layer.opacity = slider.value;
}

/** 设置白平衡滑动数据 */
- (void)contentViewBalanceCustomSliderValueChange:(UISlider *)slider
{
    switch (slider.tag) {
        case 50:     // 色温
        {
            self.temp = slider.value;
//            self.logView.tempText.text = [NSString stringWithFormat:@"%f", self.temp];
            AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
                .temperature = self.temp,
                .tint = self.tint,
            };
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraSetWhiteBalanceGains:[self.videoCamera.videoDevice deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
            } else {
                [self.photoCamera photosCameraSetWhiteBalanceGains:[self.photoCamera.photosManager.inputCamera deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
            }
        }
            break;
        case 51:     // 色调
        {
            self.tint = slider.value;
//            self.logView.tintText.text = [NSString stringWithFormat:@"%f", self.tint];
            AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
                .temperature = self.temp,
                .tint = self.tint,
            };
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraSetWhiteBalanceGains:[self.videoCamera.videoDevice deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
            } else {
                [self.photoCamera photosCameraSetWhiteBalanceGains:[self.photoCamera.photosManager.inputCamera deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
            }
        }
            break;
        case 52:     // 饱和度
            
//            [self mainVideoCamera];
            
            [self.photoCamera.saturationFilter setSaturation:[(UISlider *)slider value]];
            
            break;
            
        default:
            break;
    }
}

/** 设置白平衡自动和手动 */
- (void)contentViewBalanceAutoBtnOnClick:(UIButton *)btn
{
    //    NSLog(@"%ld",(long)btn.selected);
    switch (btn.tag) {
        case 30:    // 色温
            self.tempAuto = !btn.selected;
            if (self.tintAuto == 0 && self.tempAuto == 0) {   // 如果色调当前处于自动状态
                if (self.cameraType == JYCameraTypeVideo) {
                    [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                } else {
                    [self.photoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                }
                [JYSeptManager sharedManager].iSHUD = NO;
            } else
            {
                if (self.cameraType == JYCameraTypeVideo) {
                    [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
                } else {
                    [self.photoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
                }
                [JYSeptManager sharedManager].iSHUD = YES;
            }
            
            break;
        case 31:    // 色调
            self.tintAuto = !btn.selected;
            if (self.tintAuto == 0 && self.tempAuto == 0) {   // 如果色调当前处于手动状态
                
                if (self.cameraType == JYCameraTypeVideo) {
                    [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                } else {
                    [self.photoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                }
                [JYSeptManager sharedManager].iSHUD = NO;
            } else
            {
                
                if (self.cameraType == JYCameraTypeVideo) {
                    [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
                } else {
                    [self.photoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
                }
                [JYSeptManager sharedManager].iSHUD = YES;
            }
            break;
        case 32:    // 饱和度
//            [self mainVideoCamera];
            [self.photoCamera.saturationFilter setSaturation:1.0];
            break;
            
        default:
            break;
    }
}

/** 天气滤镜 */
- (void)contentViewWetherButtonOnClick:(UIButton *)btn
{
    if ([JYSeptManager sharedManager].iSHUD == YES) {
        
        [SVProgressHUD show];
        
        if (self.cameraType == JYCameraTypeVideo) {
            [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        } else {
            [self.photoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            [self setWeatherFilterWithtag:btn.tag];
        });
    } else {
        [self setWeatherFilterWithtag:btn.tag];
    }
    [JYSeptManager sharedManager].iSHUD = NO;
}

- (void)setWeatherFilterWithtag:(NSInteger)tag
{
    self.tintAuto = YES;
    self.tempAuto = YES;
    
    [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
    switch (tag) {
        case 80:      // 日光灯
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraBalanceGainsWithTemp:self.temp + 500 andTint:self.tint];
            } else {
                [self.photoCamera photosCameraBalanceGainsWithTemp:self.temp + 500 andTint:self.tint];
            }
            self.myContentView.whiteSize = CGSizeMake(self.temp + 500, self.tint);
            break;
        case 81:      // 钨丝灯
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraBalanceGainsWithTemp:self.temp + 2700 andTint:self.tint];
            } else {
                [self.photoCamera photosCameraBalanceGainsWithTemp:self.temp + 2700 andTint:self.tint];
            }
            self.myContentView.whiteSize = CGSizeMake(self.temp + 2700, self.tint);
            break;
        case 82:      // 烛光
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraBalanceGainsWithTemp:self.temp + 7000 andTint:self.tint];
            } else {
                [self.photoCamera photosCameraBalanceGainsWithTemp:self.temp + 7000 andTint:self.tint];
            }
            self.myContentView.whiteSize = CGSizeMake(self.temp + 7000, self.tint);
            break;
        case 83:      // 阴天
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraBalanceGainsWithTemp:self.temp - 500 andTint:self.tint];
            } else {
                [self.photoCamera photosCameraBalanceGainsWithTemp:self.temp - 500 andTint:self.tint];
            }
            self.myContentView.whiteSize = CGSizeMake(self.temp - 500, self.tint);
            break;
        case 84:      // 晴天
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraBalanceGainsWithTemp:self.temp - 1000 andTint:self.tint];
            } else {
                [self.photoCamera photosCameraBalanceGainsWithTemp:self.temp - 1000 andTint:self.tint];
            }
            self.myContentView.whiteSize = CGSizeMake(self.temp - 1000, self.tint);
            break;
        case 85:      // 蓝天
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            } else {
                [self.photoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            break;
        default:
            break;
    }
}

- (void)contentViewExpsureCustomSliderValueChange:(UISlider *)slider
{
    switch (slider.tag) {
        case 61:     // 感光度
            [self.videoCamera videoCameraExposureIOS:slider.value];
            break;
        case 62:     // 曝光时间
        {
            [self.videoCamera videoCameraExposureDurationWith:slider.value];
        }
            break;
    }
}

/** 设置闪光灯的开和自动 */
- (void)contentViewFlashViewOnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 100:
            [self.videoCamera flashModel:AVCaptureFlashModeAuto];
            break;
        case 101:
            [self.videoCamera flashModel:AVCaptureFlashModeOn];
            break;
        case 102:
            [self.videoCamera flashModel:AVCaptureFlashModeOff];
            break;
    }
}

/** 曝光自动和手动的监听事件 */
- (void)contentViewExpsureAutoBtnOnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 41:    // 感光度
            self.isoAuto = !btn.selected;
            if (btn.selected) {
                if (self.timeAuto == 0) {
                    [self.videoCamera exposeMode:AVCaptureExposureModeContinuousAutoExposure];
                }
            } else {
                [self.videoCamera exposeMode:AVCaptureExposureModeLocked];
            }
            break;
        case 42:    // 曝光时间
            self.timeAuto = !btn.selected;
            if (btn.selected) {
                if (self.isoAuto == 0) {
                    [self.videoCamera exposeMode:AVCaptureExposureModeContinuousAutoExposure];
                }
            } else {
                [self.videoCamera exposeMode:AVCaptureExposureModeLocked];
            }
            break;
    }
}

- (void)contentViewPushEsaycamWebView
{
    JYWebViewController *webCtl = [[JYWebViewController alloc] init];
    
    [self.navigationController pushViewController:webCtl animated:YES];
}

- (void)contentViewCameraLensViewCellBtnOnClick:(UIButton *)btn
{
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:self.sizeTitle message:self.lensMesage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:self.altSure style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        switch (btn.tag) {
            case 80:      // 默认
                self.infoView.dzText = @"x1";
                self.blueManager.managerLens = JYBlueManagerLensOne;
                self.focusView.contents = (id)[UIImage imageNamed:@"1x_focus"].CGImage;
                break;
            case 81:      // 2倍增距镜
                self.infoView.dzText = @"x2";
                self.blueManager.managerLens = JYBlueManagerLensTwo;
                self.focusView.contents = (id)[UIImage imageNamed:@"2x_focus"].CGImage;
                break;
            case 82:      // 3倍增距镜
                self.infoView.dzText = @"//";
                self.blueManager.managerLens = JYBlueManagerLensThree;
                self.focusView.contents = (id)[UIImage imageNamed:@"degree_scale_other"].CGImage;
                break;
                
            default:
                break;
        }
    }];
    
    [alertCtl addAction:okAction];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:self.altCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.myContentView contenViewCameraLensViewShowOneCell];
        self.infoView.dzText = @"x1";
        
        [self.myContentView contenViewSetDirectionBtnTitle:btn.currentTitle andTag:85];
    }];
    [alertCtl addAction:noAction];
    
    [self presentViewController:alertCtl animated:YES completion:nil];
}

/** 设置自动重复模式 */
- (void)contentViewResetVideo:(UIButton *)btn
{
    if (self.blueManager.connectPeripheral != nil) {
        switch (btn.tag) {
            case 80:
                self.blueManager.videoType = JYResetVideoTypeTwo;
                break;
            case 81:
                self.blueManager.videoType = JYResetVideoTypeOne;
                break;
        }
        [[NSUserDefaults standardUserDefaults] setBool:self.blueManager.videoType forKey:@"ResetVideo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.myContentView contenViewSetDirectionBtnTitle:btn.currentTitle andTag:86];
    }else {
        [self resetVideoAndHandwheelAlert];
    }
}

- (void)resetVideoAndHandwheelAlert
{
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:self.sizeTitle message:self.direction preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:self.sizeOk style:UIAlertActionStyleCancel handler:nil];
    
    [alertCtl addAction:OKAction];
    
    [self presentViewController:alertCtl animated:YES completion:nil];
}

/** 设置手轮方向 */
- (void)contentViewHandwheelOnClick:(UIButton *)btn
{
    if (self.blueManager.connectPeripheral != nil) {
        switch (btn.tag) {
            case 80:
                self.blueManager.derection = CoreBlueDerectionClockwise;
                break;
            case 81:
                self.blueManager.derection = CoreBlueDerectionAntiClockwise;
                break;
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:self.blueManager.derection forKey:BlueDerection];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 选中成功则显示当前选中的名称
        [self.myContentView contenViewSetDirectionBtnTitle:btn.currentTitle andTag:84];
    }else {
        [self resetVideoAndHandwheelAlert];
    }
}

- (void)exposureFiveXiaoGuoButtonOnClick:(UIButton *)btn
{
    switch (self.takeType) {
        case JYTakePhotosTypeSights:
            [self.photoCamera.saturationFilter setSaturation:1.5];
            break;
        case JYTakePhotosTypePeople:
//            [self mainVideoCamera];
            [self.photoCamera stopPortrait];
            break;
        case JYTakePhotosTypeNight:
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera exposeMode:AVCaptureExposureModeLocked];
            } else {
                [self.photoCamera exposeMode:AVCaptureExposureModeLocked];
            }
            break;
        default:
            break;
    }
    
    switch (btn.tag) {
        case 70:      // 风景模式
            self.takeType = JYTakePhotosTypeSights;
            [self.photoCamera.saturationFilter setSaturation:1.5];
            break;
        case 71:      // 人像模式
            self.takeType = JYTakePhotosTypePeople;
            [self.photoCamera startPortrait];
            break;
        case 72:      // 夜景模式
            self.takeType = JYTakePhotosTypeNight;
            [self.photoCamera exposeMode:AVCaptureExposureModeLocked];
            [self.photoCamera photosCameraExposureDuration:1.0];
            
            [SVProgressHUD showInfoWithStatus:@"拍摄时保持手机稳定" duration:1.0f style:SVProgressHUDMaskTypeBlack];
            break;
        case 73:      // HDR
            self.takeType = JYTakePhotosTypeHDR;
            break;
        case 74:      // 双重曝光
            self.takeType = JYTakePhotosTypeResetExposure;
            break;
        case 75:      // 正常
            self.takeType = JYTakePhotosTypeNonal;
            break;
    }
}

- (void)threeViewButtonOnClick:(UIButton *)sender
{
    self.coreBlueView.hidden = YES;
    self.fpsView.hidden = YES;
}

- (void)alertController
{
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:self.sizeTitle message:self.sizeMesage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:self.sizeOk style:UIAlertActionStyleDefault handler:nil];
    [alertCtl addAction:okAction];
    
    [self presentViewController:alertCtl animated:YES completion:nil];
}

- (void)baisSliderValueChange:(UISlider *)slider
{
    switch (slider.tag) {
        case 10:
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraWithExposure:slider.value / 300];
            } else {
                [self.photoCamera.exposureFilter setExposure:slider.value / 300];
            }
            break;
        case 11:
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraExposureDurationWith:slider.value];
            } else {
                [self.photoCamera photosCameraExposureDuration:slider.value];
            }
            break;
        case 12:
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraExposureIOS:slider.value];
            } else {
                [self.photoCamera photosCameraExposureIOS:slider.value];
            }
            break;
            
        default:
            break;
    }
}

- (void)contentViewBaisSliderAutoBtnOnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 30:
            
            if (self.cameraType == JYCameraTypeVideo) {
                [self.videoCamera videoCameraWithExposure:0];
            } else {
                [self.photoCamera.exposureFilter setExposure:0];
            }
            break;
        case 31:
            self.timeAuto = !btn.selected;
            if (btn.selected) {
                if (self.isoAuto == 0) {
                    if (self.cameraType == JYCameraTypeVideo) {
                        [self.videoCamera exposeMode:AVCaptureExposureModeContinuousAutoExposure];
                    } else {
                        [self.photoCamera exposeMode:AVCaptureExposureModeContinuousAutoExposure];
                    }
                }
            } else {
                
                if (self.cameraType == JYCameraTypeVideo) {
                    [self.videoCamera exposeMode:AVCaptureExposureModeLocked];
                } else {
                    [self.photoCamera exposeMode:AVCaptureExposureModeLocked];
                }
            }
            break;
        case 32:
            self.isoAuto = !btn.selected;
            if (btn.selected) {
                if (self.timeAuto == 0) {
                    if (self.cameraType == JYCameraTypeVideo) {
                        [self.videoCamera exposeMode:AVCaptureExposureModeContinuousAutoExposure];
                    } else {
                        [self.photoCamera exposeMode:AVCaptureExposureModeContinuousAutoExposure];
                    }
                }
            } else {
                
                if (self.cameraType == JYCameraTypeVideo) {
                    [self.videoCamera exposeMode:AVCaptureExposureModeLocked];
                } else {
                    [self.photoCamera exposeMode:AVCaptureExposureModeLocked];
                }
            }
            break;
            
        default:
            break;
    }
}

/** 设置的内容视图 */
- (JYContenView *)myContentView
{
    if (!_myContentView) {
        
        _myContentView = [[JYContenView alloc] init];
        
        _myContentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:BG_ALPHA];
        _myContentView.delegate = self;
        _myContentView.hidden = YES;
        
        [self.subView addSubview:_myContentView];
    }
    return _myContentView;
}

#pragma mark -------------------------> JYVideoViewDelegate
- (void)videoViewButtonOnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 21:    // 录像
            btn.selected = !btn.selected;
            if (btn.selected == 1) {
                [self takeVideoing];
            } else
            {
//                [self stopVideoing];
//                [_timer setFireDate:[NSDate distantFuture]];
//                //                NSLog(@"%@", self.videoCamera.imgsArray);
//                UIImageWriteToSavedPhotosAlbum([self createLongExposure:self.videoCamera.imgsArray], nil, nil, nil);
//                [self.videoCamera.imgsArray removeAllObjects];
                
//                if (self.fpsType == JYfpsType30Or60) {
                    [self stopVideoing];
                [SVProgressHUD showWithStatus:@"正在保存" style:SVProgressHUDMaskTypeBlack];
//                } else {
//                    [self.captureManager testStop];
//                    [self.videoTimeView stopTimer];
//                }
            }
            
            break;
        case 22:    // 拍照
//            [self mainVideoCamera];
//            [_timer setFireDate:[NSDate date]];
            switch (self.takeType) {
                case JYTakePhotosTypeHDR:
                    [self.photoCamera takePhotosWithHDR];
                    break;
                case JYTakePhotosTypeResetExposure:
                    [self.photoCamera doubleExposure];
                    break;
                default:
                    [self startPhoto];
                    break;
            }
            break;
        case 23:    // 图片选择
        {
            [[JYSaveVideoData sharedManager] photosArrayAndthumbsArrayValue];
            
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            
            browser.zoomPhotosToFill = YES;
            browser.enableSwipeToDismiss = NO;
            [browser setCurrentPhotoIndex:0];
            
            [self.navigationController pushViewController:browser animated:YES];
        }
            break;
        case 24:
//            self.logView.hidden = !self.logView.hidden;
//            NSLog(@"%@", self.videoCamera.imgsArray);
//            UIImageWriteToSavedPhotosAlbum([self createLongExposure:self.videoCamera.imgsArray], nil, nil, nil);
//            self.videoView.image = [self createLongExposure:self.videoCamera.imgsArray];
//            [self.videoCamera.imgsArray removeAllObjects];
            
            break;
    }
}

- (UIImage *) createLongExposure:(NSArray *)images {
    UIImage *firstImg = images[0];
    CGSize imgSize = firstImg.size;
    CGFloat alpha = 1.0 / images.count;
    
    UIGraphicsBeginImageContext(imgSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, imgSize.width, imgSize.height));
    
    for (UIImage *image in images) {
        [image drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)
                blendMode:kCGBlendModePlusLighter alpha:alpha];
    }
    UIImage *longExpImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return longExpImg;
}

- (void)testMax:(CGRect)max min:(CGRect)min
{
    self.logView.myText.text = [NSString stringWithFormat:@"%f", max.origin.x/max.origin.y];
    self.logView.camereText.text = [NSString stringWithFormat:@"%f", min.origin.x / min.origin.y];
}

- (void)startPhoto
{
    CATransition *shutterAnimation = [CATransition animation];
    [shutterAnimation setDelegate:self];
    // シャッター速度
    [shutterAnimation setDuration:0.2];
    shutterAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [shutterAnimation setType:@"cameraIris"];
    [shutterAnimation setValue:@"cameraIris" forKey:@"cameraIris"];
    CALayer *cameraShutter = [[CALayer alloc]init];
    //    [cameraShutter setBounds:CGRectMake(0.0, 0.0, 320.0, 425.0)];
    [self.view.layer addSublayer:cameraShutter];
    [self.view.layer addAnimation:shutterAnimation forKey:@"cameraIris"];
    if (self.cameraType == JYCameraTypeVideo) {
        [self.videoCamera videoTakeingPhotos];
    } else {
        [self.photoCamera takePhoto];
    }
}

/** 录像、拍照按钮的背景 */
- (JYVideoView *)videoView
{
    if (!_videoView) {
        
        _videoView = [[JYVideoView alloc] init];
        _videoView.layer.opacity = ([[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"] == 0) ? 1 : [[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"];
        _videoView.delegate = self;
        
        [self.subView addSubview:_videoView];
    }
    return _videoView;
}

/** 录像时间显示 */
- (JYVideoTimeView *)videoTimeView
{
    if (!_videoTimeView) {
        
        _videoTimeView = [[JYVideoTimeView alloc] init];
        _videoTimeView.hidden = YES;
        _videoTimeView.layer.opacity = ([[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"] == 0) ? 1 : [[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"];
        
        [self.subView addSubview:_videoTimeView];
    }
    return _videoTimeView;
}

#pragma mark -------------------------> JYLeftTopViewDelegate
- (void)leftTopViewQuickOrSettingBtnOnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 10:
            break;
        case 11:
            if (self.coreBlueView.hidden == NO) {
                self.coreBlueView.hidden = YES;
                self.myContentView.isHidden = NO;
            }
            else if (self.fpsView.hidden == NO) {
                self.myContentView.isHidden = NO;
                self.fpsView.hidden = YES;
            }
            else {
                self.myContentView.hidden = !btn.selected;
            }
            break;
            
        default:
            break;
    }
}

/** 左上角设置按钮和快捷键按钮 */
- (JYLeftTopView *)leftTopView
{
    if (!_leftTopView) {
        
        _leftTopView = [[JYLeftTopView alloc] init];
        _leftTopView.backgroundColor = [UIColor clearColor];
        _leftTopView.delegate = self;
        
        [self.subView addSubview:_leftTopView];
    }
    return _leftTopView;
}


#pragma mark -------------------------> DWBubbleMenuViewDelegate
/** 按钮显示之后 */
- (void)bubbleMenuButtonWillExpand:(DWBubbleMenuButton *)expandableView
{
//    NSLog(@"%s", __func__);
    //    self.leftTopView.isShow = YES;
    self.leftTopView.quickBtn.image = [UIImage imageNamed:@"dub_arrow_up"];
}

/** 按钮掩藏之后 */
- (void)bubbleMenuButtonDidCollapse:(DWBubbleMenuButton *)expandableView
{
//    NSLog(@"%s", __func__);
    //    self.leftTopView.isShow = NO;
    self.leftTopView.quickBtn.image = [UIImage imageNamed:@"dub_arrow_down"];
}

- (void)setUpphotoImgPhtoto
{
    [self.phtotBtn setImage:[UIImage imageNamed:@"home_photo_click_icon"] forState:UIControlStateNormal];
    self.imgModel = JYPhotoImgPhtoto;
    self.videoView.isVideo = YES;
//    self.sliderImageView.hidden = self.videoView.isVideo;
    
    [self.videoCamera exposeMode:AVCaptureExposureModeContinuousAutoExposure];
    
    if (self.focusView.hidden == NO) {
        self.useModel = CoreBlueUseModelFocus;
    } else {
        self.useModel = CoreBlueUseModelZOOM;
    }
}

- (void)plusButtonOnClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    switch (btn.tag) {
        case 100:    // MF <---> ZM
            self.useModel = !btn.selected;
            self.focusView.hidden = !btn.selected;
            self.zoomView.hidden = !self.focusView.hidden;
            break;
        case 101:   // video <---> photo
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoView.isVideo = btn.selected;
                [[NSUserDefaults standardUserDefaults] setBool:btn.selected forKey:@"video"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (btn.selected == YES) {    // 拍照
                    // 1.停止视频录制会话
                    [self.videoCamera stopSession];
                    // 2.掩藏AVCaptureVideoPreviewLayer
                    self.videoCamera.previewLayer.hidden = YES;
                    
                    // 2.显示GPUImageView
                    self.photoCamera.filteredVideoView.hidden = NO;
                    
                    // 开启拍照会话
                    [self.photoCamera startCamera];
                    self.cameraType = JYCameraTypePhoto;
                } else {
                    [self.videoCamera startSession];
                    
                    // 掩藏GPUImageView
                    self.photoCamera.filteredVideoView.hidden = YES;
                    
                    // 显示AVCaptureVideoPreviewLayer
                    self.videoCamera.previewLayer.hidden = NO;
                    
                    [self.photoCamera stopCamera];
                    self.cameraType = JYCameraTypeVideo;
                }
                [self.myContentView contentViewSwitchHidden:YES andTag:42];
                
                [JYSeptManager sharedManager].cameraType = self.cameraType;
                //改变完成之后发送通知，告诉其他页面切换模型
                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCamera" object:nil];
                
            });
        }
            break;
        case 102:
            self.collectionView.hidden = !btn.selected;
            break;
        case 103:    // 局部放大功能
            if (btn.selected == 1) {
                self.bottomPreview.hidden = NO;
                [self scalingWithFromValue:0.45 toValue:1.0];
            } else
            {
                [self scalingWithFromValue:1.0 toValue:0.45];
                self.isHidden = YES;
            }
            break;
    }
}

//- (void)sliderViewHidden
//{
//    if (self.bottomPreview.hidden == NO) {
//        self.bottomPreview.hidden = YES;
//    }
//}

- (DWBubbleMenuButton *)menuBtn
{
    if (!_menuBtn) {
        _menuBtn = [[DWBubbleMenuButton alloc] initWithFrame:CGRectMake(18.f, 10.f, 35, 35) expansionDirection:DirectionDown];
        
        _menuBtn.delegate = self;
        
        _menuBtn.homeButtonView = self.leftTopView.quickBtn;
        
        [_menuBtn addButtons:[self createDemoButtonArray]];
    }
    return _menuBtn;
}

- (UIButton *)videoBtn
{
    if (!_videoBtn) {
        
        _videoBtn = [self createBtnWithImg:@"shift_ZMtoMF" seletedImg:@"shift_MFtoZM" size:CGSizeMake(35.0f, 65.0f)];
        _videoBtn.tag = 100;
        _videoBtn.selected = YES;
    }
    return _videoBtn;
}

- (UIButton *)phtotBtn
{
    if (!_phtotBtn) {
        
        _phtotBtn = [self createBtnWithImg:@"shift_RECtoCAM" seletedImg:@"shift_CAMtoREC" size:CGSizeMake(35.0f, 65.0f)];
        _phtotBtn.tag = 101;
        _phtotBtn.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"video"];
    }
    return _phtotBtn;
}

//- (UIButton *)timesBtn
//{
//    if (!_timesBtn) {
//        
//        _timesBtn = [self createBtnWithImg:@"Zoom_in_on" seletedImg:@"Zoom_in_off" size:CGSizeMake(35.0f, 60.0f)];
//        _timesBtn.tag = 102;
//        _timesBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 0);
//    }
//    return _timesBtn;
//}

- (UIButton *)enlargeBtn
{
    if (!_enlargeBtn) {
        
        _enlargeBtn = [self createBtnWithImg:@"Zoom_in_on" seletedImg:@"Zoom_in_off" size:CGSizeMake(35.0f, 60.0f)];
        _enlargeBtn.tag = 103;
        _enlargeBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 0);
    }
    return _enlargeBtn;
}

- (UIButton *)createBtnWithImg:(NSString *)img seletedImg:(NSString *)sImg  size:(CGSize)size
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:[UIImage imageNamed:img] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:sImg] forState:UIControlStateNormal];
    [button setAdjustsImageWhenHighlighted:NO];
    
    button.frame = CGRectMake(0.f, 0.f, size.width, size.height);
    button.clipsToBounds = YES;
    
    [button addTarget:self action:@selector(plusButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (NSArray *)createDemoButtonArray
{
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
        
//    [buttonsMutable addObject:self.mainBtn];
    [buttonsMutable addObject:self.videoBtn];
    [buttonsMutable addObject:self.phtotBtn];
    [buttonsMutable addObject:self.enlargeBtn];
//    [buttonsMutable addObject:self.timesBtn];
    
    return [buttonsMutable copy];
}

- (JYCollectionView *)collectionView
{
    if (!_collectionView) {
        
        _collectionView = [JYCollectionView collectionViewWithSize:CGSizeMake(self.myContentView.width, 40)];
        
        _collectionView.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:BG_ALPHA];
        _collectionView.delegate = self;
        _collectionView.hidden = YES;
        
        [self.subView addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)collectionViewDidSelectIndex:(CGFloat)time
{
//    if (time <= 1.0) {   // 这些值大于1.0,则直接复制给快门时间
////        self.videoCamera.isLongExposure = NO;
////        [self.soundSlider setValue:0.8f animated:NO];
////        [self.soundSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
//        [self.videoCamera setExposureDurationWith:time];
//    } else {
////        self.videoCamera.isLongExposure = YES;
//        [self.soundSlider setValue:0.0f animated:NO];
//        [self.soundSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
//        [self.videoCamera cameraManagerExposureIOS:46];
//        [self.videoCamera setExposureDurationWith:0.932];
////        self.videoCamera.arrCount = (NSInteger)time;
//    }
}

/** 蓝牙显示的View */
- (JYShowInfoView *)infoView
{
    if (!_infoView) {
        
        _infoView = [[JYShowInfoView alloc] init];
        
        [self.subView addSubview:_infoView];
    }
    return _infoView;
}

#pragma mark -------------------------> 刻度尺操作
/** 图片底部的背景View */
- (UIView *)ruleBottomView
{
    if (!_ruleBottomView) {
        
        _ruleBottomView = [[UIView alloc] init];
        _ruleBottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:BG_ALPHA];
        _ruleBottomView.layer.opacity = ([[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"] == 0) ? 1 : [[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"];
        CALayer *layer = [CALayer layer];
        
        //设置需要显示的图片
        layer.contents=(id)[UIImage imageNamed:@"home_i_show_view_icon"].CGImage;
        
        [_ruleBottomView.layer addSublayer:layer];
        self.layer = layer;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ruleImgViewGesture:)];
        
        [_ruleBottomView addGestureRecognizer:panGesture];
        
        [self.subView addSubview:_ruleBottomView];
    }
    return _ruleBottomView;
}

/** 刻度尺图片View */
- (CALayer *)focusView
{
    if (!_focusView) {
        
        _focusView = [CALayer layer];
        //设置需要显示的图片
        _focusView.contents=(id)[UIImage imageNamed:@"1x_focus"].CGImage;
        
        [self.ruleBottomView.layer  addSublayer:_focusView];
    }
    return _focusView;
}

- (CALayer *)zoomView
{
    if (!_zoomView) {
        
        _zoomView = [CALayer layer];
        _zoomView.contents=(id)[UIImage imageNamed:@"home_dz_rule_icon"].CGImage;
        _zoomView.hidden = YES;
        
        [self.ruleBottomView.layer  addSublayer:_zoomView];
    }
    return _zoomView;
}

#pragma mark -------------------------> UITableViewDelegate、UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fpsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"test";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor yellowColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    }
    JYFormats *format = self.fpsArray[indexPath.row];
    cell.textLabel.text = format.fpsStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JYFormats *format = self.fpsArray[indexPath.row];
    [self.myContentView contenViewSetDirectionBtnTitle:format.fpsStr andTag:88];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.videoCamera videoCameraFormatWithDesiredFPS:self.fpsArray[indexPath.row]];
    });
    
    self.fpsView.hidden = YES;
    self.myContentView.scrollView.hidden = NO;
}

- (void)viewWillLayoutSubviews
{
    CGFloat magin = 10;
    self.grladView.frame = self.view.bounds;
    self.subView.frame = self.view.bounds;
    
    CGFloat ruleW = 50;
    
    self.ruleBottomView.frame = CGRectMake(screenW - ruleW, 0, ruleW, screenH);
    self.layer.frame = CGRectMake(0, (screenH - 30) * 0.5, ruleW, 30);
    
    self.focusView.frame = CGRectMake(0, 0, ruleW, screenH);
    self.zoomView.frame = CGRectMake(0, -SHOW_Y, ruleW, screenH);
    
    // 3.设置录像、拍照按钮的View
    CGFloat videoW = 60;
    self.videoView.frame = CGRectMake(screenW - self.ruleBottomView.width - videoW, 0, videoW, screenH);
    
    // 4.录像时间显示
    CGFloat videoTimeW = (screenW != 480) ? 95 : 75;
    CGFloat videoTimeH = 30;
    CGFloat videoTimeX = (screenW - videoTimeW) * 0.5;
    CGFloat videoTimeY = JYSpaceWidth;
    
    self.videoTimeView.frame = CGRectMake(videoTimeX, videoTimeY, videoTimeW, videoTimeH);
    
    CGFloat infoW = 150;
    self.infoView.frame = CGRectMake(screenW - ruleW - infoW, magin, infoW, 30);
    
    // 5.左上角的View  -- 设置和快捷键
    self.leftTopView.frame = CGRectMake(0, 0, 120, 55);
    
    // 5.设置的内容视图
    CGFloat contentX = 70;
    CGFloat contentY = self.leftTopView.height;
    CGFloat contentW = self.videoView.x - 90;
    CGFloat contentH = screenH - contentY - magin;
    
    self.myContentView.frame = CGRectMake(contentX, contentY, contentW, contentH);
    
//    self.sliderImageView.frame = CGRectMake(self.myContentView.x, screenH - 50, self.myContentView.width, 30);
    
    self.coreBlueView.frame = CGRectMake(self.myContentView.x + 10, screenH - self.myContentView.height + 60, self.myContentView.width - 20, self.myContentView.height - 60);
    
    self.logView.frame = CGRectMake(0, screenH - 60, screenW - 100, 60);
    
    self.fpsView.frame = self.coreBlueView.frame;
    
    CGFloat bottomWH = 200;
    CGFloat bottomX = (screenW - bottomWH) * 0.5;
    CGFloat bottomY = (screenH - bottomWH) * 0.5;
    
    self.bottomPreview.frame = CGRectMake(bottomX, bottomY, bottomWH, bottomWH);
    self.bottomPreview.layer.cornerRadius = bottomWH * 0.5;
    
    self.collectionView.frame = CGRectMake(self.myContentView.x, screenH - 50, self.myContentView.width, 40);
    
    self.exposureView.frame = self.subView.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView *)subView
{
    if (!_subView) {
        
        _subView = [[UIView alloc] init];
//        _subView.backgroundColor = [UIColor cyanColor];
        
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOnClick:)];
//        tapGesture.delegate = self;
//        [self.view addGestureRecognizer:tapGesture];
        
        [self.view addSubview:_subView];
    }
    return _subView;
}

- (void)tapGestureOnClick:(UITapGestureRecognizer *)tap
{
    CGPoint tapPoint = [tap locationInView:self.subView];
    if (tapPoint.x <= self.myContentView.x || tapPoint.x >= self.myContentView.x + self.myContentView.width || tapPoint.y <= self.myContentView.y) {
        
        if (self.coreBlueView.hidden == NO) {
            self.coreBlueView.hidden = YES;
            self.myContentView.scrollView.hidden = NO;
        } else{
            self.myContentView.hidden = YES;
            self.leftTopView.settingHiden = NO;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//     若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [JYSaveVideoData sharedManager].photosArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < [JYSaveVideoData sharedManager].photosArray.count)
        return [[JYSaveVideoData sharedManager].photosArray objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < [JYSaveVideoData sharedManager].thumbsArray.count)
        return [[JYSaveVideoData sharedManager].thumbsArray objectAtIndex:index];
    return nil;
}

#pragma mark KVO and Notifications
- (void)addObservers
{
//    // 1.监听会话是否开启
//    [self.videoCamera.videoCamera.captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
//    
//    // 实时监听白平衡的变化
//    [self.videoCamera.videoCamera.inputCamera addObserver:self forKeyPath:@"deviceWhiteBalanceGains" options:NSKeyValueObservingOptionNew context:DeviceWhiteBalanceGains];
//    
//    // 实时监听曝光偏移的变化exposureTargetOffset
//    [self.videoCamera.videoCamera.inputCamera addObserver:self forKeyPath:@"exposureTargetOffset" options:NSKeyValueObservingOptionNew context:DeviceExposureOffset];
//    
//    // 实时监听感光度的变化
//    [self.videoCamera.videoCamera.inputCamera addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:DeviceExposureISO];
//    
//    // 实时监听曝光时间的变化
//    [self.videoCamera.videoCamera.inputCamera addObserver:self forKeyPath:@"exposureDuration" options:NSKeyValueObservingOptionNew context:DeviceExposureDuration];
//    
//    [self.videoCamera addObserver:self forKeyPath:@"videoSize" options:NSKeyValueObservingOptionNew context:VideoSize];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.videoCamera.videoCamera.captureSession];
//    
//    [self.videoCamera addObserver:self forKeyPath:@"zoomVideo" options:NSKeyValueObservingOptionNew context:zoomVideo];
    
    [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"temperatureAndTintValues" options:NSKeyValueObservingOptionNew context:DeviceWhiteBalanceGains];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreDefaults) name:@"RestoreDefaults" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    
    [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"versionDict" options:NSKeyValueObservingOptionNew context:AppStoreVersion];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[JYSeptManager sharedManager] removeObserver:self forKeyPath:@"temperatureAndTintValues" context:DeviceWhiteBalanceGains];
    
    [[JYSeptManager sharedManager] removeObserver:self forKeyPath:@"versionDict" context:AppStoreVersion];
}

- (void)sessionRuntimeError:(NSNotification *)notification
{
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog( @"Capture session runtime error: %@", error );
    
    // Automatically try to restart the session running if media services were reset and the last start running succeeded.
    // Otherwise, enable the user to try to resume the session running.
//    if ( error.code == AVErrorMediaServicesWereReset ) {
//        dispatch_async( self.sessionQueue, ^{
//            if ( self.videoCamera.videoCamera.isSessionRunning ) {
//                [self.videoCamera.captureSession startRunning];
//                self.videoCamera.sessionRunning = self.videoCamera.captureSession.isRunning;
//            }
//        } );
//    }
}

#pragma KVO监听事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //    id oldValue = change[NSKeyValueChangeOldKey];
//    id newValue = change[NSKeyValueChangeNewKey];
//    
//    if (context == DeviceWhiteBalanceGains) {  // 白平衡
//        if (self.tempAuto == 0 && self.tintAuto == 0) {
//            AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTintValues = [self.videoCamera.videoCamera.inputCamera temperatureAndTintValuesForDeviceWhiteBalanceGains:self.videoCamera.videoCamera.inputCamera.deviceWhiteBalanceGains];
//            self.tint = temperatureAndTintValues.tint;
//            self.temp = temperatureAndTintValues.temperature;
//            [self.myContentView contentViewSetCustomSliderValue:temperatureAndTintValues.temperature andCustomSliderTag:50 classType:1];
//            [self.myContentView contentViewSetCustomSliderValue:temperatureAndTintValues.tint andCustomSliderTag:51 classType:1];
//        }
//        else if ( newValue && newValue != [NSNull null] ) {
//            AVCaptureWhiteBalanceGains newGains;
//            [newValue getValue:&newGains];
//            AVCaptureWhiteBalanceTemperatureAndTintValues newTemperatureAndTint = [self.videoCamera.videoCamera.inputCamera temperatureAndTintValuesForDeviceWhiteBalanceGains:newGains];
//            
//            if (self.videoCamera.videoCamera.inputCamera.whiteBalanceMode != AVCaptureExposureModeLocked ) {
//                [self.myContentView contentViewSetCustomSliderValue:newTemperatureAndTint.temperature andCustomSliderTag:50 classType:1];
//                [self.myContentView contentViewSetCustomSliderValue:newTemperatureAndTint.tint andCustomSliderTag:51 classType:1];
//            }
//        }
//    }
//    else if (context == DeviceExposureISO) {   // 感光度
//        if (self.isoAuto == 0) {
//            //            self.f_iso = videoCamera.inputCamera.ISO;
//            [self.myContentView contentViewSetCustomSliderValue:self.videoCamera.videoCamera.inputCamera.ISO andCustomSliderTag:61 classType:0];
//        }
//    }
//    else if (context == DeviceExposureOffset) {   // 曝光偏移
//        [self.myContentView contentViewSetCustomSliderValue:self.videoCamera.videoCamera.inputCamera.exposureTargetOffset andCustomSliderTag:60 classType:0];
//    }
//    else if (context == DeviceExposureDuration) {   // 曝光时间
//        
//        if ( newValue && newValue != [NSNull null] ) {
//            double newDurationSeconds = CMTimeGetSeconds( [newValue CMTimeValue] );
//            if (self.videoCamera.videoCamera.inputCamera.exposureMode != AVCaptureExposureModeCustom ) {
//                double minDurationSeconds = MAX( CMTimeGetSeconds(self.videoCamera.videoCamera.inputCamera.activeFormat.minExposureDuration ), kExposureMinimumDuration );
//                double maxDurationSeconds = CMTimeGetSeconds(self.videoCamera.videoCamera.inputCamera.activeFormat.maxExposureDuration );
//                // Map from duration to non-linear UI range 0-1
//                double p = ( newDurationSeconds - minDurationSeconds ) / ( maxDurationSeconds - minDurationSeconds ); // Scale to 0-1
//                [self.myContentView contentViewSetCustomSliderValue:pow( p, 1 / kExposureDurationPower ) andCustomSliderTag:62 classType:0];
//            }
//        }
//    } else if (context == VideoSize) {
//        self.fpsArray = [self getFpsAtNowResolution];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.fpsView reloadData];
//        });
////        NSLog(@"self.fpsArray = %@", self.fpsArray);
//    } else if (context == zoomVideo) {
////        CGFloat value  = log(self.videoCamera.zoomVideo) / log([self.videoCamera getMaxZoom]);
////        NSLog(@"%f", SHOW_Y - (0.5 - value) * (screenH - 30));
////        [self animationWith:(0.5 - value) * (screenH - 30) layer:self.zoomView];
//    } else if (context == SessionRunningContext) {
//        //        NSLog(@"%f", self.videoCamera.zoomVideo);
//    }
    if (context == DeviceWhiteBalanceGains) {
        self.tint = [JYSeptManager sharedManager].temperatureAndTintValues.tint;
        self.temp = [JYSeptManager sharedManager].temperatureAndTintValues.temperature;
    } else if (context == VideoCameraWidth)
    {
        self.fpsArray = [self getFpsAtNowResolution];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fpsView reloadData];
        });
    } else if (context == AppStoreVersion)
    {
        // app版本
        //此获取的版本号对应version，打印出来对应为1.2.3.4.5这样的字符串
        NSString *string = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        //    [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]]
        
        if ([string isEqualToString:[JYSeptManager sharedManager].versionDict[@"version"]]) {
            NSLog(@"xiangtong");
        } else {
            UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"发现新版本" message:@"内容更丰富，体验效果更美好，还不快去更新！" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertAction *update = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:@"https://appsto.re/us/mNeHcb.i"];
                [[UIApplication sharedApplication]openURL:url];
            }];
            
            [alertCtl addAction:cancle];
            [alertCtl addAction:update];
            
            [self presentViewController:alertCtl animated:YES completion:nil];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (JYInfoLogView *)logView
{
    if (!_logView) {
        
        _logView = [[JYInfoLogView alloc] init];
        _logView.hidden = YES;
        
        [self.subView addSubview:_logView];
    }
    return _logView;
}

- (UIImageView *)exposureView
{
    if (!_exposureView) {
        
        _exposureView = [[UIImageView alloc] init];
        _exposureView.hidden = YES;
        _exposureView.alpha = 0.5;
        
        [self.subView insertSubview:_exposureView aboveSubview:self.grladView];
    }
    return _exposureView;
}

@end
