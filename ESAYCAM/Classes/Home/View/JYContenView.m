//
//  JYContenView.m
//  SeptEsayCamera
//
//  Created by Sept on 16/3/17.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYContenView.h"

#import "JYThreeBtnView.h"
#import "JYSettingView.h"
#import "JYBalanceView.h"
#import "JYExpsureView.h"

#import "JYResolutionView.h"
#import "JYLanguageView.h"
#import "JYSupportView.h"
#import "JYCameraLensView.h"
#import "JYResetVideoView.h"
#import "JYHandwheelView.h"
#import "JYFlashView.h"
#import "JYQualityView.h"

#define scrollView_contentSize 700

static NSString *ID = @"fenbinalv";

@interface JYContenView() <JYThreeBtnViewDelegate, JYSettingViewDelegate, JYBalanceViewDelegate, JYExpsureViewDelegate, JYResolutionViewDelegate, JYLanguageViewDelegate, JYSupportViewDelegate, JYCameraLensViewDelegate, JYResetVideoViewDelegate, JYHandwheelViewDelegte, JYFlashViewDelegate, JYQualityViewDelegate>

@property (strong, nonatomic) JYThreeBtnView *threeBtnView;


@property (strong, nonatomic) JYSettingView *settingView;

@property (strong, nonatomic) JYSupportView *supportView;

@property (strong, nonatomic) JYBalanceView *balanceView;

@property (strong, nonatomic) JYExpsureView *expsureView;

@property (strong, nonatomic) JYResolutionView *resolutionView;

@property (strong, nonatomic) JYLanguageView *languageView;

@property (strong, nonatomic) JYCameraLensView *lensView;

@property (strong, nonatomic) JYResetVideoView *resetView;

@property (strong, nonatomic) JYHandwheelView *handView;

@property (strong, nonatomic) JYFlashView *flashView;

@property (strong, nonatomic) JYQualityView *qualityView;

@end

@implementation JYContenView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreDefaults) name:@"RestoreDefaults" object:nil];
    }
    return self;
}

- (void)restoreDefaults
{
    self.threeBtnView.layer.opacity = 1.0;
}

/** 设置、白平衡、曝光按钮 */
- (JYThreeBtnView *)threeBtnView
{
    if (!_threeBtnView) {
        
        _threeBtnView = [JYThreeBtnView threeBtnView];
        
        _threeBtnView.backgroundColor = [UIColor clearColor];
        _threeBtnView.delegate = self;
        _threeBtnView.layer.opacity = ([[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"] == 0) ? 1 : [[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"];
        
        [self addSubview:_threeBtnView];
    }
    return _threeBtnView;
}

/** settingView的背景scrollView */
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] init];
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.contentSize = CGSizeMake(0, scrollView_contentSize);
        
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

/** settingView */
- (JYSettingView *)settingView
{
    if (!_settingView) {
        
        _settingView = [[JYSettingView alloc] init];
        _settingView.delegate = self;
        
        [self.scrollView addSubview:_settingView];
    }
    return _settingView;
}

/** 懒加载平衡的View */
- (JYBalanceView *)balanceView
{
    if (_balanceView == nil) {
        
        _balanceView = [[JYBalanceView alloc] initWithWidth:self.scrollView.width];
        _balanceView.hidden = YES;
        _balanceView.delegate = self;
        
        [self addSubview:_balanceView];
    }
    return _balanceView;
}

/** 懒加载曝光的View */
- (JYExpsureView *)expsureView
{
    if (_expsureView == nil) {
        
        _expsureView = [[JYExpsureView alloc] init];
        _expsureView.delegate = self;
        _expsureView.hidden = YES;
        
        [self addSubview:_expsureView];
    }
    return _expsureView;
}

/** 分辨率 */
- (JYResolutionView *)resolutionView
{
    if (!_resolutionView) {
        _resolutionView = [[JYResolutionView alloc] init];
        _resolutionView.hidden = YES;
        _resolutionView.delegate = self;
        
        [self addSubview:_resolutionView];
    }
    return _resolutionView;
}

/** 附加镜头 */
- (JYCameraLensView *)lensView
{
    if (!_lensView) {
        _lensView = [[JYCameraLensView alloc] init];
        _lensView.hidden = YES;
        _lensView.delegate = self;
        
        [self addSubview:_lensView];
    }
    return _lensView;
}

