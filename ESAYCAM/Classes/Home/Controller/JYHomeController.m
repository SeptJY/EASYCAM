//
//  JYHomeController.m
//  ESAYCAM
//
//  Created by Sept on 16/4/22.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYHomeController.h"
#import "JYCameraManager.h"
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

static const float kExposureMinimumDuration = 1.0/1000;
static const float kExposureDurationPower = 5;

@interface JYHomeController () <JYCameraManagerDelegate, JYVideoViewDelegate, JYLeftTopViewDelegate, MWPhotoBrowserDelegate, DWBubbleMenuViewDelegate, JYSliderImageViewDelegate, JYContentViewDelegate, JYBlueManagerDelegate, JYCoreBlueViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIView *subView;
@property (strong, nonatomic) JYCameraManager *videoCamera;
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

@end

@implementation JYHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL);
    self.navigationController.navigationBarHidden = YES;
    
    self.connectSucces = NSLocalizedString(@"连接成功", nil);
    self.disConnect = NSLocalizedString(@"连接中断", nil);
    self.nowSace = NSLocalizedString(@"正在保存...", nil);
    
    self.altTitle = NSLocalizedString(@"参数重置", nil);
    self.altMesage = NSLocalizedString(@"所有设置将全部恢复为默认设置", nil);
    self.altSure = NSLocalizedString(@"是", nil);
    self.altCancel = NSLocalizedString(@"否", nil);
    
    self.sizeTitle = NSLocalizedString(@"温馨提示", nil);
    self.sizeMesage = NSLocalizedString(@"您好，当前设备不支持3840x2160", nil);
    self.sizeOk = NSLocalizedString(@"好的", nil);
    
    self.lensMesage = NSLocalizedString(@"是否安装了其他镜头", nil);
    
    self.direction = NSLocalizedString(@"蓝牙设备未连接", nil);
    
    self.changeName = NSLocalizedString(@"修改名称", nil);
    self.nameMsg = NSLocalizedString(@"请输入你要修改的名字, 不支持中文名字", nil);
    self.nameplace = NSLocalizedString(@"修改名称", nil);

    
    [self homeOfFirstConnectPeripheral];
    [self.blueManager findBLKAppPeripherals:0];
    
    [NSTimer scheduledTimerWithTimeInterval:20.0/1000 target:self selector:@selector(ruleImgViewTimer) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreDefaults) name:@"RestoreDefaults" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    
    [self addObservers];
    
    [self getFpsAtNowResolution];
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
}

- (void)changeLanguage
{
    self.connectSucces = [[JYLanguageTool bundle] localizedStringForKey:@"连接成功" value:nil table:@"Localizable"];
    self.disConnect = [[JYLanguageTool bundle] localizedStringForKey:@"蓝牙连接中断" value:nil table:@"Localizable"];
    self.nowSace = [[JYLanguageTool bundle] localizedStringForKey:@"正在保存..." value:nil table:@"Localizable"];
    
    self.altTitle = [[JYLanguageTool bundle] localizedStringForKey:@"参数重置" value:nil table:@"Localizable"];
    self.altMesage = [[JYLanguageTool bundle] localizedStringForKey:@"所有设置将全部恢复为默认设置" value:nil table:@"Localizable"];
    self.altSure = [[JYLanguageTool bundle] localizedStringForKey:@"是" value:nil table:@"Localizable"];
    self.altCancel = [[JYLanguageTool bundle] localizedStringForKey:@"否" value:nil table:@"Localizable"];
    
    self.sizeTitle = [[JYLanguageTool bundle] localizedStringForKey:@"温馨提示" value:nil table:@"Localizable"];
    self.sizeMesage = [[JYLanguageTool bundle] localizedStringForKey:@"您好，当前设备不支持3840x2160" value:nil table:@"Localizable"];
    self.sizeOk = [[JYLanguageTool bundle] localizedStringForKey:@"好的" value:nil table:@"Localizable"];
    
    self.lensMesage = [[JYLanguageTool bundle] localizedStringForKey:@"是否安装了其他镜头" value:nil table:@"Localizable"];
    
    self.direction = [[JYLanguageTool bundle] localizedStringForKey:@"蓝牙设备未连接" value:nil table:@"Localizable"];
}

