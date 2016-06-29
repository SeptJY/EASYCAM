//
//  TTMCaptureManager.m
//  SlowMotionVideoRecorder
//  https://github.com/shu223/SlowMotionVideoRecorder
//
//  Created by shuichi on 12/17/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "JYVideosCamera.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "JYFormats.h"

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface JYVideosCamera ()
<AVCaptureFileOutputRecordingDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    CMTime defaultVideoMaxFrameDuration;
}

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureDeviceFormat *defaultFormat;
@property (nonatomic, strong) NSURL *fileURL;
//@property (nonatomic, strong) AVCaptureDevice *videoDevice;

@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;

@property (nonatomic, strong) AVCaptureDeviceInput *subDeviceInput;

@property (nonatomic) AVCamSetupResult setupResult;

@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;

// 视频录制标识符
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (strong, nonatomic) UIView *previewView;

@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end


@implementation JYVideosCamera

- (instancetype)initWithPreviewView:(UIView *)previewView withSub:(UIView *)subView
{
    self = [super init];
    
    if (self) {

        [self initCaptureSessionWithPreviewView:previewView subView:subView];;
        
        self.previewView = previewView;
        
        self.videoWidth = 1920;
    }
    return self;
}

#pragma mark -------------------------> 初始化会话捕捉
- (void)initCaptureSessionWithPreviewView:(UIView *)previewView subView:(UIView *)subView
{
    // 与此队列中的会话和其他会话对象进行通信
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
    
    self.captureSession = [[AVCaptureSession alloc] init];
    // 偏好设置录像的分辨率
    self.captureSession.sessionPreset = [[JYResolutionData sharedManager] resolutionBackSessionPresionWith:[[NSUserDefaults standardUserDefaults] integerForKey:@"imageViewSeleted"]];
    
    self.setupResult = AVCamSetupResultSuccess;
    
    // 检测视频授权状态，视频访问是必须的，音频访问是可选的
    // 如果音频访问被拒绝， 在视频录制过程中没有录制音频
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] )
    {
        case AVAuthorizationStatusAuthorized:
        {
            // 该用户先前已授权访问相机
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            // 用户尚未提交给视频访问的选项
            // 我们暂停会话队列，以延迟会话设置，知道请求访问完成，以避免用户音频访问，如果视频访问被拒绝
            dispatch_suspend( self.sessionQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( ! granted ) {
                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
                }
                dispatch_resume( self.sessionQueue );
            }];
            break;
        }
        default:
        {
            // 用户先前以拒绝访问
            self.setupResult = AVCamSetupResultCameraNotAuthorized;
            break;
        }
    }
    
    // 设置捕追会话
    // 一般来说是不安全的 AVCaptureSession 突变 或 其任何输入，输出，或连接多个线程，在同一时间
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult != AVCamSetupResultSuccess ) {
            return;
        }
        
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [JYVideosCamera deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        
        self.videoDevice = videoDevice;
        
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if ( ! videoDeviceInput ) {
            NSLog( @"Could not create video device input: %@", error );
        }
        
        [self.captureSession beginConfiguration];
        
        if ( [self.captureSession canAddInput:videoDeviceInput] ) {
            [self.captureSession addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
            
            if (previewView) {
                self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
                self.previewLayer.frame = previewView.bounds;
                self.previewLayer.contentsGravity = kCAGravityResizeAspectFill;
                self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                dispatch_async( dispatch_get_main_queue(), ^{
                    
                    
                    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                    AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                    if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                        initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                    }
                    
                    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                } );
                [previewView.layer insertSublayer:self.previewLayer atIndex:0];
            }
        }
        else {
            // 无法将视频设备输入到会话中
            NSLog( @"Could not add video device input to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if ( ! audioDeviceInput ) {
            // 无法创建音频设备的输入
            NSLog( @"Could not create audio device input: %@", error );
        }
        
        if ( [self.captureSession canAddInput:audioDeviceInput] ) {
            [self.captureSession addInput:audioDeviceInput];
        }
        else {
            // 无法将音频设备输入到会话中
            NSLog( @"Could not add audio device input to the session" );
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ( [self.captureSession canAddOutput:movieFileOutput] ) {
            [self.captureSession addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ( connection.isVideoStabilizationSupported ) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            self.movieFileOutput = movieFileOutput;
            
        }
        else {
            // 无法将电影文件输出添加到会话中
            NSLog( @"Could not add movie file output to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        // 添加拍照
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ( [self.captureSession canAddOutput:stillImageOutput] ) {
            stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
            [self.captureSession addOutput:stillImageOutput];
            self.stillImageOutput = stillImageOutput;
        }
        else {
            // 无法将静止图像输出添加到会话中
            NSLog( @"Could not add still image output to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        [self.captureSession commitConfiguration];
    } );
}

#pragma mark -------------------------> 会话捕捉开启
- (void)startSession
{
    dispatch_async( self.sessionQueue, ^{
        switch ( self.setupResult )
        {
            case AVCamSetupResultSuccess:
            {
//                NSLog(@"录像捕捉开启");
                // 只有设置观察员， 如果设置成功就开始运行
                [self addObservers];
                [self.captureSession startRunning];
                self.sessionRunning = self.captureSession.isRunning;
                break;
            }
            case AVCamSetupResultCameraNotAuthorized:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    
                    NSLog(@"相机没有权限使用相机，请更改隐私设置");
                    //                    // 相机没有权限使用相机，请更改隐私设置
                    //                    NSString *message = NSLocalizedString( @"AVCam doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
                    //                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    //                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    //                    [alertController addAction:cancelAction];
                    //                    // Provide quick access to Settings.
                    //                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                    //                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    //                    }];
                    //                    [alertController addAction:settingsAction];
                    //                    [self presentViewController:alertController animated:YES completion:nil];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCameraChangePrivacySettings)]) {
                        [self.delegate videoCameraChangePrivacySettings];
                    }
                } );
                break;
            }
            case AVCamSetupResultSessionConfigurationFailed:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    //                    NSString *message = NSLocalizedString( @"Unable to capture media", @"Alert message when something goes wrong during capture session configuration" );
                    //                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    //                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    //                    [alertController addAction:cancelAction];
                    //                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
            }
        }
    } );
}

