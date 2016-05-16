//
//  JYCameraManager.m
//  Esaycamera
//
//  Created by Sept on 16/4/8.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYCameraManager.h"




@interface JYCameraManager () <GPUImageMovieWriterDelegate>
{
    CGRect _frame;
    GPUImageMovieWriter *movieWriter;
    CMTime defaultVideoMaxFrameDuration;
}
@property (nonatomic, unsafe_unretained) dispatch_queue_t prepareFilterQueue;

@property (nonatomic , strong) GPUImageView *cameraScreen;

@property (nonatomic, strong) AVCaptureDeviceFormat *defaultFormat;

@property (strong, nonatomic) NSDictionary *videoSettings;

@end

@implementation JYCameraManager

- (instancetype)initWithFrame:(CGRect)frame superview:(UIView *)superview {
    
    self = [super init];
    if (self) {
        _frame = frame;
        [superview addSubview:self.cameraScreen];
        
        self.videoSize = CGSizeMake(1920.0, 1080.0);
        
        self.quality = 5.0f;
    }
    return self;
}

- (void)takePhoto
{
    [self.camera capturePhotoAsJPEGProcessedUpToFilter:self.filter withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
        
        if (!error) {
            [[JYSaveVideoData sharedManager] saveImageWithData:processedJPEG];
            // 返回拍照数据
            if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(cameraManageTakingPhotoSucuess:)]) {
                [self.cameraDelegate cameraManageTakingPhotoSucuess:processedJPEG];
            }
        }else
        {
            NSLog(@"拍照时，error = %@", error);
        }
    }];
}

- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS
{
    BOOL isRunning = self.captureSession.isRunning;
    
    if (isRunning)  [self.captureSession stopRunning];
    
    AVCaptureDeviceFormat *selectedFormat = nil;
    AVFrameRateRange *frameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in [_inputCamera formats]) {
        
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            if (range.minFrameRate <= desiredFPS && width == (int)self.videoSize.width && range.maxFrameRate == desiredFPS) {
                
                selectedFormat = format;
                frameRateRange = range;
            }
        }
    }
    
    if (selectedFormat) {
    
        if ([_inputCamera lockForConfiguration:nil]) {
            
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(selectedFormat.formatDescription);
            self.videoSize = CGSizeMake(dimensions.width, dimensions.height);
            
            _inputCamera.activeFormat = selectedFormat;
            _inputCamera.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            _inputCamera.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [_inputCamera unlockForConfiguration];
        }
    }
    
    if (isRunning) [self.captureSession startRunning];
}

- (void)resetFormat {
    
    BOOL isRunning = self.captureSession.isRunning;
    
    if (isRunning) {
        [self.captureSession stopRunning];
    }
    
//    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [_inputCamera lockForConfiguration:nil];
    _inputCamera.activeFormat = self.defaultFormat;
    _inputCamera.activeVideoMaxFrameDuration = defaultVideoMaxFrameDuration;
    [_inputCamera unlockForConfiguration];
    
    if (isRunning) {
        [self.captureSession startRunning];
    }
}

- (GPUImageView *)cameraScreen {
    if (!_cameraScreen) {
        GPUImageView *cameraScreen = [[GPUImageView alloc] initWithFrame:_frame];
        cameraScreen.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        _cameraScreen = cameraScreen;
    }
    return _cameraScreen;
}

- (GPUImageView *)subPreview
{
    if (!_subPreview) {
        GPUImageView *subPreview = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        subPreview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        subPreview.transform = CGAffineTransformMakeScale(4.0, 4.0);
        _subPreview = subPreview;
    }
    return _subPreview;
}

/**
 
 AVCaptureSessionPreset640x480
 AVCaptureSessionPresetHigh
 */

- (GPUImageStillCamera *)camera
{
    if (!_camera) {
        _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
        _camera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
        _camera.horizontallyMirrorFrontFacingCamera = NO;
        _camera.horizontallyMirrorRearFacingCamera = NO;
    
        self.filter = [[GPUImageSaturationFilter alloc] init];
        [_camera addTarget:self.filter];
        [self.filter addTarget:self.cameraScreen];
        [self.filter addTarget:self.subPreview];
    }
    return _camera;
}

#pragma mark 启用预览
- (void)startCamera{
    [self.camera startCameraCapture];
}

#pragma mark 关闭预览
- (void)stopCamera{
    [self.camera stopCameraCapture];
}

- (void)startVideo
{
    movieWriter = [self writer];
    [movieWriter startRecording];
}

- (void)stopVideo
{
    // 1.停止录像
    [self.filter removeTarget:movieWriter];
    self.camera.audioEncodingTarget = nil;
    [movieWriter finishRecording];
}

