//
//  JYHomeController.h
//  ESAYCAM
//
//  Created by Sept on 16/4/22.
//  Copyright © 2016年 九月. All rights reserved.
//

#import <UIKit/UIKit.h>

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningContext = &SessionRunningContext;
static void * CaptureLensPositionContext = &CaptureLensPositionContext;
static void * DeviceWhiteBalanceGains = &DeviceWhiteBalanceGains;
static void * DeviceExposureTargetBias = &DeviceExposureTargetBias;
static void * DeviceExposureISO = &DeviceExposureISO;
static void * DeviceExposureDuration = &DeviceExposureDuration;
static void * DeviceExposureOffset = &DeviceExposureOffset;
static void * VideoCameraWidth = &VideoCameraWidth;
static void * zoomVideo = &zoomVideo;
static void * AppStoreVersion = &AppStoreVersion;

typedef NS_ENUM(NSUInteger, CoreBlueUseModel) {
    CoreBlueUseModelFocus,
    CoreBlueUseModelZOOM,
    CoreBlueUseModelDurationAndFucus,
    CoreBlueUseModelDurationAndZoom,
    CoreBlueUseModelRepeatRecording,
};

typedef NS_ENUM(NSUInteger, JYCameraType) {
    JYCameraTypeVideo,
    JYCameraTypePhoto,
};

// 曝光模式里的五种效果
typedef NS_ENUM(NSUInteger, JYTakePhotosType) {
    JYTakePhotosTypeNonal,
    JYTakePhotosTypeHDR,
    JYTakePhotosTypeResetExposure,
    JYTakePhotosTypePeople,
    JYTakePhotosTypeSights,
    JYTakePhotosTypeNight,
};

//typedef NS_ENUM(NSUInteger, CamereFangDaModel) {
//    CamereFangDaModelAuto,
//    CamereFangDaModelLock,
//    CamereFangDaModelHidden,
//};

typedef NS_ENUM(NSUInteger, JYPhotoImgModel) {
    JYPhotoImgNone,
    JYPhotoImgPhtoto,
    JYPhotoImgTVPhtoto,
};


@interface JYHomeController : UIViewController

@property (assign, nonatomic) JYCameraType cameraType;

@property (assign, nonatomic) JYTakePhotosType takeType;

@property (assign, nonatomic) CoreBlueUseModel useModel;

//@property (assign, nonatomic) CamereFangDaModel fangDaModel;

@property (assign, nonatomic) JYPhotoImgModel imgModel;

/** 中英文切换 */
@property (copy, nonatomic) NSString *connectSucces;

@property (copy, nonatomic) NSString *disConnect;

@property (copy, nonatomic) NSString *nowSace;

@property (copy, nonatomic) NSString *altTitle;
@property (copy, nonatomic) NSString *altMesage;
@property (copy, nonatomic) NSString *altCancel;
@property (copy, nonatomic) NSString *altSure;

@property (copy, nonatomic) NSString *sizeTitle;
@property (copy, nonatomic) NSString *sizeMesage;
@property (copy, nonatomic) NSString *sizeOk;

@property (copy, nonatomic) NSString *lensMesage;

@property (copy, nonatomic) NSString *direction;

@property (copy, nonatomic) NSString *changeName;
@property (copy, nonatomic) NSString *nameMsg;
@property (copy, nonatomic) NSString *nameplace;

@property (copy, nonatomic) NSString *noperName;

@end