#pragma mark -------------------------> 停止会话捕捉
- (void)stopSession
{
//    NSLog(@"录像捕捉结束");
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult == AVCamSetupResultSuccess ) {
            [self.captureSession stopRunning];
            [self removeObservers];
        }
    } );
}

// 通知对象是遇到运行时错误的avcapturesession实例
- (void)sessionRuntimeError:(NSNotification *)notification
{
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    // 捕追会话运行时错误
    NSLog( @"Capture session runtime error: %@", error );
    
    // 如果媒体服务被重置，自动尝试重新启动会话运行，知道运行成功
    if ( error.code == AVErrorMediaServicesWereReset ) {
        dispatch_async( self.sessionQueue, ^{
            if ( self.isSessionRunning ) {
                [self.captureSession startRunning];
                self.sessionRunning = self.captureSession.isRunning;
            }
            else {
                dispatch_async( dispatch_get_main_queue(), ^{
#warning  捕追会话运行时错误的时候显示继续按钮
                    [self interruptedSession];
                } );
            }
        } );
    }
    else {
#warning 同上
        //        self.resumeButton.hidden = NO;
        [self interruptedSession];
    }
}

- (void)interruptedSession
{
    dispatch_async( self.sessionQueue, ^{
        // 当打电话的时候会话无法启动
        [self.captureSession startRunning];
        self.sessionRunning = self.captureSession.isRunning;
        if ( ! self.captureSession.isRunning ) {
            //            dispatch_async( dispatch_get_main_queue(), ^{
            //                NSString *message = NSLocalizedString( @"Unable to resume", @"Alert message when unable to resume the session running" );
            //                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
            //                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
            //                [alertController addAction:cancelAction];
            //                [self presentViewController:alertController animated:YES completion:nil];
            //            } );
        }
        else {
            dispatch_async( dispatch_get_main_queue(), ^{
                //                self.resumeButton.hidden = YES;
            } );
        }
    } );
}

