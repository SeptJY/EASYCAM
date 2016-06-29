//
//  JYVideoCamera.m
//  TestVideo
//
//  Created by Sept on 16/5/26.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYPhotosCamera.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GPUImageBeautifyFilter.h"

@interface JYPhotosCamera () <GPUImageMovieWriterDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, GPUImageVideoCameraDelegate>
{
    CMTime defaultVideoMaxFrameDuration;
    dispatch_queue_t movieWritingQueue;
    CMBufferQueueRef previewBufferQueue;
    NSArray *_bracketSettings;
    
    BOOL readyToRecordAudio;
    BOOL readyToRecordVideo;
    AVCaptureVideoOrientation videoOrientation;
    AVCaptureVideoOrientation referenceOrientation;
    BOOL recordingWillBeStarted;
    NSURL *_url;
}

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (strong, nonatomic) UIView *superView;

@property (nonatomic, strong) AVCaptureDeviceFormat *defaultFormat;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) GPUImageBeautifyFilter *beautifyFilter;

@property (assign, nonatomic) BOOL isBeautify;

@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;

@end


@implementation JYPhotosCamera

- (instancetype)initWithSuperView:(UIView *)superView
{
    self = [super init];
    if (self) {
        
        movieWritingQueue = dispatch_queue_create("com.shu223.moviewriting", DISPATCH_QUEUE_SERIAL);
        referenceOrientation = (AVCaptureVideoOrientation)UIDeviceOrientationPortrait;
        self.superView = superView;
        
        self.imgsArray = [[NSMutableArray alloc] init];
        
        [self.photosManager prepareBracketsWithIndex:1];
    }
    return self;
}

#pragma mark ---> 开启、关闭会话捕捉
- (void)startCamera
{
//    NSLog(@"拍照会话开启");
    [self addObservers];
    [self.photosManager startCameraCapture];
}

// 关闭会话捕捉
- (void)stopCamera
{
//    NSLog(@"拍照会话关闭");
    [self removeObservers];
    [self.photosManager stopCameraCapture];
}

#pragma mark ---> 局部放大显示的view
- (GPUImageView *)scaleView
{
    if (!_scaleView) {
        _scaleView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        _scaleView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        _scaleView.transform = CGAffineTransformMakeScale(4.0, 4.0);
    }
    return _scaleView;
}

#pragma mark ---> 会话显示的view
- (GPUImageView *)filteredVideoView
{
    if (!_filteredVideoView) {
        
        _filteredVideoView = [[GPUImageView alloc] init];
        
        _filteredVideoView.frame = self.superView.bounds;
        _filteredVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        [self.superView insertSubview:_filteredVideoView atIndex:0];
    }
    return _filteredVideoView;
}

#pragma mark ---> 人像模式的美白
- (GPUImageBeautifyFilter *)beautifyFilter
{
    if (_beautifyFilter == nil) {
        _beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    }
    return _beautifyFilter;
}

// 开启人像模式
- (void)startPortrait
{
    [self.photosManager removeAllTargets];
    [self.photosManager addTarget:self.beautifyFilter];
    [self.beautifyFilter addTarget:self.filteredVideoView];
    [self.beautifyFilter addTarget:self.scaleView];
    
    self.isBeautify = YES;
}

// 结束人像模式
- (void)stopPortrait
{
    [self.photosManager removeAllTargets];
    [self.photosManager addTarget:self.filter];
    
    [self.filter addTarget:self.filteredVideoView];
    [self.filter addTarget:self.scaleView];
    
    self.isBeautify = NO;
}

#pragma mark ---> 设置ZOOM
- (void)photosCameraWithZoom:(CGFloat)value
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = self.photosManager.inputCamera;
    
    [currentVideoDevice lockForConfiguration:&error];
    
    if ( ! self.photosManager.inputCamera.isRampingVideoZoom ) // ignore automatic updates
        self.photosManager.inputCamera.videoZoomFactor = value;
    
    [currentVideoDevice unlockForConfiguration];
}

- (CGFloat) getMaxZoom
{
    return MIN(self.photosManager.inputCamera.activeFormat.videoMaxZoomFactor, 6 );
}