#pragma mark -------------------------> 相机操作
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.videoCamera startCamera];
    [self.subView addSubview:self.menuBtn];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.videoCamera stopCamera];
}

- (JYCameraManager *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[JYCameraManager alloc] initWithFrame:self.view.bounds superview:self.view];
        _videoCamera.cameraDelegate = self;
        [_videoCamera flashModel:AVCaptureFlashModeAuto];
        [self.bottomPreview addSubview:_videoCamera.subPreview];
    }
    return _videoCamera;
}

- (void)cameraManagerRecodingSuccess:(NSURL *)url
{
    [SVProgressHUD dismiss];
    
    self.videoView.imgUrl = url;
}

- (void)cameraManageTakingPhotoSucuess:(NSData *)data
{
    self.videoView.imageData = data;
}

#pragma mark ------------------------->JYBlueManagerDelegate 蓝牙管理者和蓝牙界面显示
- (void)blueManagerToTableViewReloadData
{
    // 1.判断当前连接蓝牙是否为空 --- 为空的话就去解挡
    if (self.blueManager.connectPeripheral == nil) {
        
        // 2.解挡遍历保存的蓝牙数据
        [[NSKeyedUnarchiver unarchiveObjectWithFile:path_encode] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
//                        NSLog(@"解挡数组  %@", [NSKeyedUnarchiver unarchiveObjectWithFile:path_encode]);
            
            JYPeripheral *codePer = obj;
            NSLog(@"codePer = %@", codePer.identifier);
//            NSLog(@"%@", self.blueManager.peripherals);
            // 3.遍历蓝牙数据中的数据
            for (CBPeripheral *isPer in self.blueManager.peripherals) {
                JYPeripheral *mPer = [[JYPeripheral alloc] initWithPeripheral:isPer];
                                NSLog(@"蓝牙数组中 %@", mPer.identifier);
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
    if (self.leftTopView.imgHidden == NO) {
        self.videoView.isVideo = NO;
        
        [self.videoCamera startVideo];
        [self.videoTimeView startTimer];
        self.leftTopView.imgHidden = YES;
    }
}

- (void)stopVideoing
{
    [self.videoTimeView stopTimer];
    [self.videoCamera stopVideo];
    self.leftTopView.imgHidden = NO;
//    [SVProgressHUD showWithStatus:self.nowSace];
}

/** 蓝牙发送的指令和查询指令 */
- (void)blueManagerOthersCommandWith:(NSInteger)num
{
    switch (num) {
        case 201:   // 拍照
            [self startPhoto];
            break;
        case 301:   // 录像开始
            
            [self takeVideoing];
            if (self.useModel == CoreBlueUseModelRepeatRecording) {
                [self.videoView startResetVideoing];
            }
            self.videoView.btnSeleted = YES;
            break;
        case 302:   // 录像停止
            [self stopVideoing];
            if (self.useModel == CoreBlueUseModelRepeatRecording) {
                [self.videoView stopResetVideoing];
            }
            self.videoView.btnSeleted = NO;
            
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
//            if (self.zoomView.y <= -SHOW_Y) {
//                self.zoomView.y = -SHOW_Y;
//            }
            [self.blueManager blueToolWriteValue:[NSString stringWithFormat:@"a051%db", (int)(20000 + self.zoomNum / (screenH - 30) * 1000)]];
            break;
        case 601:   // 重复录制开始
            self.useModel = CoreBlueUseModelRepeatRecording;
            break;
        case 602:   // 重复录制结束
            self.focusView.hidden = NO;
            self.zoomView.hidden = YES;
            self.useModel = CoreBlueUseModelFocus;
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
                self.videoView.isVideo = NO;
                
                [self.menuBtn menuButtonSeleted:NO andTag:100];
//                [self.menuBtn menuButtonsetImg:@"home_photo_icon" andTag:102];
//                [self.menuBtn menuButtonSeleted:YES andTag:101];
            }
            else if (self.useModel == CoreBlueUseModelDurationAndFucus)  // 当前在快门时间模式时 界面 -1的话  就是处于ZOOM模式
            {
                if (self.videoTimeView.hidden == YES) {
                    self.useModel = CoreBlueUseModelDurationAndZoom;
                    self.zoomView.hidden = NO;
                    self.focusView.hidden = YES;
//                    self.sliderImageView.hidden = NO;
                    self.videoView.isVideo = YES;
//                    [self.menuBtn menuButtonsetImg:@"home_photo_tv_click_icon" andTag:102];
//                    self.imgModel = JYPhotoImgTVPhtoto;
//                    [self.menuBtn menuButtonSeleted:NO andTag:101];
//                    
                    [self.menuBtn menuButtonSeleted:NO andTag:100];
                }
            } else if (self.useModel == CoreBlueUseModelDurationAndZoom)  // 当前在快门时间模式时 界面 -1的话  就是处于ZOOM模式
            {
                if (self.videoTimeView.hidden == YES) {
                    self.useModel = CoreBlueUseModelFocus;
                    self.focusView.hidden = NO;
                    self.zoomView.hidden = YES;
//                    self.sliderImageView.hidden = YES;
                    self.videoView.isVideo = NO;
                    
                    [self.menuBtn menuButtonSeleted:YES andTag:100];
//                    [self.menuBtn menuButtonsetImg:@"home_photo_icon" andTag:102];
//                    [self.menuBtn menuButtonSeleted:YES andTag:101];
                }
            }
            break;
        case CoreBlueTypeMinus:
            //             当前在调焦模式和ZOOM模式时 界面 -1的话 就是处于调焦模式
            if (self.useModel == CoreBlueUseModelDurationAndZoom || self.useModel == CoreBlueUseModelDurationAndFucus)
            {
                if (self.videoTimeView.hidden == YES) {
                    self.useModel = CoreBlueUseModelDurationAndFucus;
                    self.zoomView.hidden = YES;
                    self.focusView.hidden = NO;
//                    self.sliderImageView.hidden = NO;
                    self.videoView.isVideo = YES;
//                    [self.menuBtn menuButtonsetImg:@"home_photo_tv_click_icon" andTag:102];
//                    self.imgModel = JYPhotoImgTVPhtoto;
//                    [self.menuBtn menuButtonSeleted:NO andTag:101];
//                    
                    [self.menuBtn menuButtonSeleted:YES andTag:100];
                }
            } else if (self.useModel == CoreBlueUseModelFocus)  // 当前在快门时间模式和ZOOM时 界面 -1的话  就是处于快门时间模式
            {
                if (self.videoTimeView.hidden == YES) {
                    self.useModel = CoreBlueUseModelDurationAndZoom;
                    self.zoomView.hidden = NO;
                    self.focusView.hidden = YES;
//                    self.sliderImageView.hidden = NO;
                    self.videoView.isVideo = YES;
//                    [self.menuBtn menuButtonsetImg:@"home_photo_tv_click_icon" andTag:102];
//                    self.imgModel = JYPhotoImgTVPhtoto;
//                    [self.menuBtn menuButtonSeleted:NO andTag:101];
//                    
                    [self.menuBtn menuButtonSeleted:NO andTag:100];
                }
            } else if (self.useModel == CoreBlueUseModelZOOM)  // 当前在快门时间模式和ZOOM时 界面 -1的话  就是处于快门时间模式
            {
                self.useModel = CoreBlueUseModelFocus;
                self.zoomView.hidden = YES;
                self.focusView.hidden = NO;
//                self.sliderImageView.hidden = YES;
                self.videoView.isVideo = NO;
                
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

/** 获取当前分辨率下所支持的fps */
- (NSMutableArray *)getFpsAtNowResolution
{
    NSMutableArray *fpsArr = [NSMutableArray array];
    for (AVCaptureDeviceFormat *format in [self.videoCamera.inputCamera formats]) {
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
        
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
//            NSLog(@"width = %d", width);
            if (width == (int)self.videoCamera.videoSize.width) {
//                NSLog(@"%f", range.maxFrameRate);
                [fpsArr addObject:[NSString stringWithFormat:@"%.f", range.maxFrameRate]];
            }
        }
    }
    
    // 1.去掉重复的元素
    NSArray *mArray = [[NSMutableSet setWithArray:fpsArr] allObjects];
    // 2.通过不可变数组转换成可变数据
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:mArray];
    // 3.冒泡排序（从小到大）
    for (int i = 0; i < mArr.count - 1; i ++) {
        for (int j = 0; j < mArr.count -1 - i; j ++) {
            if ([mArr[j] intValue] > [mArr[j + 1] intValue]) {
                NSString *temp = mArr[j];
                mArr[j] = mArr[j + 1];
                mArr[j + 1] = temp;
            }
        }
    }
    return mArr;
}

/** 九宫格 */
- (UIImageView *)grladView
{
    if (!_grladView) {
        _grladView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_grid_icon"]];
        _grladView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"grladView_hidden"];
        _grladView.alpha = 0.3;
        
        [self.view insertSubview:_grladView belowSubview:self.subView];
    }
    return _grladView;
}

/** 局部放大的背景View */
- (UIView *)bottomPreview
{
    if (!_bottomPreview) {
        
        CGFloat bottomWH = 200;
        CGFloat bottomX = (screenW - bottomWH) * 0.5;
        CGFloat bottomY = (screenH - bottomWH) * 0.5;
        
        _bottomPreview = [[UIView alloc] initWithFrame:CGRectMake(bottomX, bottomY, bottomWH, bottomWH)];
        _bottomPreview.hidden = YES;
        _bottomPreview.clipsToBounds = YES;
        _bottomPreview.layer.cornerRadius = bottomWH * 0.5;
        _bottomPreview.backgroundColor = [UIColor yellowColor];
        
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
            [JYSeptManager sharedManager].perName = self.blueManager.connectPeripheral.name;
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
                [self.videoCamera cameraManagerChangeFoucus:(1 - (-self.focusNum + SHOW_Y) / (screenH - 30))];
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
                [self.videoCamera cameraManagerVideoZoom:(-self.zoomNum + SHOW_Y) / (screenH - 30)];
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

- (void)timerClickView:(CALayer *)clickView type:(NSInteger)type translation:(CGFloat)y
{
    if (self.saveNum != y) {
        
        [self animationWith:y layer:clickView];
        
        if (type == 0) {
            dispatch_async(self.sessionQueue, ^{
                [self.videoCamera cameraManagerVideoZoom:(-y + SHOW_Y) / (screenH - 30)];
            });
            
        }else
        {
//            dispatch_async(self.sessionQueue, ^{
                self.logView.myText.text = [NSString stringWithFormat:@"%f", (0.5 - (-y + SHOW_Y) / (screenH - 30))];
                // 2.1 30是showView的高度   -- 调节微距
                
                    [self.videoCamera cameraManagerChangeFoucus:(1 - (-y + SHOW_Y) / (screenH - 30))];
                
                // 2.2显示放大的View和sliderView
                if (self.enlargeBtn.selected == YES) {
                    self.bottomPreview.hidden = NO;
                    self.timeNum = 50;
                }
//            });
        
        }
        self.saveNum = y;
    }
    self.logView.camereText.text = [NSString stringWithFormat:@"%f", self.videoCamera.inputCamera.lensPosition];
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
            self.coreBlueView.peripherals = self.blueManager.peripherals;
            
            self.myContentView.scrollView.hidden = YES;
            self.coreBlueView.hidden = NO;
            
            [self.coreBlueView.tableView reloadData];
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
            break;
        case 41:    // 九宫格
            self.grladView.hidden = !mSwitch.on;
            // 保存设置
            [[NSUserDefaults standardUserDefaults] setBool:mSwitch.on forKey:@"grladView_hidden"];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
    //     提示用户仅支持iphone6及其以上设备
    if (screenW != 480) {
        [self.videoCamera cameraManagerEffectqualityWithTag:btn.tag withBlock:^(BOOL isCan) {
            if(!isCan)
            {
                [self alertController];
            }
        }];
    }
    switch (btn.tag) {
        case 60:
            self.videoCamera.videoSize = CGSizeMake(640.0, 480.0);
            break;
        case 61:
            self.videoCamera.videoSize = CGSizeMake(1280.0, 720.0);
            break;
        case 62:
            self.videoCamera.videoSize = CGSizeMake(1920.0, 1080.0);
            break;
        case 63:
            if (screenW != 480) {    // iPhone6 及以上设备
                
                self.videoCamera.videoSize = CGSizeMake(3840.0, 2160.0);
            } else {
                [self alertController];
            }
            break;
        default:
            break;
    }
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
            self.logView.tempText.text = [NSString stringWithFormat:@"%f", self.temp];
            AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
                .temperature = self.temp,
                .tint = self.tint,
            };
            [self.videoCamera cameraManagerSetWhiteBalanceGains:[self.videoCamera.inputCamera deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
        }
            break;
        case 51:     // 色调
        {
            self.tint = slider.value;
            self.logView.tintText.text = [NSString stringWithFormat:@"%f", self.tint];
            AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
                .temperature = self.temp,
                .tint = self.tint,
            };
            [self.videoCamera cameraManagerSetWhiteBalanceGains:[self.videoCamera.inputCamera deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
        }
            break;
        case 52:     // 饱和度
            [self.videoCamera.filter setSaturation:[(UISlider *)slider value]];
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
            if (self.tintAuto == 0 && self.tempAuto == 0) {   // 如果色调当前处于手动状态
                [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            } else
            {
                [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
            }
            
            break;
        case 31:    // 色调
            self.tintAuto = !btn.selected;
            if (self.tintAuto == 0 && self.tempAuto == 0) {   // 如果色调当前处于手动状态
                [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            } else
            {
                [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
            }
            break;
        case 32:    // 色调
            [self.videoCamera.filter setSaturation:1.0];
            break;
            
        default:
            break;
    }
}

/** 天气滤镜 */
- (void)contentViewWetherButtonOnClick:(UIButton *)btn
{
    self.tintAuto = YES;
    self.tempAuto = YES;
    
    [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
    
    switch (btn.tag) {
        case 80:      // 荧光
            [self.videoCamera cameraManagerBalanceGainsWithTemp:4200.0 andTint:81.0];
            break;
        case 81:      // 灯泡
            [self.videoCamera cameraManagerBalanceGainsWithTemp:3400.0 andTint:25.0];
            break;
        case 82:      // 晴天
            [self.videoCamera cameraManagerBalanceGainsWithTemp:5000.0 andTint:0.0];
            break;
        case 83:      // 阴天
            [self.videoCamera cameraManagerBalanceGainsWithTemp:4886.0 andTint:52.0];
            break;
        case 84:      // 蓝天
            [self.videoCamera whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            break;
        default:
            break;
    }
}

- (void)contentViewExpsureCustomSliderValueChange:(UISlider *)slider
{
    switch (slider.tag) {
        case 61:     // 感光度
            [self.videoCamera cameraManagerExposureIOS:slider.value];
            break;
        case 62:     // 曝光时间
        {
            [self.videoCamera setExposureDurationWith:slider.value withBlock:nil];
        }
            break;
        case 63:     // 曝光补偿
            [self.videoCamera cameraManagerWithExposure:slider.value];
            break;
        default:
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
            break;;
            
        default:
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
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:self.sizeTitle message:@"是否安装了其他镜头" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:self.altSure style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        switch (btn.tag) {
            case 80:      // 默认
                self.infoView.dzText = @"x1";
                self.blueManager.managerLens = JYBlueManagerLensOne;
                self.focusView.contents=(id)[UIImage imageNamed:@"1x_focus"].CGImage;
                break;
            case 81:      // 2倍增距镜
                self.infoView.dzText = @"x2";
                self.blueManager.managerLens = JYBlueManagerLensTwo;
                self.focusView.contents=(id)[UIImage imageNamed:@"2x_focus"].CGImage;
                break;
            case 82:      // 3倍增距镜
                self.infoView.dzText = @"x3";
                self.blueManager.managerLens = JYBlueManagerLensThree;
                break;
                
            default:
                break;
        }
    }];
    
    [alertCtl addAction:okAction];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:self.altCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.myContentView contenViewCameraLensViewShowOneCell];
        self.infoView.dzText = @"x1";
        
        [self.myContentView contenViewSetDirectionBtnTitle:@"无镜头" andTag:85];
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
        // 选中成功则显示当前选中的名称
        [self.myContentView contenViewSetDirectionBtnTitle:btn.currentTitle andTag:84];
    }else {
        [self resetVideoAndHandwheelAlert];
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
            
            if (btn.selected) {
                [self takeVideoing];
            } else
            {
                [self stopVideoing];
            }
            
            break;
        case 22:    // 拍照
            [self startPhoto];
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
            self.logView.hidden = !self.logView.hidden;
            break;
    }
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
    [self.videoCamera takePhoto];
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
            } else if (self.fpsView.hidden == NO) {
                self.myContentView.isHidden = NO;
                self.fpsView.hidden = YES;
            } else {
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
    self.leftTopView.isShow = YES;
}

/** 按钮掩藏之后 */
- (void)bubbleMenuButtonDidCollapse:(DWBubbleMenuButton *)expandableView
{
    //    NSLog(@"%s", __func__);
    self.leftTopView.isShow = NO;
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
            self.videoView.isVideo = btn.selected;
            self.myContentView.switchEnlenble = btn.selected;
        }
            break;
        case 102:    // 局部放大功能
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
        
        _menuBtn.homeButtonView = self.leftTopView.label;
        
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
    }
    return _phtotBtn;
}

- (UIButton *)enlargeBtn
{
    if (!_enlargeBtn) {
        
        _enlargeBtn = [self createBtnWithImg:@"Zoom_in_on" seletedImg:@"Zoom_in_off" size:CGSizeMake(35.0f, 60.0f)];
        _enlargeBtn.tag = 102;
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
    
    return [buttonsMutable copy];
}

//#pragma mark -------------------------> JYSliderImageViewDelegate
//- (void)sliderImageViewValueChange:(UISlider *)sender
//{
//    __weak JYHomeController *WeakSelf = self;
//    [self.videoCamera setExposureDurationWith:sender.value withBlock:^(NSString *text) {
//        WeakSelf.sliderImageView.label.text = text;
//    }];
//}
//
///** sliderImageView */
//- (JYSliderImageView *)sliderImageView
//{
//    if (!_sliderImageView) {
//        
//        _sliderImageView = [[JYSliderImageView alloc] init];
//        _sliderImageView.hidden = YES;
//        _sliderImageView.delegate = self;
//        
//        [self.subView addSubview:_sliderImageView];
//    }
//    return _sliderImageView;
//}

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

#pragma mark -------------------------> UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    NSLog(@"%@", self.perArrays);
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
    cell.textLabel.text = self.fpsArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat desiredFps = [self.fpsArray[indexPath.row] floatValue];
    [self.myContentView contenViewSetDirectionBtnTitle:self.fpsArray[indexPath.row] andTag:88];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        if (desiredFps > 0.0) {
            [self.videoCamera switchFormatWithDesiredFPS:desiredFps];
//            self.videoCamera.frameRate = 240;
        }
        else {
            [self.videoCamera resetFormat];
        }
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
    CGFloat videoTimeW = (screenH >= 375) ? 130 : 110;
    CGFloat videoTimeH = 30;
    CGFloat videoTimeX = (screenW - videoTimeW) * 0.5;
    CGFloat videoTimeY = JYSpaceWidth;
    
    self.videoTimeView.frame = CGRectMake(videoTimeX, videoTimeY, videoTimeW, videoTimeH);
    
    CGFloat infoW = 170;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView *)subView
{
    if (!_subView) {
        
        _subView = [[UIView alloc] init];
//        _subView.backgroundColor = [UIColor cyanColor];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOnClick:)];
        tapGesture.delegate = self;
        [self.view addGestureRecognizer:tapGesture];
        
        [self.view addSubview:_subView];
    }
    return _subView;
}

- (void)tapGestureOnClick:(UITapGestureRecognizer *)tap
{
    CGPoint tapPoint = [tap locationInView:self.subView];
    if (tapPoint.x <= self.myContentView.x || tapPoint.x >= self.myContentView.x + self.myContentView.width || tapPoint.y <= self.myContentView.y || tapPoint.y >= self.myContentView.y + self.myContentView.height) {
        
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
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
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
    // 实时监听白平衡的变化
    [self.videoCamera.inputCamera addObserver:self forKeyPath:@"deviceWhiteBalanceGains" options:NSKeyValueObservingOptionNew context:DeviceWhiteBalanceGains];
    
    // 实时监听曝光偏移的变化exposureTargetOffset
    [self.videoCamera.inputCamera addObserver:self forKeyPath:@"exposureTargetOffset" options:NSKeyValueObservingOptionNew context:DeviceExposureOffset];
    
    // 实时监听感光度的变化
    [self.videoCamera.inputCamera addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:DeviceExposureISO];
    
    // 实时监听曝光时间的变化
    [self.videoCamera.inputCamera addObserver:self forKeyPath:@"exposureDuration" options:NSKeyValueObservingOptionNew context:DeviceExposureDuration];
    
    [self.videoCamera addObserver:self forKeyPath:@"videoSize" options:NSKeyValueObservingOptionNew context:VideoSize];
}

#pragma KVO监听事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //    id oldValue = change[NSKeyValueChangeOldKey];
    id newValue = change[NSKeyValueChangeNewKey];
    
    if (context == DeviceWhiteBalanceGains) {  // 白平衡
        if (self.tempAuto == 0 && self.tintAuto == 0) {
            AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTintValues = [self.videoCamera.inputCamera temperatureAndTintValuesForDeviceWhiteBalanceGains:self.videoCamera.inputCamera.deviceWhiteBalanceGains];
            self.tint = temperatureAndTintValues.tint;
            self.temp = temperatureAndTintValues.temperature;
            [self.myContentView contentViewSetCustomSliderValue:temperatureAndTintValues.temperature andCustomSliderTag:50 classType:1];
            [self.myContentView contentViewSetCustomSliderValue:temperatureAndTintValues.tint andCustomSliderTag:51 classType:1];
        }
        else if ( newValue && newValue != [NSNull null] ) {
            AVCaptureWhiteBalanceGains newGains;
            [newValue getValue:&newGains];
            AVCaptureWhiteBalanceTemperatureAndTintValues newTemperatureAndTint = [self.videoCamera.inputCamera temperatureAndTintValuesForDeviceWhiteBalanceGains:newGains];
            
            if (self.videoCamera.inputCamera.whiteBalanceMode != AVCaptureExposureModeLocked ) {
                [self.myContentView contentViewSetCustomSliderValue:newTemperatureAndTint.temperature andCustomSliderTag:50 classType:1];
                [self.myContentView contentViewSetCustomSliderValue:newTemperatureAndTint.tint andCustomSliderTag:51 classType:1];
            }
        }
    }
    else if (context == DeviceExposureISO) {   // 感光度
        if (self.isoAuto == 0) {
            //            self.f_iso = videoCamera.inputCamera.ISO;
            [self.myContentView contentViewSetCustomSliderValue:self.videoCamera.inputCamera.ISO andCustomSliderTag:61 classType:0];
        }
    }
    else if (context == DeviceExposureOffset) {   // 曝光偏移
        [self.myContentView contentViewSetCustomSliderValue:self.videoCamera.inputCamera.exposureTargetOffset andCustomSliderTag:60 classType:0];
    }
    else if (context == DeviceExposureDuration) {   // 曝光时间
        
        if ( newValue && newValue != [NSNull null] ) {
            double newDurationSeconds = CMTimeGetSeconds( [newValue CMTimeValue] );
            if (self.videoCamera.inputCamera.exposureMode != AVCaptureExposureModeCustom ) {
                double minDurationSeconds = MAX( CMTimeGetSeconds(self.videoCamera.inputCamera.activeFormat.minExposureDuration ), kExposureMinimumDuration );
                double maxDurationSeconds = CMTimeGetSeconds(self.videoCamera.inputCamera.activeFormat.maxExposureDuration );
                // Map from duration to non-linear UI range 0-1
                double p = ( newDurationSeconds - minDurationSeconds ) / ( maxDurationSeconds - minDurationSeconds ); // Scale to 0-1
                [self.myContentView contentViewSetCustomSliderValue:pow( p, 1 / kExposureDurationPower ) andCustomSliderTag:62 classType:0];
            }
        }
    } else if (context == VideoSize) {
        self.fpsArray = [self getFpsAtNowResolution];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fpsView reloadData];
        });
//        NSLog(@"self.fpsArray = %@", self.fpsArray);
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

@end