// 拍照
- (void)videoTakeingPhotos
{
    dispatch_async( self.sessionQueue, ^{
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        // Update the orientation on the still image output video connection before capturing.
        connection.videoOrientation = self.previewLayer.connection.videoOrientation;
        
        // 闪关灯设置自动捕获
        [JYVideosCamera setFlashMode:AVCaptureFlashModeAuto forDevice:self.videoDeviceInput.device];
        
        // 捕捉静止图像
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^( CMSampleBufferRef imageDataSampleBuffer, NSError *error ) {
            
            if ( imageDataSampleBuffer ) {
                // 未保留样本缓冲区，在将静态图像保存到照片库之前，先创建图像数据
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                //                [self userGPSinfoSaveImageWith:imageData];
                
                [self cameraManagerSaveImageWithData:imageData];
                //                [self writeImageToAssetsLibrary:[UIImage imageWithData:imageData]];
                
                // 获取图片数据 作为图片选择按钮的点击事件
                if (self.delegate && [self.delegate respondsToSelector:@selector(videoCameraSaveImageAtData:error:)]) {
                    [self.delegate videoCameraSaveImageAtData:imageData error:error];
                }
            }
            else {
                // 无法捕捉静止图像
                NSLog( @"Could not capture still image: %@", error );
            }
        }];
    } );
}

#pragma mark ---> 保存图片数据
/**
 PHAuthorizationStatusNotDetermined = 0, // 用户尚未对该应用程序作出选择
 PHAuthorizationStatusRestricted,        // 此应用程序未授权访问照片数据。
 PHAuthorizationStatusDenied,            // 用户已明确否认了这一应用程序访问的照片数据。
 PHAuthorizationStatusAuthorized         // 用户已授权此应用程序访问照片数据。
 */
- (void)cameraManagerSaveImageWithData:(NSData *)imageData
{
    [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
        if ( status == PHAuthorizationStatusAuthorized ) {
            // To preserve the metadata, we create an asset from the JPEG NSData representation.
            // 创建JPEG类型数据保存云数据
            // In iOS 9, we can use -[PHAssetCreationRequest addResourceWithType:data:options].
            // In iOS 8, we save the image to a temporary file and use +[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:].
            if ( [PHAssetCreationRequest class] ) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
                } completionHandler:^( BOOL success, NSError *error ) {
                    if ( ! success ) {
                        // 保存图像到照片库时出错
                        NSLog( @"Error occurred while saving image to photo library: %@", error );
                    }
                }];
            }
            else {
                NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
                NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[temporaryFileName stringByAppendingPathExtension:@"jpg"]];
                NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
                
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    NSError *error = nil;
                    [imageData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
                    
                    if ( error ) {
                        // 将图像数据写入临时文件时出错
                        NSLog( @"Error occured while writing image data to a temporary file: %@", error );
                    }
                    else {
                        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
                    }
                    
                } completionHandler:^( BOOL success, NSError *error ) {
                    
                    if ( ! success ) {
                        // 保存图像到照片库时出错
                        NSLog( @"Error occurred while saving image to photo library: %@", error );
                    }
                    
                    // 删除临时文件
                    [[NSFileManager defaultManager] removeItemAtURL:temporaryFileURL error:nil];
                }];
            }
        }
    }];
}

#pragma mark ---> 设置视频分辨率
- (void)setCaptureSessionPreset:(NSString *)captureSessionPreset;
{
    [self.captureSession beginConfiguration];
    
    self.captureSessionPreset = captureSessionPreset;
    [self.captureSession setSessionPreset:_captureSessionPreset];
    
    [self.captureSession commitConfiguration];
}

#pragma mark ------------------------->  当打电话的时候会话无法启动
- (void)resumeInterruptedSession
{
    dispatch_async( self.sessionQueue, ^{
        // 当打电话的时候会话无法启动
        [self.captureSession startRunning];
        self.sessionRunning = self.captureSession.isRunning;
        if ( ! self.captureSession.isRunning ) {
            dispatch_async( dispatch_get_main_queue(), ^{
#warning 弹框显示 --- 代理
                //                NSString *message = NSLocalizedString( @"Unable to resume", @"Alert message when unable to resume the session running" );
                //                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                //                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                //                [alertController addAction:cancelAction];
                //                [self presentViewController:alertController animated:YES completion:nil];
            } );
        }
        else {
            dispatch_async( dispatch_get_main_queue(), ^{
                //                self.resumeButton.hidden = YES;
            } );
        }
    } );
}