- (GPUImageMovieWriter *)writer
{
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.MOV"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    GPUImageMovieWriter *writer = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:self.videoSize quality:self.quality];
    

//    GPUImageMovieWriter *writer = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:self.videoSize fileType:AVFileTypeQuickTimeMovie outputSettings:attributes];        writer.shouldPassthroughAudio = YES;
    writer.delegate = self;
    
    [self.filter addTarget:writer];
    self.camera.audioEncodingTarget = writer;
    
    return writer;
}

- (void)movieRecordingCompleted
{
//    NSLog(@"ABSBSBBSBSB");
}

- (void)movieRecordingvideoSaveSuccess:(NSURL *)url
{
    if (self.cameraDelegate && [self.cameraDelegate respondsToSelector:@selector(cameraManagerRecodingSuccess:)]) {
        [self.cameraDelegate cameraManagerRecodingSuccess:url];
    }
}

#pragma mark -------------------------> 调焦焦距
- (void)cameraManagerChangeFoucus:(CGFloat)value
{
//    NSLog(@"%f", value);
    CGFloat lensPosition = value - 0.5;
    if (videoInput.device.position == AVCaptureDevicePositionBack) {
        if (lensPosition < 0) {
            lensPosition = 0;
        }
        
        if (lensPosition > 1) {
            lensPosition = 1;
        }
        
        NSError *error = nil;
        AVCaptureDevice *currentVideoDevice = videoInput.device;
        if ([currentVideoDevice lockForConfiguration:&error]) {
            
            [currentVideoDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNone];
            
            [currentVideoDevice setFocusModeLockedWithLensPosition:lensPosition completionHandler:nil];
            
            [currentVideoDevice unlockForConfiguration];
        }
    }
}