/** 语言设置 */
- (JYLanguageView *)languageView
{
    if (!_languageView) {
        _languageView = [[JYLanguageView alloc] init];
        _languageView.hidden = YES;
        _languageView.delegate = self;
        
        [self addSubview:_languageView];
    }
    return _languageView;
}

- (JYResetVideoView *)resetView
{
    if (!_resetView) {
        _resetView = [[JYResetVideoView alloc] init];
        _resetView.hidden = YES;
        _resetView.delegate = self;
        
        [self addSubview:_resetView];
    }
    return _resetView;
}


/** 设置的内容视图 */
- (JYSupportView *)supportView
{
    if (!_supportView) {
        
        _supportView = [[JYSupportView alloc] init];
        
        _supportView.hidden = YES;
        _supportView.delegate = self;
        
        [self addSubview:_supportView];
    }
    return _supportView;
}

/** 手轮方向 */
- (JYHandwheelView *)handView
{
    if (!_handView) {
        
        _handView = [[JYHandwheelView alloc] init];
        
        _handView.hidden = YES;
        _handView.delegate = self;
        
        [self addSubview:_handView];
    }
    return _handView;
}

/** 闪光灯 */
- (JYFlashView *)flashView
{
    if (!_flashView) {
        
        _flashView = [[JYFlashView alloc] init];
        
        _flashView.hidden = YES;
        _flashView.delegate = self;
        
        [self addSubview:_flashView];
    }
    return _flashView;
}


/** 闪光灯 */
- (JYQualityView *)qualityView
{
    if (!_qualityView) {
        
        _qualityView = [[JYQualityView alloc] init];
        
        _qualityView.hidden = YES;
        _qualityView.delegate = self;
        
        [self addSubview:_qualityView];
    }
    return _qualityView;
}

#pragma mark -------------------------> JYFlashViewDelegate
- (void)flashViewCellBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewFlashViewOnClick:)]) {
        [self.delegate contentViewFlashViewOnClick:btn];
    }
    [self.settingView setDirectionBtnTitle:btn.currentTitle andTag:87];
    
    // 1.点击选择 -- 掩藏分辨率的View  显示scrollView
    self.flashView.hidden = YES;
    self.scrollView.hidden = NO;
}

- (void)setWhiteSize:(CGSize)whiteSize
{
    _whiteSize = whiteSize;
    
    self.balanceView.whiteSize = whiteSize;
}

#pragma mark -------------------------> JYResetVideoViewDelegate
// 自动重复
- (void)resetVideoDirectionCellBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewResetVideo:)]) {
        [self.delegate contentViewResetVideo:btn];
    }
    
    [self.settingView setDirectionBtnTitle:btn.currentTitle andTag:86];
    
    self.resetView.hidden = YES;
    self.scrollView.hidden = NO;
}

#pragma mark -------------------------> JYThreeBtnViewDelegate 设置、白平衡、曝光按钮的显示与掩藏
- (void)threeViewButtonOnClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 30:    // 设置按钮
            [self showView:self.scrollView hiddenView:self.expsureView and:self.balanceView];
            break;
        case 31:    // 白平衡按钮
            [self showView:self.balanceView hiddenView:self.expsureView and:self.scrollView];
            break;
        case 32:    // 曝光按钮
            [self showView:self.expsureView hiddenView:self.balanceView and:self.scrollView];
            break;
            
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(threeViewButtonOnClick:)]) {
        [self.delegate threeViewButtonOnClick:sender];
    }
}

- (void)showView:(UIView *)showView hiddenView:(UIView *)oneView and:(UIView *)twoView
{
    twoView.hidden = YES;
    oneView.hidden = YES;
    showView.hidden = NO;
    self.resolutionView.hidden = YES;
    self.languageView.hidden = YES;
    self.lensView.hidden = YES;
    self.supportView.hidden = YES;
    self.resetView.hidden = YES;
    self.handView.hidden = YES;
    self.flashView.hidden = YES;
    self.qualityView.hidden = YES;
}

/** JYSettingViewDelegate  */
// 摄像头，闪光灯，九宫格
- (void)settingViewSwitchOnClick:(UISwitch *)mSwitch
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewSwitchOnClick:)]) {
        [self.delegate contentViewSwitchOnClick:mSwitch];
    }
}