#pragma mark ---> 调焦焦距
/**
  value : 传入进来的对焦值
 */
- (void)videCameraChangeFoucus:(CGFloat)value
{
    if (self.videoDeviceInput.device.position == AVCaptureDevicePositionBack) {
        if (value < 0) {
            value = 0;
        }
        
        if (value > 1) {
            value = 1;
        }
        
        NSError *error = nil;
        AVCaptureDevice *currentVideoDevice = self.videoDeviceInput.device;
        if ([currentVideoDevice lockForConfiguration:&error]) {
            
            [currentVideoDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNone];
            
            [currentVideoDevice setFocusModeLockedWithLensPosition:value completionHandler:nil];
            
            [currentVideoDevice unlockForConfiguration];
        }
    }
}

/** 设置相机拍摄质量 */
- (void)videoCameraQualityWithTag:(NSInteger)tag
{
    dispatch_async( self.sessionQueue, ^{
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [JYVideosCamera deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if ( ! videoDeviceInput ) {
            NSLog( @"Could not create video device input: %@", error );
        }
        
        [self.captureSession beginConfiguration];
        
        NSString *sessionPreset = nil;
        
        switch (tag) {
            case 60:
                sessionPreset = AVCaptureSessionPreset640x480;
                self.videoWidth = 640;
                break;
            case 61:
                sessionPreset = AVCaptureSessionPreset1280x720;
                self.videoWidth = 1280;
                break;
            case 62:
                sessionPreset = AVCaptureSessionPresetHigh;
                self.videoWidth = 1920;
                break;
            case 63:
                if (screenW != 3840) {
                    sessionPreset = AVCaptureSessionPreset3840x2160;
                }
                break;
        }
        if ([self.captureSession canSetSessionPreset:sessionPreset]) {
            self.captureSession.sessionPreset = sessionPreset;
            
            if ( [self.captureSession canAddInput:videoDeviceInput] ) {
                [self.captureSession addInput:videoDeviceInput];
                self.videoDeviceInput = videoDeviceInput;
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoCameraSetQuatilyError)]) {
                [self.delegate videoCameraSetQuatilyError];
            }
        }
        [self.captureSession commitConfiguration];
    });
}

- (CGFloat) getMaxZoom
{
    return MIN(self.videoDevice.activeFormat.videoMaxZoomFactor, 6 );
}

#pragma mark ---> 设置ZOOM
- (void)videoZoomWithValue:(CGFloat)value
{
    NSError *error = nil;
    
    [self.videoDevice lockForConfiguration:&error];
    
    if ( !self.videoDevice.isRampingVideoZoom ) // ignore automatic updates
        self.videoDevice.videoZoomFactor = value;
    
    [self.videoDevice unlockForConfiguration];
}

#pragma mark ---> 设置闪光灯
- (void)flashModel:(AVCaptureFlashMode)flashModel
{
    NSError *error = nil;
    
    if ([self.videoDevice lockForConfiguration:&error]) {
        
        if ([self.videoDevice isFlashModeSupported:flashModel] ) {
            self.videoDevice.flashMode = flashModel;
        }
        
        [self.videoDevice unlockForConfiguration];
        
    } else
    {
        NSLog(@"设置闪关灯失败");
    }
}

#pragma mark -------------------------> 开始视频录制
- (void)startRecoding
{
    dispatch_async( self.sessionQueue, ^{
        if ( ! self.movieFileOutput.isRecording ) {
            if ( [UIDevice currentDevice].isMultitaskingSupported ) {
                // 这里需要设置背景任务.  the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                // 回调不接收，直到相机返回前台，除非你请求后台执行
                // 这也保证有时间把相片保存到相机库
                // To conclude this background execution, -endBackgroundTask is called in
                // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            
            // 在拍摄前更新录像输出视频连线的方向
            AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
//            AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
            connection.videoOrientation = self.previewLayer.connection.videoOrientation;
            
            // 关上闪关灯
            [JYVideosCamera setFlashMode:AVCaptureFlashModeOff forDevice:self.videoDeviceInput.device];
            
            // 开始记录到临时文件
            NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"MOV"]];
            [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        }
        else {
            [self.movieFileOutput stopRecording];
        }
    } );
}