#pragma mark ---> HDR 模式
- (void)takePhotosWithHDR
{
    [self.photosManager startBracketsCompletionHandler:^(UIImage *image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraManageTakingPhotoSucuess:)]) {
            [self.delegate cameraManageTakingPhotoSucuess:image];
        }
    }];
}

#pragma mark ---> 设置HDR的效果，0是不同曝光补偿
- (void)prepareHDRWithIndex:(NSInteger)index
{
    [self.photosManager prepareBracketsWithIndex:index];
}

#pragma mark ---> 拍照
- (void)takePhoto
{
    NSLog(@"%@", self.photosManager.captureSessionPreset);
    if (self.isBeautify == NO) {
        [self.photosManager capturePhotoAsImageProcessedUpToFilter:self.filter withOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            
            UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(cameraManageTakingPhotoSucuess:)]) {
                [self.delegate cameraManageTakingPhotoSucuess:processedImage];
            }
        }];
    } else
    {
        [self.photosManager capturePhotoAsImageProcessedUpToFilter:self.beautifyFilter withOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            
            UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(cameraManageTakingPhotoSucuess:)]) {
                [self.delegate cameraManageTakingPhotoSucuess:processedImage];
            }
        }];
    }
}

#pragma mark ---> 双重曝光
- (void)doubleExposure
{
    [self.photosManager capturePhotoAsImageProcessedUpToFilter:self.filter withOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraManageTakingPhotoSucuess:)]) {
            [self.delegate cameraManageTakingPhotoSucuess:processedImage];
        }
    }];
}

- (void)takePhotoWithArray
{
    [self.photosManager capturePhotoAsImageProcessedUpToFilter:self.filter withOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        
//        UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
//        NSLog(@"%@", processedImage);
        if (processedImage) {
            [self.imgsArray addObject:processedImage];
        }
//        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraManageTakingPhotoSucuessArray:)]) {
//            [self.delegate cameraManageTakingPhotoSucuessArray:self.imgsArray];
//        }
        
//        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraManageTakingPhotoSucuess:)]) {
//            [self.delegate cameraManageTakingPhotoSucuess:processedImage];
//        }
    }];
}

#pragma mark ---> 滤镜组合
- (GPUImageFilterGroup *)filter
{
    if (!_filter) {
        _filter = [[GPUImageFilterGroup alloc] init];
        
        [self.exposureFilter addTarget:self.saturationFilter];
        
        [(GPUImageFilterGroup *) _filter setInitialFilters:[NSArray arrayWithObject: self.exposureFilter]];
        [(GPUImageFilterGroup *) _filter setTerminalFilter:self.saturationFilter];
        
        [_filter addTarget:self.filteredVideoView];
        [_filter addTarget:self.scaleView];
    }
    return _filter;
}

#pragma mark ---> 曝光滤镜
- (GPUImageExposureFilter *)exposureFilter
{
    if (_exposureFilter == nil) {
        _exposureFilter = [[GPUImageExposureFilter alloc] init];
    }
    return _exposureFilter;
}

#pragma mark ---> 饱和度
- (GPUImageSaturationFilter *)saturationFilter
{
    if (_saturationFilter == nil) {
        _saturationFilter = [[GPUImageSaturationFilter alloc] init];
    }
    return _saturationFilter;
}

#pragma mark ---> 初始化相机
- (GPUImageStillCamera *)photosManager
{
    if (!_photosManager) {
        _photosManager = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        _photosManager.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
        [_photosManager addAudioInputsAndOutputs];
        [_photosManager addTarget:self.filter];
        _photosManager.delegate =  self;
    }
    return _photosManager;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.photosManager.captureSession];
        _previewLayer.frame = self.superView.bounds;
        _previewLayer.contentsGravity = kCAGravityResizeAspectFill;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    
    return _previewLayer;
}

- (void)didOutputMetadataObjects:(NSArray *)metadataObjects
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didOutputMetadataObjects:previewLayer:)]) {
        [self.delegate didOutputMetadataObjects:metadataObjects previewLayer:self.previewLayer];
    }
}

