//
//  JYContenView.h
//  SeptEsayCamera
//
//  Created by Sept on 16/3/17.
//  Copyright © 2016年 九月. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreBluetooth/CoreBluetooth.h>


@protocol JYContentViewDelegate <NSObject>

@optional
- (void)contentViewSwitchOnClick:(UISwitch *)mSwitch;

- (void)contentViewResetBtnOnClick:(UIButton *)btn;

/** JYResolutionViewDelegate  相机质量选择 */
- (void)contentViewDirectionCellBtnOnClick:(UIButton *)btn;

/** 设置对比度 */
- (void)contentViewCustomSliderValueChange:(UISlider *)slider;

/** 显示蓝牙界面 */
- (void)contentViewLabelDirectionBtnOnClick:(UIButton *)btn;

/** 设置白平衡滑动数据 */
- (void)contentViewBalanceCustomSliderValueChange:(UISlider *)slider;

/** 设置白平衡自动和手动 */
- (void)contentViewBalanceAutoBtnOnClick:(UIButton *)btn;

/** 天气滤镜 */
- (void)contentViewWetherButtonOnClick:(UIButton *)btn;

- (void)contentViewExpsureCustomSliderValueChange:(UISlider *)slider;

- (void)contentViewExpsureAutoBtnOnClick:(UIButton *)btn;

- (void)contentViewPushEsaycamWebView;

- (void)contentViewCameraLensViewCellBtnOnClick:(UIButton *)btn;

/** 重复最后一次录制 */
- (void)contentViewResetVideo:(UIButton *)btn;

- (void)contentViewHandwheelOnClick:(UIButton *)btn;

- (void)threeViewButtonOnClick:(UIButton *)sender;

- (void)contentViewFlashViewOnClick:(UIButton *)btn;

- (void)contentViewQualityBtnOnClick:(UIButton *)btn;

- (void)baisSliderValueChange:(UISlider *)slider;

- (void)contentViewBaisSliderAutoBtnOnClick:(UIButton *)btn;

- (void)exposureFiveXiaoGuoButtonOnClick:(UIButton *)btn;

- (void)whiteBalanceBaisSliderValueChange:(UISlider *)slider;

@end

@interface JYContenView : UIView

@property (weak, nonatomic) id<JYContentViewDelegate> delegate;

/** 设置系统相机反馈的白平衡、曝光属性 slider的value
 tag : slider的tag
 type: 0 -> expsureView, 1 -> balanceView
 */
- (void)contentViewSetCustomSliderValue:(CGFloat)value andCustomSliderTag:(NSInteger)tag classType:(NSInteger)type;

- (void)contenViewCameraLensViewShowOneCell;

- (void)contenViewSetDirectionBtnTitle:(NSString *)title andTag:(NSInteger)tag;

- (void)contentViewSwitchHidden:(BOOL)hidden andTag:(NSInteger)tag;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign, nonatomic) BOOL handBool;

@property (assign, nonatomic) BOOL isHidden;

@property (assign, nonatomic) CGSize whiteSize;

@end