#pragma mark -------------------------> 视频录制结束
- (void)stopRecodeing
{
    [self.movieFileOutput stopRecording];
}

#pragma mark File Output Recording Delegate
#pragma mark -------------------------> 开始录像会调用的代理方法
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    // 启动录像按钮让用户停止记录
    NSLog(@"开始录像");
}

#pragma mark -------------------------> 录像录制完成会调用的代理方法
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishRecordingToOutputFileAtURL:error:)]) {
        [self.delegate didFinishRecordingToOutputFileAtURL:outputFileURL error:error];
    }
    
    // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
    // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
    // is back to NO — which happens sometime after this method returns.
    // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    dispatch_block_t cleanup = ^{
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        if ( currentBackgroundRecordingID != UIBackgroundTaskInvalid ) {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };
    
    BOOL success = YES;
    
    // 视频保存失败
    if ( error ) {
        NSLog( @"Movie file finishing error: %@", error );
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    // 视频保存成功
    if ( success ) {
        
        // 检查授权状态
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if ( status == PHAuthorizationStatusAuthorized ) {
                // 保存电影文件到照片库和清理
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    // In iOS 9 and later, it's possible to move the file into the photo library without duplicating the file data.
                    // This avoids using double the disk space during save, which can make a difference on devices with limited free disk space.
                    if ( [PHAssetResourceCreationOptions class] ) {
                        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                        options.shouldMoveFile = YES;
                        PHAssetCreationRequest *changeRequest = [PHAssetCreationRequest creationRequestForAsset];
                        [changeRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
                    }
                    else {
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                    }
                } completionHandler:^( BOOL success, NSError *error ) {
                    
                    cleanup();
                }];
            }
            else {
                cleanup();
            }
        }];
    }
    else {
        cleanup();
    }
}

- (void)cameraManagerVideoZoom:(CGFloat)zoom
{
    CGFloat value = 2.5 - 3 * zoom;
    //        NSLog(@"赋值给系统 - %f", value);
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = self.videoDevice;
    
    [currentVideoDevice lockForConfiguration:&error];
    
//    if (value >= currentVideoDevice.activeFormat.videoMaxZoomFactor) {
//        value = currentVideoDevice.activeFormat.videoMaxZoomFactor;
//    } else if (value <= 1.0)
//    {
//        value = 1.0;
//    }
//    
//    currentVideoDevice.videoZoomFactor = value;
    if ([self.videoDevice lockForConfiguration:&error])
    {
        [self.videoDevice rampToVideoZoomFactor:value withRate:10];
        
        [self.videoDevice unlockForConfiguration];
    }
    else
    {
        NSLog(@"%@", error);
    }
    //    NSLog(@"系统的对焦值 - %f", currentVideoDevice.videoZoomFactor);
    
    [currentVideoDevice unlockForConfiguration];
}

#pragma mark ---> 设置白平衡色温和色彩
- (void)videoCameraBalanceGainsWithTemp:(CGFloat)temp andTint:(CGFloat)tint
{
    AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
        .temperature = temp,
        .tint = tint,
    };
    [self videoCameraSetWhiteBalanceGains:[self.videoDevice deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
}

#pragma mark ---> 设置相机的白平衡模式
- (void)whiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    NSError *error = nil;
    
    if ([self.videoDevice lockForConfiguration:&error]) {
        
        if ([self.videoDevice isWhiteBalanceModeSupported:whiteBalanceMode] ) {
            self.videoDevice.whiteBalanceMode = whiteBalanceMode;
        }
        
        [self.videoDevice unlockForConfiguration];
        
    } else
    {
        NSLog(@"设置白平衡失败");
    }
}

- (AVCaptureWhiteBalanceMode)getWhiteBalanceMode
{
    return self.videoDevice.whiteBalanceMode;
}

