//
//  JYSettingView.m
//  SeptEsayCamera
//
//  Created by Sept on 16/3/17.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYSettingView.h"

#import "JYLabelDirection.h"
#import "JYLabelSwitch.h"
#import "JYCustomSliderView.h"

#define DIRECTION_SIZE_LABEL @"Auto Repeat"
#define SWITCH_SIZE_LABEL @"VideoFlash"

static void *COREBLUE_NAME = &COREBLUE_NAME;

@interface JYSettingView () <JYLabelSwitchDelegate, JYCustomSliderViewDelegate, JYLabelDirectionDelegate>

@property (strong, nonatomic) JYLabelDirection *blueDirection;

@property (strong, nonatomic) JYLabelDirection *resolutionDirection;

@property (strong, nonatomic) JYLabelDirection *languageDirection;

//@property (strong, nonatomic) JYLabelSwitch *positionSwitch;

@property (strong, nonatomic) JYLabelSwitch *girldSwitch;

@property (strong, nonatomic) JYLabelSwitch *videoFalshView;

@property (strong, nonatomic) JYCustomSliderView *alphaSlide;

@property (strong, nonatomic) JYLabelDirection *direction;

@property (strong, nonatomic) JYLabelDirection *suportDirection;

@property (strong, nonatomic) JYLabelDirection *chooseDirection;

@property (strong, nonatomic) JYLabelDirection *lastVideo;

@property (strong, nonatomic) JYLabelDirection *flasView;

@property (strong, nonatomic) JYLabelDirection *fpsDirection;

@property (strong, nonatomic) JYLabelDirection *qualityDirection;

/** 恢复默认设置 */
@property (strong, nonatomic) UIButton *resetBtn;
@property (strong, nonatomic) UIView *lineView;

@end

@implementation JYSettingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.opacity = ([[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"] == 0) ? 1 : [[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreDefaults) name:@"RestoreDefaults" object:nil];
        
        // 设置蓝牙连接之后显示连接蓝牙的名称
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"perName" options:NSKeyValueObservingOptionNew context:COREBLUE_NAME];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == COREBLUE_NAME) {    // 设置连接蓝牙的显示名称
        self.blueDirection.titleBtn = [JYSeptManager sharedManager].perName;
        self.videoFalshView.switchEnlenble = YES;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)restoreDefaults
{
    self.alphaSlide.value = 1.0;
    self.layer.opacity = 1.0;
    
    [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:@"opacity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.resolutionDirection.titleBtn = @"1920x1080";
    // 62是1920x1080分辨率按钮的tag
    [[NSUserDefaults standardUserDefaults] setInteger:62 forKey:@"imageViewSeleted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _girldSwitch.mSwitchOn = NO;
    // 保存设置
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"grladView_hidden"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changeLanguage
{
    self.blueDirection.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"蓝  牙" value:nil table:@"Localizable"];
    
    self.resolutionDirection.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"分辨率 " value:nil table:@"Localizable"];
    
    self.languageDirection.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"语  言" value:nil table:@"Localizable"];
    
    self.fpsDirection.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"帧  率" value:nil table:@"Localizable"];
    
    self.qualityDirection.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"编码质量" value:nil table:@"Localizable"];
    [self.qualityDirection.btn setTitle:[[JYLanguageTool bundle] localizedStringForKey:self.qualityDirection.btn.currentTitle value:nil table:@"Localizable"] forState:UIControlStateNormal];
    
    self.direction.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"手轮方向" value:nil table:@"Localizable"];
    
    self.chooseDirection.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"附加镜头" value:nil table:@"Localizable"];
    [self.chooseDirection.btn setTitle:[[JYLanguageTool bundle] localizedStringForKey:self.chooseDirection.btn.currentTitle value:nil table:@"Localizable"] forState:UIControlStateNormal];
    
    self.lastVideo.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"自动重复" value:nil table:@"Localizable"];
    [self.lastVideo.btn setTitle:[[JYLanguageTool bundle] localizedStringForKey:self.lastVideo.btn.currentTitle value:nil table:@"Localizable"] forState:UIControlStateNormal];
    
    
    self.suportDirection.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"硬件支持" value:nil table:@"Localizable"];
    