#pragma mark -------------------------> 调焦焦距
- (void)photosCameraChangeFoucus:(CGFloat)value
{
    //    NSLog(@"%f", value);d
    CGFloat lensPosition = value - 0.5;
    if (self.photosManager.inputCamera.position == AVCaptureDevicePositionBack) {
        if (lensPosition < 0) {
            lensPosition = 0;
        }
        
        if (lensPosition > 1) {
            lensPosition = 1;
        }
        
        NSError *error = nil;
        AVCaptureDevice *currentVideoDevice = self.photosManager.inputCamera;
        if ([currentVideoDevice lockForConfiguration:&error]) {
            
            [currentVideoDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNone];
            
            [currentVideoDevice setFocusModeLockedWithLensPosition:lensPosition completionHandler:nil];
            
            [currentVideoDevice unlockForConfiguration];
        }
    }
}

#pragma mark -------------------------> 设置曝光时间 和 感光度
- (void)photosCameraExposureTime:(CGFloat)time andIso:(CGFloat)iso
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = self.photosManager.inputCamera;
    
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

#pragma mark ---> 设置闪关灯模式
- (void)flashModel:(AVCaptureFlashMode)flashModel
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = self.photosManager.inputCamera;
    
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

#pragma mark ---> 设置白平衡
- (void)photosCameraSetWhiteBalanceGains:(AVCaptureWhiteBalanceGains)gains
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = self.photosManager.inputCamera;
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
    
    g.redGain = MIN(self.photosManager.inputCamera.maxWhiteBalanceGain, g.redGain );
    g.greenGain = MIN( self.photosManager.inputCamera.maxWhiteBalanceGain, g.greenGain );
    g.blueGain = MIN( self.photosManager.inputCamera.maxWhiteBalanceGain, g.blueGain );
    
    return g;
}

#pragma mark ---> 设置相机的白平衡模式
- (void)whiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    NSError *error = nil;
    
    if ([self.photosManager.inputCamera lockForConfiguration:&error]) {
        
        if ([self.photosManager.inputCamera isWhiteBalanceModeSupported:whiteBalanceMode] ) {
            self.photosManager.inputCamera.whiteBalanceMode = whiteBalanceMode;
        }
        
        [self.photosManager.inputCamera unlockForConfiguration];
        
    } else
    {
        NSLog(@"设置白平衡失败");
    }
}

