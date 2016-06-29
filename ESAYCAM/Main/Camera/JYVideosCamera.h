//
//  TTMCaptureManager.h
//  SlowMotionVideoRecorder
//  https://github.com/shu223/SlowMotionVideoRecorder
//
//  Created by shuichi on 12/17/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreMedia;
@class JYFormats;

@protocol JYCaptureManagerDelegate <NSObject>
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                                      error:(NSError *)error;
- (void)videoCameraSetQuatilyError;

/** 跳转到隐私设置更改 */
- (void)videoCameraChangePrivacySettings;

- (void)videoCameraSaveImageAtData:(NSData *)data error:(NSError *)error;

@end

static void * SessionRunContext = &SessionRunContext;
static void * LensPositionContext = &LensPositionContext;
static void * WhiteBalanceGainsContext = &WhiteBalanceGainsContext;
static void * ExposureTargetBiasContext = &ExposureTargetBiasContext;
static void * ExposureISOContext = &ExposureISOContext;
static void * ExposureDurationContext = &ExposureDurationContext;


@interface JYVideosCamera : NSObject

@property (nonatomic, assign) id<JYCaptureManagerDelegate> delegate;
@property (nonatomic, readonly) BOOL isRecording;

@property (nonatomic, strong) AVCaptureDevice *videoDevice;

@property (readwrite, nonatomic, copy) NSString *captureSessionPreset;

// 会话显示的previewView
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

// 会话显示的previewView
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *subPreviewLayer;

// 视频的宽度，为了匹配合适的fps
@property (assign, nonatomic) NSInteger videoWidth;

- (instancetype)initWithPreviewView:(UIView *)previewView withSub:(UIView *)subView;

// 开始或停止记录
- (void)startRecoding;
- (void)stopRecodeing;

// 开始或停止会话捕捉
- (void)startSession;
- (void)stopSession;

// 拍照
- (void)videoTakeingPhotos;

// 设置ZOOM
- (void)cameraManagerVideoZoom:(CGFloat)zoom;

// 设置对焦
- (void)videCameraChangeFoucus:(CGFloat)value;

- (void)videoCameraSetWhiteBalanceGains:(AVCaptureWhiteBalanceGains)gains;

- (void)videoCameraBalanceGainsWithTemp:(CGFloat)temp andTint:(CGFloat)tint;

- (void)whiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode;

// 设置曝光属性  ---> 曝光补偿
- (void)videoCameraWithExposure:(CGFloat)value;

- (void)videoCameraExposureDurationWith:(CGFloat)value;

- (void)videoCameraExposureIOS:(CGFloat)iso;

- (void)exposeMode:(AVCaptureExposureMode)exposureMode;

- (CGFloat) getMaxZoom;
#pragma mark ---> 设置ZOOM
- (void)videoZoomWithValue:(CGFloat)value;

- (void)flashModel:(AVCaptureFlashMode)flashModel;

- (void)videoCameraFormatWithDesiredFPS:(JYFormats *)format;

- (void)resetFormat;

- (void)videoCameraQualityWithTag:(NSInteger)tag;

- (AVCaptureWhiteBalanceMode)getWhiteBalanceMode;

@end