- (void)cameraManagerExposureIOS:(CGFloat)iso
{
    if (iso >= self.inputCamera.activeFormat.maxISO) {
        iso = self.inputCamera.activeFormat.maxISO;
    }
    
    if (iso <= self.inputCamera.activeFormat.minISO) {
        iso = self.inputCamera.activeFormat.minISO;
    }
    
    NSError *error = nil;
    if ( [self.inputCamera lockForConfiguration:&error] ) {
        [self.inputCamera setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:iso completionHandler:nil];
        [self.inputCamera unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

static const float kExposureMinimumDuration = 1.0/1000;
static const float kExposureDurationPower = 5;
- (void)setExposureDurationWith:(CGFloat)value withBlock:(JYLableText)text
{
    NSError *error = nil;
    
    double p = pow( value, kExposureDurationPower ); // Apply power function to expand slider's low-end range
    double minDurationSeconds = MAX( CMTimeGetSeconds(self.inputCamera.activeFormat.minExposureDuration ), kExposureMinimumDuration );
    double maxDurationSeconds = CMTimeGetSeconds(self.inputCamera.activeFormat.maxExposureDuration );
    double newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds; // Scale from 0-1 slider range to actual duration
    
    if ( [self.inputCamera lockForConfiguration:&error] ) {
        [self.inputCamera setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )  ISO:AVCaptureISOCurrent completionHandler:nil];
        [self.inputCamera unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

#pragma mark -------------------------> 设置曝光补偿
// 设置曝光属性  ---> 曝光补偿
- (void)cameraManagerWithExposure:(CGFloat)value
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = videoInput.device;
    
    [currentVideoDevice lockForConfiguration:&error];
    
    [currentVideoDevice setExposureTargetBias:value completionHandler:nil];
    
    [currentVideoDevice unlockForConfiguration];
}

- (void)cameraManagerVideoZoom:(CGFloat)zoom
{
    CGFloat value = 2.5 - 3 * zoom;
//        NSLog(@"赋值给系统 - %f", value);
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = videoInput.device;
    
    [currentVideoDevice lockForConfiguration:&error];
    
    if (value >= currentVideoDevice.activeFormat.videoMaxZoomFactor) {
        value = currentVideoDevice.activeFormat.videoMaxZoomFactor;
    } else if (value <= 1.0)
    {
        value = 1.0;
    }
    
    currentVideoDevice.videoZoomFactor = value;
    //    NSLog(@"系统的对焦值 - %f", currentVideoDevice.videoZoomFactor);
    
    [currentVideoDevice unlockForConfiguration];
}


/** 设置相机的白平衡模式 */
- (void)whiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    NSError *error = nil;
    
    if ([_inputCamera lockForConfiguration:&error]) {
        
        if ([_inputCamera isWhiteBalanceModeSupported:whiteBalanceMode] ) {
            _inputCamera.whiteBalanceMode = whiteBalanceMode;
        }
        
        [_inputCamera unlockForConfiguration];
        
    } else
    {
        NSLog(@"设置白平衡失败");
    }
}

/** 设置相机的曝光模式 */
- (void)exposeMode:(AVCaptureExposureMode)exposureMode
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = videoInput.device;
    
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

- (void)flashModel:(AVCaptureFlashMode)flashModel
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = videoInput.device;
    
    if ([currentVideoDevice lockForConfiguration:&error]) {
        
        if ([currentVideoDevice isFlashModeSupported:flashModel] ) {
            currentVideoDevice.flashMode = flashModel;
        }
        
        [currentVideoDevice unlockForConfiguration];
        
    } else
    {
        NSLog(@"设置闪关灯失败");
    }
}

- (void)cameraManagerBalanceGainsWithTemp:(CGFloat)temp andTint:(CGFloat)tint
{
    AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
        .temperature = temp,
        .tint = tint,
    };
    [self cameraManagerSetWhiteBalanceGains:[videoInput.device deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
}

- (void)cameraManagerSetWhiteBalanceGains:(AVCaptureWhiteBalanceGains)gains
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = videoInput.device;
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
    
    g.redGain = MIN( videoInput.device.maxWhiteBalanceGain, g.redGain );
    g.greenGain = MIN( videoInput.device.maxWhiteBalanceGain, g.greenGain );
    g.blueGain = MIN( videoInput.device.maxWhiteBalanceGain, g.blueGain );
    
    return g;
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

/** 设置相机拍摄质量 */
- (void)cameraManagerEffectqualityWithTag:(NSInteger)tag withBlock:(CanSetSessionPreset)canSetSessionPreset
{
    NSError *error = nil;
    
    AVCaptureDevice *videoDevice = [JYCameraManager deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if ( ! videoDeviceInput ) {
        NSLog( @"Could not create video device input: %@", error );
    }
    
    [self.captureSession beginConfiguration];
    
    NSString *sessionPreset = nil;
    
    switch (tag) {
            
        case 60:
            sessionPreset = AVCaptureSessionPreset640x480;
            break;
        case 61:
            sessionPreset = AVCaptureSessionPreset1280x720;
            break;
        case 62:
            sessionPreset = AVCaptureSessionPreset1920x1080;
            break;
        case 63:
            sessionPreset = AVCaptureSessionPreset3840x2160;
            break;
        default:
            sessionPreset = AVCaptureSessionPresetHigh;
            break;
    }
    if ([self.captureSession canSetSessionPreset:sessionPreset])
    {
        [self setCaptureSessionPreset:sessionPreset];
        
        // 2.偏好设置保存选中的分辨率
        [[NSUserDefaults standardUserDefaults] setInteger:tag forKey:@"imageViewSeleted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"%@", self.captureSessionPreset);
    } else{
        canSetSessionPreset(NO);
    }
    
    
    if ( [self.captureSession canAddInput:videoDeviceInput] ) {
        [self.captureSession addInput:videoDeviceInput];
        videoInput = videoDeviceInput;
    }
    
    [self.captureSession commitConfiguration];
    //    });
}

#pragma mark -------------------------> 更改操作
// 设置闪关灯
- (void)setEnableFlash:(BOOL)enableFlash
{
    _enableFlash = enableFlash;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        if (enableFlash) { [device setTorchMode:AVCaptureTorchModeOn]; }
        else { [device setTorchMode:AVCaptureTorchModeOff]; }
        [device unlockForConfiguration];
    }
}

#pragma mark -------------------------> 设置曝光时间 和 感光度
- (void)videoCameraWithExposureTime:(CGFloat)time andIso:(CGFloat)iso
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = videoInput.device;
    
    [currentVideoDevice lockForConfiguration:&error];
    
    //        AVCaptureDeviceFormat *deviceFormat = self.captureDevice.activeFormat;
    //
    //        NSLog(@"%f =%f", deviceFormat.maxISO, deviceFormat.minISO);
    CMTime timea = CMTimeMake(time, 1000000);
    
    [currentVideoDevice setExposureModeCustomWithDuration:timea ISO:iso completionHandler:^(CMTime syncTime) {
        
    }];
    //    CMTime time = CMTimeMake(125, 1000000);
    //    CMTime time1 = CMTimeMake(333333, 1000000);
    //    NSLog(@"%f  == %f",CMTimeGetSeconds(time), CMTimeGetSeconds(time1));
    //    NSLog(@"%f == %f",deviceFormat.minISO, deviceFormat.maxISO);
    [currentVideoDevice unlockForConfiguration];
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