#pragma mark -------------------------> 设置曝光补偿
// 设置曝光属性  ---> 曝光补偿
- (void)videoCameraWithExposure:(CGFloat)value
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = self.videoDevice;
    
    [currentVideoDevice lockForConfiguration:&error];
    
    [currentVideoDevice setExposureTargetBias:value completionHandler:nil];
    
    [currentVideoDevice unlockForConfiguration];
}

#pragma mark ---> 设置曝光时间（0 ~ 1）
static const float kExposureMinimumDuration = 1.0/1000;
static const float kExposureDurationPower = 5;
- (void)videoCameraExposureDurationWith:(CGFloat)value
{
    NSError *error = nil;
    
    double p = pow( value, kExposureDurationPower ); // Apply power function to expand slider's low-end range
    double minDurationSeconds = MAX( CMTimeGetSeconds(self.videoDevice.activeFormat.minExposureDuration ), kExposureMinimumDuration );
    double maxDurationSeconds = CMTimeGetSeconds(self.videoDevice.activeFormat.maxExposureDuration );
    double newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds; // Scale from 0-1 slider range to actual duration
    
    if ( [self.videoDevice lockForConfiguration:&error] ) {
        [self.videoDevice setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )  ISO:AVCaptureISOCurrent completionHandler:nil];
        [self.videoDevice unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

#pragma mark ---> 设置感光度
- (void)videoCameraExposureIOS:(CGFloat)iso
{
    if (iso >= self.videoDevice.activeFormat.maxISO) {
        iso = self.videoDevice.activeFormat.maxISO;
    }
    
    if (iso <= self.videoDevice.activeFormat.minISO) {
        iso = self.videoDevice.activeFormat.minISO;
    }
    
    NSError *error = nil;
    if ( [self.videoDevice lockForConfiguration:&error] ) {
        [self.videoDevice setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:iso completionHandler:nil];
        [self.videoDevice unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

#pragma mark ---> 设置相机的曝光模式
- (void)exposeMode:(AVCaptureExposureMode)exposureMode
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = self.videoDevice;
    
    if ([currentVideoDevice lockForConfiguration:&error]) {
        
        if ( currentVideoDevice.isExposurePointOfInterestSupported && [currentVideoDevice isExposureModeSupported:exposureMode] ) {
            currentVideoDevice.exposureMode = exposureMode;
        }
        
        [currentVideoDevice unlockForConfiguration];
        
    } else
    {
        NSLog(@"设置曝光失败");
    }
}

- (void)videoCameraSetWhiteBalanceGains:(AVCaptureWhiteBalanceGains)gains
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = self.videoDevice;
    if ( [currentVideoDevice lockForConfiguration:&error] ) {
        AVCaptureWhiteBalanceGains normalizedGains = [self normalizedGains:gains]; // Conversion can yield out-of-bound values, cap to limits
        [currentVideoDevice setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:normalizedGains completionHandler:nil];
        [currentVideoDevice unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

- (AVCaptureWhiteBalanceGains)normalizedGains:(AVCaptureWhiteBalanceGains) gains
{
    AVCaptureWhiteBalanceGains g = gains;
    
    g.redGain = MAX( 1.0, g.redGain );
    g.greenGain = MAX( 1.0, g.greenGain );
    g.blueGain = MAX( 1.0, g.blueGain );
    
    g.redGain = MIN(self.videoDevice.maxWhiteBalanceGain, g.redGain );
    g.greenGain = MIN(self.videoDevice.maxWhiteBalanceGain, g.greenGain );
    g.blueGain = MIN(self.videoDevice.maxWhiteBalanceGain, g.blueGain );
    
    return g;
}

#pragma mark ---> 设置视频帧率
- (void)videoCameraFormatWithDesiredFPS:(JYFormats *)format
{
    dispatch_async( self.sessionQueue, ^{
        BOOL isRunning = self.captureSession.isRunning;
        
        if (isRunning)  [self.captureSession stopRunning];
            
        if ([self.videoDevice  lockForConfiguration:nil]) {
            
            self.videoDevice .activeFormat = format.format;
            self.videoDevice .activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)[format.fpsStr floatValue]);
            self.videoDevice .activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)[format.fpsStr floatValue]);
            [self.videoDevice  unlockForConfiguration];
        }
        
        if (isRunning) [_captureSession startRunning];
    });
}

- (void)resetFormat {
    
    BOOL isRunning = self.captureSession.isRunning;
    
    if (isRunning) {
        [self.captureSession stopRunning];
    }
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [videoDevice lockForConfiguration:nil];
    videoDevice.activeFormat = self.defaultFormat;
    videoDevice.activeVideoMaxFrameDuration = defaultVideoMaxFrameDuration;
    [videoDevice unlockForConfiguration];
    
    if (isRunning) {
        [self.captureSession startRunning];
    }
}


//- (void)                 captureOutput:(AVCaptureFileOutput *)captureOutput
//   didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
//                       fromConnections:(NSArray *)connections error:(NSError *)error
//{
////    [self saveRecordedFile:outputFileURL];
//    _isRecording = NO;
//    
////    if ([self.delegate respondsToSelector:@selector(didFinishRecordingToOutputFileAtURL:error:)]) {
////        [self.delegate didFinishRecordingToOutputFileAtURL:outputFileURL error:error];
////    }
//    [self saveRecordedFile:outputFileURL];
//}

- (void)saveRecordedFile:(NSURL *)recordedFile {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        [assetLibrary writeVideoAtPathToSavedPhotosAlbum:recordedFile
                                         completionBlock:
         ^(NSURL *assetURL, NSError *error) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 NSString *title;
                 NSString *message;
                 
                 if (error != nil) {
                     
                     title = @"Failed to save video";
                     message = [error localizedDescription];
                 }
                 else {
                     title = @"Saved!";
                     message = nil;
                     
                     NSError *error;
                     NSFileManager *fm=[NSFileManager defaultManager];
                     [fm removeItemAtURL:recordedFile error:&error];
                     if (error) {
                         NSLog(@"缓存清除失败: %@", error);
                     }
                 }
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                 message:message
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             });
         }];
    });
}