#pragma mark ---> 设置色温和色彩
- (void)photosCameraBalanceGainsWithTemp:(CGFloat)temp andTint:(CGFloat)tint
{
    AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
        .temperature = temp,
        .tint = tint,
    };
    [self photosCameraSetWhiteBalanceGains:[self.photosManager.inputCamera deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
}

#pragma mark ---> 设置感光度
- (void)photosCameraExposureIOS:(CGFloat)iso
{
    if (iso >= self.photosManager.inputCamera.activeFormat.maxISO) {
        iso = self.photosManager.inputCamera.activeFormat.maxISO;
    }
    
    if (iso <= self.photosManager.inputCamera.activeFormat.minISO) {
        iso = self.photosManager.inputCamera.activeFormat.minISO;
    }
    
    NSError *error = nil;
    if ( [self.photosManager.inputCamera lockForConfiguration:&error] ) {
        [self.photosManager.inputCamera setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:iso completionHandler:nil];
        [self.photosManager.inputCamera unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

static const float kExposureMinimumDuration = 1.0/1000;
static const float kExposureDurationPower = 5;
#pragma mark ---> 设置曝光时间
- (void)photosCameraExposureDuration:(CGFloat)value
{
    NSError *error = nil;
    
    double p = pow( value, kExposureDurationPower ); // Apply power function to expand slider's low-end range
    double minDurationSeconds = MAX( CMTimeGetSeconds(self.photosManager.inputCamera.activeFormat.minExposureDuration ), kExposureMinimumDuration );
    double maxDurationSeconds = CMTimeGetSeconds(self.photosManager.inputCamera.activeFormat.maxExposureDuration );
    double newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds; // Scale from 0-1 slider range to actual duration
    
    if ( [self.photosManager.inputCamera lockForConfiguration:&error] ) {
        [self.photosManager.inputCamera setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )  ISO:AVCaptureISOCurrent completionHandler:nil];
        [self.photosManager.inputCamera unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

#pragma mark ---> 设置相机的曝光模式 */
- (void)exposeMode:(AVCaptureExposureMode)exposureMode
{
    NSError *error = nil;
    AVCaptureDevice *currentVideoDevice = self.photosManager.inputCamera;
    
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

#pragma mark ---> 添加事件监听
- (void)addObservers
{
    // 白平衡
    [self.photosManager.inputCamera addObserver:self forKeyPath:@"deviceWhiteBalanceGains" options:NSKeyValueObservingOptionNew context:PhotosWhiteBalanceGainsContext];
    
    // 曝光时间
    [self.photosManager.inputCamera addObserver:self forKeyPath:@"exposureDuration" options:NSKeyValueObservingOptionNew context:PhotosDurationContext];
    
    // 感光度
    [self.photosManager.inputCamera addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:PhotosISOContext];
    
    // 曝光补偿
    [self.photosManager.inputCamera addObserver:self forKeyPath:@"exposureTargetBias" options:NSKeyValueObservingOptionNew context:PhotosBiasContext];
}

#pragma mark ---> 移除监听
- (void)removeObservers
{
    [self.photosManager.inputCamera removeObserver:self forKeyPath:@"exposureDuration" context:PhotosDurationContext];
    [self.photosManager.inputCamera removeObserver:self forKeyPath:@"ISO" context:PhotosISOContext];
    //    [self removeObserver:self forKeyPath:@"videoDevice.whiteBalanceMode" context:WhiteBalanceModeContext];
    [self.photosManager.inputCamera removeObserver:self forKeyPath:@"deviceWhiteBalanceGains" context:PhotosWhiteBalanceGainsContext];
    
    [self.photosManager.inputCamera removeObserver:self forKeyPath:@"exposureTargetBias" context:PhotosBiasContext];
}

#pragma mark ---> 监听事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //    id oldValue = change[NSKeyValueChangeOldKey];
    id newValue = change[NSKeyValueChangeNewKey];
    
    if ( context == PhotosDurationContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            double newDurationSeconds = CMTimeGetSeconds( [newValue CMTimeValue] );
            if ( self.photosManager.inputCamera.exposureMode != AVCaptureExposureModeCustom ) {
                double minDurationSeconds = MAX( CMTimeGetSeconds(self.photosManager.inputCamera.activeFormat.minExposureDuration ), kExposureMinimumDuration );
                double maxDurationSeconds = CMTimeGetSeconds(self.photosManager.inputCamera.activeFormat.maxExposureDuration );
                // Map from duration to non-linear UI range 0-1
                double p = ( newDurationSeconds - minDurationSeconds ) / ( maxDurationSeconds - minDurationSeconds ); // Scale to 0-1
                [JYSeptManager sharedManager].timeValue = pow( p, 1 / kExposureDurationPower ); // Apply inverse power
//                NSLog(@"P _timeValue = %f", [JYSeptManager sharedManager].timeValue);
            }
        }
    }
    else if ( context == PhotosISOContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            float newISO = [newValue floatValue];
            
            if (self.photosManager.inputCamera.exposureMode != AVCaptureExposureModeCustom ) {
                [JYSeptManager sharedManager].ISOValue = newISO;
//                NSLog(@"P _ISOValue = %f", [JYSeptManager sharedManager].ISOValue);
            }
        }
    }
    else if ( context == PhotosBiasContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            float newExposureTargetOffset = [newValue floatValue];
            
            [JYSeptManager sharedManager].baisValue = newExposureTargetOffset;
//            NSLog(@"P _baisValue = %f", [JYSeptManager sharedManager].baisValue);
        }
    }
    else if ( context == PhotosWhiteBalanceGainsContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            AVCaptureWhiteBalanceGains newGains;
            [newValue getValue:&newGains];
            AVCaptureWhiteBalanceTemperatureAndTintValues newTemperatureAndTint = [self.photosManager.inputCamera temperatureAndTintValuesForDeviceWhiteBalanceGains:newGains];
            
            if (self.photosManager.inputCamera.whiteBalanceMode != AVCaptureExposureModeLocked ) {
                [JYSeptManager sharedManager].temperatureAndTintValues = newTemperatureAndTint;
//                NSLog(@"P _Tint = %f, temp = %f", [JYSeptManager sharedManager].temperatureAndTintValues.tint, [JYSeptManager sharedManager].temperatureAndTintValues.temperature);
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (AVCaptureWhiteBalanceMode)getWhiteBalanceMode
{
    return self.photosManager.inputCamera.whiteBalanceMode;
}

@end