//    self.positionSwitch.title = [[JYLanguageTool bundle] localizedStringForKey:@"摄像头" value:nil table:@"Localizable"];
    
    self.videoFalshView.title = [[JYLanguageTool bundle] localizedStringForKey:@"录像灯" value:nil table:@"Localizable"];
    
    self.flasView.titleLabel = [[JYLanguageTool bundle] localizedStringForKey:@"闪光灯" value:nil table:@"Localizable"];
    [self.flasView.btn setTitle:[[JYLanguageTool bundle] localizedStringForKey:self.flasView.btn.currentTitle value:nil table:@"Localizable"] forState:UIControlStateNormal];
    
    self.girldSwitch.title = [[JYLanguageTool bundle] localizedStringForKey:@"九宫格" value:nil table:@"Localizable"];
    
    self.alphaSlide.title = [[JYLanguageTool bundle] localizedStringForKey:@"对比度" value:nil table:@"Localizable"];
    
    self.languageDirection.titleBtn = [[JYLanguageTool bundle] localizedStringForKey:self.languageDirection.titleBtn value:nil table:@"Localizable"];
    if ([self.direction.titleBtn isEqualToString:@"正"] || [self.direction.titleBtn isEqualToString:@"Positive"]) {
        self.direction.titleBtn = [[JYLanguageTool bundle] localizedStringForKey:@"正" value:nil table:@"Localizable"];
    }
    
    if ([self.direction.titleBtn isEqualToString:@"反"] || [self.direction.titleBtn isEqualToString:@"Negative"]) {
        self.direction.titleBtn = [[JYLanguageTool bundle] localizedStringForKey:@"反" value:nil table:@"Localizable"];
    }
    
    [self.resetBtn setTitle:[[JYLanguageTool bundle] localizedStringForKey:@"恢复默认设置" value:nil table:@"Localizable"] forState:UIControlStateNormal];
    
    if ([self.blueDirection.titleBtn isEqualToString:@"未连接"] || [self.blueDirection.titleBtn isEqualToString:@"Not connected"]) {
        self.blueDirection.titleBtn = [[JYLanguageTool bundle] localizedStringForKey:@"未连接" value:nil table:@"Localizable"];
    }
}

/** 蓝牙 */
- (JYLabelDirection *)blueDirection
{
    if (!_blueDirection) {
        
        _blueDirection = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _blueDirection.titleBtn = [NSString titleChinese:@"未连接" english:@"Not connected"];
        _blueDirection.btnTag = 50;
        _blueDirection.titleLabel = [NSString titleChinese:@"蓝  牙" english:@"Bluetooth"];
        _blueDirection.delegate = self;
        _blueDirection.tag = 80;
        
        [self addSubview:_blueDirection];
    }
    return _blueDirection;
}

/** 分辨率 */
- (JYLabelDirection *)resolutionDirection
{
    if (!_resolutionDirection) {
        
        _resolutionDirection = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _resolutionDirection.titleBtn = [[JYResolutionData sharedManager] resolutionBackImageBtnTitleWith:[[NSUserDefaults standardUserDefaults] integerForKey:@"imageViewSeleted"]];
        _resolutionDirection.btnTag = 51;
        _resolutionDirection.titleLabel = [NSString titleChinese:@"分辨率 " english:@"Resolution"];
        ;
        _resolutionDirection.delegate = self;
        _blueDirection.tag = 81;
        
        [self addSubview:_resolutionDirection];
    }
    return _resolutionDirection;
}