/** 设置对比度 */
- (void)settingViewCustomSliderValueChange:(UISlider *)slider
{
    self.threeBtnView.layer.opacity = slider.value;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewCustomSliderValueChange:)])
    {
        [self.delegate contentViewCustomSliderValueChange:slider];
    }
}

/** JYResolutionViewDelegate  相机质量选择 */
- (void)directionCellBtnOnClick:(UIButton *)btn
{
    // 1.点击选择 -- 掩藏分辨率的View  显示scrollView
    self.resolutionView.hidden = YES;
    self.scrollView.hidden = NO;
    
    // 2.设置分辨率
    if (screenH >= 375 || btn.tag != 63) {
        [self.settingView setDirectionBtnTitle:btn.currentTitle andTag:81];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewDirectionCellBtnOnClick:)]) {
        [self.delegate contentViewDirectionCellBtnOnClick:btn];
    }
}

// 恢复所有的默认设置
- (void)settingViewResetBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewResetBtnOnClick:)]) {
        [self.delegate contentViewResetBtnOnClick:btn];
    }
}

/** JYLanguageViewDelegate 语言切换 */
- (void)languageViewDirectionCellBtnOnClick:(UIButton *)btn
{
    self.languageView.hidden = YES;
    self.scrollView.hidden = NO;
    
    [self.settingView setDirectionBtnTitle:btn.currentTitle andTag:82];
    
//    switch (btn.tag) {
//        case 80:
//            // 设置语言的名称
//            [self.settingView setDirectionBtnTitle:@"简体中文" andTag:82];
//            break;
//        case 81:
//            // 设置语言的名称
//            [self.settingView setDirectionBtnTitle:@"English" andTag:82];
//            break;
//    }
}

- (void)contentViewSwitchHidden:(BOOL)hidden andTag:(NSInteger)tag
{
    [self.settingView switchHidden:hidden andTag:tag];
}

- (void)contenViewSetDirectionBtnTitle:(NSString *)title andTag:(NSInteger)tag
{
    [self.settingView setDirectionBtnTitle:title andTag:tag];
}

// 附加镜头
- (void)cameraLensViewCellBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewCameraLensViewCellBtnOnClick:)]) {
        [self.delegate contentViewCameraLensViewCellBtnOnClick:btn];
    }
    [self.settingView setDirectionBtnTitle:btn.currentTitle andTag:85];
    
    // 1.点击选择 -- 掩藏分辨率的View  显示scrollView
    self.lensView.hidden = YES;
    self.scrollView.hidden = NO;
}

- (void)setIsHidden:(BOOL)isHidden
{
    _isHidden = isHidden;
    self.scrollView.hidden = isHidden;
}

#pragma ============== JYHandwheelViewDelegte
- (void)handwheelDirectionCellBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewHandwheelOnClick:)]) {
        [self.delegate contentViewHandwheelOnClick:btn];
    }
    
//    [self.settingView setDirectionBtnTitle:btn.currentTitle andTag:84];
    
    // 1.点击选择 -- 掩藏分辨率的View  显示scrollView
    self.handView.hidden = YES;
    self.scrollView.hidden = NO;
}

- (void)settingViewLabelDirectionBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewLabelDirectionBtnOnClick:)]) {
        [self.delegate contentViewLabelDirectionBtnOnClick:btn];
    }
    switch (btn.tag) {
        case 51:
            self.scrollView.hidden = YES;
            self.resolutionView.hidden = NO;
            break;
        case 52:
            self.scrollView.hidden = YES;
            self.languageView.hidden = NO;
            break;
        case 53:
            if (self.handBool == YES) {
                self.scrollView.hidden = YES;
                self.handView.hidden = NO;
                self.handBool = NO;
            }
            break;
        case 54:
            self.scrollView.hidden = YES;
            self.supportView.hidden = NO;
            break;
        case 55:
            self.scrollView.hidden = YES;
            self.lensView.hidden = NO;
            break;
        case 56:
            if (self.handBool == YES) {
                self.scrollView.hidden = YES;
                self.resetView.hidden = NO;
                self.handBool = NO;
            }
            break;
        case 57:
            self.scrollView.hidden = YES;
            self.flashView.hidden = NO;
            break;
        case 59:
            self.scrollView.hidden = YES;
            self.qualityView.hidden = NO;
            break;
            
        default:
            break;
    }
}

