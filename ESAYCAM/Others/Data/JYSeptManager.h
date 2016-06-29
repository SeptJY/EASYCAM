//
//  JYSeptDelegate.h
//  Sept数据库
//
//  Created by admin on 15/12/28.
//  Copyright © 2015年 Sept. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import "JYBlueManager.h"
@class JYPeripheral;


@interface JYSeptManager : NSObject

+ (instancetype)sharedManager;

@property (assign, nonatomic) CGFloat baisValue;

@property (assign, nonatomic) CGFloat ISOValue;

@property (assign, nonatomic) CGFloat timeValue;

@property (assign, nonatomic) CGFloat focusValue;

@property (assign, nonatomic) CGFloat offsetValue;

@property (assign, nonatomic) BOOL isAutoFocus;

@property (assign, nonatomic) BOOL isEnglish;

@property (assign, nonatomic) NSInteger version;

@property (assign, nonatomic) NSInteger hardVersion;   // 硬件版本
@property (assign, nonatomic) NSInteger hardSoftVersion;   // 硬件软件版本

@property (copy, nonatomic) NSString *perName;     // 蓝牙名称

@property (strong, nonatomic) JYBlueManager *blueManager;

// 判断点击白平衡时是否需要HUD
@property (assign, nonatomic) BOOL iSHUD;

// 当前相机模型
@property (assign, nonatomic) BOOL cameraType;

@property (assign, nonatomic) AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTintValues;

// 存储appStore的版本号
@property (strong, nonatomic) NSDictionary *versionDict;

/** 归档蓝牙数据 */
- (void)saveCoreBlueWith:(JYPeripheral *)pre;

- (BOOL)currentLanguage;

@end