+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ( device.hasFlash && [device isFlashModeSupported:flashMode] ) {
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    }
}

#pragma mark ---> 添加需要监听的对象
- (void)addObservers
{
    // 1.监听会话是否开启
    [self.captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunContext];
    
    // 实时监听白平衡的变化
    [self.videoDevice addObserver:self forKeyPath:@"deviceWhiteBalanceGains" options:NSKeyValueObservingOptionNew context:WhiteBalanceGainsContext];
    
    // 曝光补偿
    [self.videoDevice addObserver:self forKeyPath:@"exposureTargetBias" options:NSKeyValueObservingOptionNew context:ExposureTargetBiasContext];
    
    // 实时监听感光度的变化
    [self.videoDevice addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:ExposureISOContext];
    
    // 实时监听曝光时间的变化
    [self.videoDevice addObserver:self forKeyPath:@"exposureDuration" options:NSKeyValueObservingOptionNew context:ExposureDurationContext];
    
    
    // 3.设置通知 （在avcapturedevice实例检测到视频领域的一个重大改变发送通知）
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
//    
//    // 4.在caputerSession开始运行时意外出现错误时发送通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.captureSession];
    
    // 5.在avcapturesession的实例中断的时候发送通知
    // 由一个传入的电话呼叫，或报警，或另一个应用程序，以控制硬件资源的需要。当适当的avcapturesession实例将停止运行，自动响应一个中断。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.captureSession];
    
    // 6.在avcapturesession的实例不再中断的时候发送通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.captureSession];
}

- (void)sessionWasInterrupted:(NSNotification *)notification
{
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog( @"Capture session was interrupted with reason %ld", (long)reason );
    
    if ( reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
        reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient ) {     // 让用户尝试恢复会话运行
        dispatch_async( self.sessionQueue, ^{
            // The session might fail to start running, e.g., if a phone or FaceTime call is still using audio or video.
            // A failure to start the session running will be communicated via a session runtime error notification.
            // To avoid repeatedly failing to start the session running, we only try to restart the session running in the
            // session runtime error handler if we aren't trying to resume the session running.
            [self.captureSession startRunning];
            self.sessionRunning = self.captureSession.isRunning;
            if ( ! self.captureSession.isRunning ) {
                dispatch_async( dispatch_get_main_queue(), ^{
#warning 无法恢复会话运行时的警报消息
//                    NSString *message = NSLocalizedString( @"Unable to resume", @"Alert message when unable to resume the session running" );
//                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCamManual" message:message preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
//                    [alertController addAction:cancelAction];
//                    [self presentViewController:alertController animated:YES completion:nil];
                } );
            }
        } );
    }
    else if ( reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps ) {    // 通知用户相机不可用
        
    }
}