- (void)contenViewCameraLensViewShowOneCell
{
    [self.lensView cameraLensViewShowOneCell];
}

#pragma mark -------------------------> JYQualityDelegte
- (void)qualityBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewQualityBtnOnClick:)]) {
        [self.delegate contentViewQualityBtnOnClick:btn];
    }
    [self.settingView setDirectionBtnTitle:btn.currentTitle andTag:89];
    
    // 1.点击选择 -- 掩藏分辨率的View  显示scrollView
    self.qualityView.hidden = YES;
    self.scrollView.hidden = NO;
}

#pragma mark -------------------------> JYSupportViewDelegate
- (void)pushEsaycamWebView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewPushEsaycamWebView)]) {
        [self.delegate contentViewPushEsaycamWebView];
    }
}

#pragma mark -------------------------> JYBalanceViewDelegate
- (void)whiteBalanceCustomSliderValueChange:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewBalanceCustomSliderValueChange:)]) {
        [self.delegate contentViewBalanceCustomSliderValueChange:slider];
    }
}

- (void)whiteBalanceCustomSliderAutoBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewBalanceAutoBtnOnClick:)]) {
        [self.delegate contentViewBalanceAutoBtnOnClick:btn];
    }
}

- (void)expsureViewCustomSliderValueChange:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewExpsureCustomSliderValueChange:)]) {
        [self.delegate contentViewExpsureCustomSliderValueChange:slider];
    }
}

- (void)expsureViewCustomSliderAutoBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewExpsureAutoBtnOnClick:)]) {
        [self.delegate contentViewExpsureAutoBtnOnClick:btn];
    }
}

- (void)baisSliderValueChange:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(baisSliderValueChange:)]) {
        [self.delegate baisSliderValueChange:slider];
    }
}

- (void)baisSliderAutoBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewBaisSliderAutoBtnOnClick:)]) {
        [self.delegate contentViewBaisSliderAutoBtnOnClick:btn];
    }
}

/** 设置系统相机反馈的白平衡、曝光属性 slider的value
 tag : slider的tag
 type: 0 -> expsureView, 1 -> balanceView
 */
- (void)contentViewSetCustomSliderValue:(CGFloat)value andCustomSliderTag:(NSInteger)tag classType:(NSInteger)type
{
    switch (type) {
        case 0:
            [self.expsureView exposureSetCustomSliderValue:value andCustomSliderTag:tag];
            break;
        case 1:
            [self.balanceView whiteBalanceSetCustomSliderValue:value andCustomSliderTag:tag];
            break;
            
        default:
            break;
    }
}

/** 天气滤镜 */
- (void)wetherButtonOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewWetherButtonOnClick:)]) {
        [self.delegate contentViewWetherButtonOnClick:btn];
    }
}

- (void)layoutSubviews
{
    self.threeBtnView.frame = CGRectMake(JYSpaceWidth, JYSpaceWidth, self.width - 2 * JYSpaceWidth, 32);
    
    self.scrollView.frame = CGRectMake(JYSpaceWidth, 60, self.width - 2 * JYSpaceWidth, self.height - 60);
    
    self.settingView.frame = CGRectMake(0, 0, self.scrollView.width, scrollView_contentSize);
    
    self.balanceView.frame = CGRectMake(0, self.scrollView.y, self.scrollView.width, self.scrollView.height);
    
    self.expsureView.frame = CGRectMake(0, self.scrollView.y, self.scrollView.width, self.scrollView.height);
    
    self.resolutionView.frame = CGRectMake(JYSpaceWidth, self.scrollView.y - 20, self.scrollView.width, self.scrollView.height);
    
    self.languageView.frame = self.resolutionView.frame;
    self.resetView.frame = self.languageView.frame;
    
    self.supportView.frame = CGRectMake(self.scrollView.x, self.scrollView.y, self.scrollView.width, self.scrollView.height - 10);
    
    self.lensView.frame = CGRectMake(self.scrollView.x, self.scrollView.y, self.scrollView.width, self.scrollView.height - 10);
    
    self.handView.frame = self.lensView.frame;
    
    self.flashView.frame = self.lensView.frame;
    
    self.qualityView.frame = self.lensView.frame;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeLanguage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RestoreDefaults" object:nil];
}

@end
