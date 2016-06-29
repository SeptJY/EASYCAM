//
//  JYVideoCamera.h
//  TestVideo
//
//  Created by Sept on 16/5/26.
//  Copyright © 2016年 九月. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@protocol JYVideoCameraDelegate <NSObject>

@optional
- (void)cameraManagerRecodingSuccess:(NSURL *)url;

- (void)cameraManageTakingPhotoSucuess:(UIImage *)image;

- (void)cameraManageTakingPhotoSucuessArray:(NSMutableArray *)images;

- (void)videoCameraDidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)didOutputMetadataObjects:(NSArray *)metadataObjects previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

@end

static void * PhotosFocusContext = &PhotosFocusContext;
static void * PhotosWhiteBalanceGainsContext = &PhotosWhiteBalanceGainsContext;
static void * PhotosBiasContext = &PhotosBiasContext;
static void * PhotosISOContext = &PhotosISOContext;
static void * PhotosDurationContext = &PhotosDurationContext;

@interface JYPhotosCamera : NSObject

@property (copy, nonatomic) NSString *pathToMovie;

@property (weak, nonatomic) id<JYVideoCameraDelegate> delegate;

@property (strong, nonatomic) GPUImageView *scaleView;
@property (strong, nonatomic) GPUImageView *filteredVideoView;

@property (strong, nonatomic) GPUImageStillCamera *photosManager;

@property (nonatomic, strong) GPUImageExposureFilter *exposureFilter;
@property (nonatomic, strong) GPUImageSaturationFilter *saturationFilter;

@property (strong, nonatomic) GPUImageLowPassFilter *lowPassFilter;
@property (strong, nonatomic) GPUImageFilterGroup *filter;

- (instancetype)initWithSuperView:(UIView *)superView;

@property (nonatomic, copy) void (^onBuffer)(CMSampleBufferRef sampleBuffer);
@property (nonatomic, assign) BOOL isRecording;

- (void)startCamera;
- (void)stopCamera;

- (void)photosCameraChangeFoucus:(CGFloat)value;

- (void)photosCameraExposureTime:(CGFloat)time andIso:(CGFloat)iso;

- (void)flashModel:(AVCaptureFlashMode)flashModel;

- (void)photosCameraWithZoom:(CGFloat)zoom;

- (void)photosCameraSetWhiteBalanceGains:(AVCaptureWhiteBalanceGains)gains;

- (AVCaptureWhiteBalanceGains)normalizedGains:(AVCaptureWhiteBalanceGains) gains;

- (void)whiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode;

- (void)photosCameraBalanceGainsWithTemp:(CGFloat)temp andTint:(CGFloat)tint;

- (void)photosCameraExposureIOS:(CGFloat)iso;

- (void)photosCameraExposureDuration:(CGFloat)value;

- (void)exposeMode:(AVCaptureExposureMode)exposureMode;

- (void)takePhoto;

- (void)takePhotosWithHDR;

- (void)prepareHDRWithIndex:(NSInteger)index;

- (void)takePhotoWithArray;;

@property (strong, nonatomic) NSMutableArray *imgsArray;

- (void)doubleExposure;

- (void)startPortrait;

// 结束人像模式
- (void)stopPortrait;

- (CGFloat) getMaxZoom;

- (AVCaptureWhiteBalanceMode)getWhiteBalanceMode;

@end