/** 硬件支持 */
- (JYLabelDirection *)suportDirection
{
    if (!_suportDirection) {
        
        _suportDirection = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _suportDirection.titleLabel = [NSString titleChinese:@"硬件支持" english:@"Support"];
        _suportDirection.btnTag = 54;
        _suportDirection.delegate = self;
        _suportDirection.tag = 82;
        
        [self addSubview:_suportDirection];
    }
    return _suportDirection;
}

/** 语言选择 */
- (JYLabelDirection *)languageDirection
{
    if (!_languageDirection) {
        
        _languageDirection = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _languageDirection.titleBtn = [NSString titleChinese:@"简体中文" english:@"English"];
        _languageDirection.titleLabel = [NSString titleChinese:@"语  言" english:@"Language"];
        _languageDirection.btnTag = 52;
        _languageDirection.delegate = self;
        _blueDirection.tag = 83;
        
        [self addSubview:_languageDirection];
    }
    return _languageDirection;
}

/** 手轮方向 */
- (JYLabelDirection *)direction
{
    if (!_direction) {
        
        _direction = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _direction.titleBtn = ([[NSUserDefaults standardUserDefaults] integerForKey:BlueDerection] == 1) ? [NSString titleChinese:@"反" english:@"Negative"] : [NSString titleChinese:@"正" english:@"Positive"];
        _direction.titleLabel = [NSString titleChinese:@"手轮方向" english:@"Direction"];
        _direction.btnTag = 53;
        _direction.delegate = self;
        _direction.tag = 84;
        
        [self addSubview:_direction];
    }
    return _direction;
}

/** 附加镜头 */
- (JYLabelDirection *)chooseDirection
{
    if (!_chooseDirection) {
        
        _chooseDirection = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _chooseDirection.titleLabel = [NSString titleChinese:@"附加镜头" english:@"Lens"];
        _chooseDirection.btnTag = 55;
        _chooseDirection.delegate = self;
        _chooseDirection.tag = 85;
        _chooseDirection.titleBtn = [NSString titleChinese:@"无镜头" english:@"No Lens"];
        
        [self addSubview:_chooseDirection];
    }
    return _chooseDirection;
}

/** 自动重复 */
- (JYLabelDirection *)lastVideo
{
    if (!_lastVideo) {
        
        _lastVideo = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _lastVideo.titleLabel = [NSString titleChinese:@"自动重复" english:@"Auto Repeat"];
        _lastVideo.btnTag = 56;
        _lastVideo.delegate = self;
        _lastVideo.tag = 86;
        _lastVideo.titleBtn = [NSString titleChinese:@"两点" english:@"Linear"];
        
        [self addSubview:_lastVideo];
    }
    return _lastVideo;
}

/** 闪光灯 */
- (JYLabelDirection *)flasView
{
    if (!_flasView) {
        
        _flasView = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _flasView.titleLabel = [NSString titleChinese:@"闪光灯" english:@"Flash"];
        _flasView.btnTag = 57;
        _flasView.delegate = self;
        _flasView.tag = 87;
        _flasView.titleBtn = [NSString titleChinese:@"自动" english:@"Auto"];
        
        [self addSubview:_flasView];
    }
    return _flasView;
}

/** fps */
- (JYLabelDirection *)fpsDirection
{
    if (!_fpsDirection) {
        
        _fpsDirection = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _fpsDirection.titleLabel = [NSString titleChinese:@"帧  率" english:@"fps"];
        _fpsDirection.btnTag = 58;
        _fpsDirection.delegate = self;
        _fpsDirection.tag = 88;
        _fpsDirection.titleBtn = @"30";
        
        [self addSubview:_fpsDirection];
    }
    return _fpsDirection;
}

/** fps */
- (JYLabelDirection *)qualityDirection
{
    if (!_qualityDirection) {
        
        _qualityDirection = [[JYLabelDirection alloc] initWithTitle:DIRECTION_SIZE_LABEL];
        _qualityDirection.titleLabel = [NSString titleChinese:@"编码质量" english:@"Quality"];
        _qualityDirection.btnTag = 59;
        _qualityDirection.delegate = self;
        _qualityDirection.tag = 89;
        _qualityDirection.titleBtn = [NSString titleChinese:@"标准" english:@"Standard"];
        
        [self addSubview:_qualityDirection];
    }
    return _qualityDirection;
}