#pragma mark ---> 移除监听
- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.captureSession removeObserver:self forKeyPath:@"running" context:SessionRunContext];
    
//    [self removeObserver:self forKeyPath:@"videoDevice.focusMode" context:FocusModeContext];
//    [self removeObserver:self forKeyPath:@"videoDevice.exposureMode" context:ExposureModeContext];
    [self.videoDevice removeObserver:self forKeyPath:@"exposureDuration" context:ExposureDurationContext];
    [self.videoDevice removeObserver:self forKeyPath:@"ISO" context:ExposureISOContext];
//    [self removeObserver:self forKeyPath:@"videoDevice.whiteBalanceMode" context:WhiteBalanceModeContext];
    [self.videoDevice removeObserver:self forKeyPath:@"deviceWhiteBalanceGains" context:WhiteBalanceGainsContext];
    
    [self.videoDevice removeObserver:self forKeyPath:@"exposureTargetBias" context:ExposureTargetBiasContext];
}

#pragma mark ---> 监听事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    id oldValue = change[NSKeyValueChangeOldKey];
    id newValue = change[NSKeyValueChangeNewKey];
    if (context == SessionRunContext) {
//        NSLog(@"录像捕捉开启录像捕捉开启");
    }else if ( context == ExposureDurationContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            double newDurationSeconds = CMTimeGetSeconds( [newValue CMTimeValue] );
            if ( self.videoDevice.exposureMode != AVCaptureExposureModeCustom ) {
                double minDurationSeconds = MAX( CMTimeGetSeconds( self.videoDevice.activeFormat.minExposureDuration ), kExposureMinimumDuration );
                double maxDurationSeconds = CMTimeGetSeconds( self.videoDevice.activeFormat.maxExposureDuration );
                // Map from duration to non-linear UI range 0-1
                double p = ( newDurationSeconds - minDurationSeconds ) / ( maxDurationSeconds - minDurationSeconds ); // Scale to 0-1
                [JYSeptManager sharedManager].timeValue = pow( p, 1 / kExposureDurationPower ); // Apply inverse power
//                NSLog(@"timeValue = %f", [JYSeptManager sharedManager].timeValue);
            }
        }
    }
    else if ( context == ExposureISOContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            float newISO = [newValue floatValue];
            
            if ( self.videoDevice.exposureMode != AVCaptureExposureModeCustom ) {
                [JYSeptManager sharedManager].ISOValue = newISO;
//                NSLog(@"ISOValue = %f", [JYSeptManager sharedManager].ISOValue);
            }
        }
    }
    else if ( context == ExposureTargetBiasContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            float newExposureTargetOffset = [newValue floatValue];
            
            [JYSeptManager sharedManager].baisValue = newExposureTargetOffset;
//            NSLog(@"baisValue = %f", [JYSeptManager sharedManager].baisValue);
        }
    }
    else if ( context == WhiteBalanceGainsContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            AVCaptureWhiteBalanceGains newGains;
            [newValue getValue:&newGains];
            AVCaptureWhiteBalanceTemperatureAndTintValues newTemperatureAndTint = [self.videoDevice temperatureAndTintValuesForDeviceWhiteBalanceGains:newGains];
            
            if ( self.videoDevice.whiteBalanceMode != AVCaptureExposureModeLocked ) {
                [JYSeptManager sharedManager].temperatureAndTintValues = newTemperatureAndTint;
//                NSLog(@"Tint = %f, temp = %f", [JYSeptManager sharedManager].temperatureAndTintValues.tint, [JYSeptManager sharedManager].temperatureAndTintValues.temperature);
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

@end