- (void)setDirectionBtnTitle:(NSString *)title andTag:(NSInteger)tag
{
    switch (tag) {
        case 80:   // 蓝牙
            self.blueDirection.titleBtn = title;
            break;
            
        case 81:   // 分辨率
            self.resolutionDirection.titleBtn = title;
            break;
            
        case 82:   // 语言切换
            self.languageDirection.titleBtn = title;
            break;
        case 86:   // 最后一次
//            if ([self.lastVideo.titleBtn isEqualToString:@"Linear"]) {
//                self.lastVideo.titleBtn = @"RealTime";
//            } else if ([self.lastVideo.titleBtn isEqualToString:@"RealTime"]) {
//                self.lastVideo.titleBtn = @"Linear";
//            } else if ([self.lastVideo.titleBtn isEqualToString:@"实时"]) {
//                self.lastVideo.titleBtn = @"线性";
//            }else if ([self.lastVideo.titleBtn isEqualToString:@"线性"]) {
//                self.lastVideo.titleBtn = @"实时";
//            }
            self.lastVideo.titleBtn = title;
            break;
            
        case 85:   // 附加镜头
            self.chooseDirection.titleBtn = title;
            break;
        case 84:   // 手轮方向
            self.direction.titleBtn = title;
            break;
        case 87:   // 闪光灯
            self.flasView.titleBtn = title;
            break;
        case 88:   // fps
            self.fpsDirection.titleBtn = title;
            break;
        case 89:   // fps
            self.qualityDirection.titleBtn = title;
            break;
            
        default:
            break;
    }
}

/** 摄像头 */
//- (JYLabelSwitch *)positionSwitch
//{
//    if (!_positionSwitch) {
//        
//        _positionSwitch = [[JYLabelSwitch alloc] initWithTitle:SWITCH_SIZE_LABEL];
//        _positionSwitch.switchTag = 40;
//        _positionSwitch.delegate = self;
//        _positionSwitch.title = @"摄像头";
//        
//        [self addSubview:_positionSwitch];
//    }
//    return _positionSwitch;
//}

/** 九宫格 */
- (JYLabelSwitch *)girldSwitch
{
    if (!_girldSwitch) {
        
        _girldSwitch = [[JYLabelSwitch alloc] initWithTitle:SWITCH_SIZE_LABEL];
        _girldSwitch.switchTag = 41;
        _girldSwitch.delegate = self;
        _girldSwitch.title = [NSString titleChinese:@"九宫格" english:@"Grid"];
        _girldSwitch.mSwitchOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"grladView_hidden"];
        
        [self addSubview:_girldSwitch];
    }
    return _girldSwitch;
}

/** 闪光灯 */
- (JYLabelSwitch *)videoFalshView
{
    if (!_videoFalshView) {
        
        _videoFalshView = [[JYLabelSwitch alloc] initWithTitle:SWITCH_SIZE_LABEL];
        _videoFalshView.switchTag = 42;
        _videoFalshView.delegate = self;
        _videoFalshView.title = [NSString titleChinese:@"录像灯" english:@"VideoFlash"];
        _videoFalshView.switchEnlenble = NO;
        
        [self addSubview:_videoFalshView];
    }
    return _videoFalshView;
}

/** 对比度 */
- (JYCustomSliderView *)alphaSlide
{
    if (!_alphaSlide) {
        
        _alphaSlide = [JYCustomSliderView customSliderViewWithTitle:@"Contrast"];
        _alphaSlide.title = [NSString titleChinese:@"对比度" english:@"Contrast"];
        _alphaSlide.maximumValue = 1;
        _alphaSlide.minimumValue = 0.2;
        _alphaSlide.value = ([[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"] == 0) ? 1 : [[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"];;
        _alphaSlide.sliderEnabled = YES;
        _alphaSlide.delegate = self;
        _alphaSlide.btnModel = CustomSliderNoTitle;
        
        [self addSubview:_alphaSlide];
    }
    return _alphaSlide;
}

- (UIButton *)resetBtn
{
    if (!_resetBtn) {
        
        _resetBtn = [[UIButton alloc] init];
        
        [_resetBtn setTitle:[NSString titleChinese:@"恢复默认设置" english:@"Restore Defaults"] forState:UIControlStateNormal];
        _resetBtn.titleLabel.font = setBoldFont(15);
        [_resetBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        
        [_resetBtn addTarget:self action:@selector(settingViewResetBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_resetBtn];
    }
    return _resetBtn;
}

- (void)setMSwitch:(BOOL)mSwitch
{
    _mSwitch = mSwitch;
    
    self.videoFalshView.switchEnlenble = mSwitch;
}

/** 恢复所有的默认设置 */
- (void)settingViewResetBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingViewResetBtnOnClick:)]) {
        [self.delegate settingViewResetBtnOnClick:btn];
    }
}

#pragma mark -------------------------> 自定义View的代理设置
/** JYLabelSwitchDelegate 摄像头，闪光灯，九宫格 */
- (void)switchOnClick:(UISwitch *)mSwitch
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingViewSwitchOnClick:)]) {
        [self.delegate settingViewSwitchOnClick:mSwitch];
    }
}

/**  JYCustomSliderViewDelegate 设置空间的对比度 */
- (void)customSliderValueChange:(UISlider *)slider
{
    self.layer.opacity = slider.value;
    
    [[NSUserDefaults standardUserDefaults] setFloat:slider.value forKey:@"opacity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingViewCustomSliderValueChange:)]) {
        [self.delegate settingViewCustomSliderValueChange:slider];
    }
}

/** JYLabelDirectionDelegate 选项 */
- (void)labelDirectionBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingViewLabelDirectionBtnOnClick:)]) {
        [self.delegate settingViewLabelDirectionBtnOnClick:btn];
    }
}

- (UIView *)lineView
{
    if (!_lineView) {
        
        _lineView = [[UIView alloc] init];
        
        _lineView.backgroundColor = [UIColor yellowColor];
        
        [self addSubview:_lineView];
    }
    return _lineView;
}

- (void)layoutSubviews
{
    CGFloat viewW = self.width - 2 * JYSpaceWidth;
    
    self.blueDirection.frame = CGRectMake(JYSpaceWidth, 0, viewW, JYCortrolWidth);
    
    self.resolutionDirection.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth, viewW, JYCortrolWidth);
    
    self.fpsDirection.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 2, viewW, JYCortrolWidth);
    self.qualityDirection.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 3, viewW, JYCortrolWidth);
    
    self.languageDirection.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 4, viewW, JYCortrolWidth);
    
    self.direction.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 5, viewW, JYCortrolWidth);
    
    self.lastVideo.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 6, viewW, JYCortrolWidth);
    
    self.chooseDirection.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 7, viewW, JYCortrolWidth);
    
    self.suportDirection.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 8, viewW, JYCortrolWidth);
    
    self.flasView.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 9, viewW, JYCortrolWidth);
    
    self.videoFalshView.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 10, viewW, JYCortrolWidth);
    
    self.girldSwitch.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 11, viewW, JYCortrolWidth);
    
    self.alphaSlide.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 12, viewW, JYCortrolWidth);
    
    self.lineView.frame = CGRectMake(JYSpaceWidth, (JYCortrolWidth * 13) -1, viewW, 1);
    
    self.resetBtn.frame = CGRectMake(JYSpaceWidth, JYCortrolWidth * 13, viewW, JYCortrolWidth);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeLanguage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RestoreDefaults" object:nil];
    
    [[JYSeptManager sharedManager] removeObserver:self forKeyPath:@"perName" context:COREBLUE_NAME];
}

@end
