//
//  JYExpsureView.m
//  SeptOnCamera
//
//  Created by Sept on 16/1/19.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYExpsureView.h"
#import "JYBaisSlider.h"

#define SLIDER_COUNT 4

static void *SeptManagerBaisValue = &SeptManagerBaisValue;
static void *SeptManagerISOValue = &SeptManagerISOValue;
static void *SeptManagerTimeValue = &SeptManagerTimeValue;
static void *SeptManagerOffsetValue = &SeptManagerOffsetValue;
static void *JYSELFHIDDEN = &JYSELFHIDDEN;

@interface JYExpsureView () <JYCustomSliderViewDelegate, JYBaisSliderDelegate>

@property (strong, nonatomic) JYBaisSlider *baisSlider;

@property (strong, nonatomic) JYBaisSlider *ISOSlider;

@property (strong, nonatomic) JYBaisSlider *timeSlider;

//@property (strong, nonatomic) JYCustomSliderView *offSetSlider;

@property (assign, nonatomic) CGFloat widthBtn;

@end

@implementation JYExpsureView

- (instancetype)initWithWidth:(CGFloat)width

{
    self = [super init];
    if (self) {
        
        self.widthBtn = width;
//        [self addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:JYSELFHIDDEN];
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"offsetValue" options:NSKeyValueObservingOptionNew context:SeptManagerOffsetValue];
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"baisValue" options:NSKeyValueObservingOptionNew context:SeptManagerBaisValue];
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"ISOValue" options:NSKeyValueObservingOptionNew context:SeptManagerISOValue];
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"timeValue" options:NSKeyValueObservingOptionNew context:SeptManagerTimeValue];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
        
        [self createWetherButton];
    }
    return self;
}

/** 语言切换 */
- (void)changeLanguage
{
    self.baisSlider.title = [[JYLanguageTool bundle] localizedStringForKey:@"曝光补偿" value:nil table:@"Localizable"];
    
    self.ISOSlider.title = [[JYLanguageTool bundle] localizedStringForKey:@"感光度" value:nil table:@"Localizable"];
    
    self.timeSlider.title = [[JYLanguageTool bundle] localizedStringForKey:@"曝光时间" value:nil table:@"Localizable"];
    
//    self.offSetSlider.title = [[JYLanguageTool bundle] localizedStringForKey:@"曝光偏移" value:nil table:@"Localizable"];
}

/**
 @property (assign, nonatomic) CGFloat baisValue;
 
 @property (assign, nonatomic) CGFloat ISOValue;
 
 @property (assign, nonatomic) CGFloat SeptManagerTimeValue;
 
 @property (assign, nonatomic) CGFloat focusValue;
 
 @property (assign, nonatomic) CGFloat offsetValue;
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == SeptManagerOffsetValue) {
//        self.offSetSlider.value = [JYSeptManager sharedManager].offsetValue;
    } else if (context == SeptManagerBaisValue) {
        self.baisSlider.value = [JYSeptManager sharedManager].baisValue;
    } else if (context == SeptManagerISOValue) {
        self.ISOSlider.value = [JYSeptManager sharedManager].ISOValue;
    } else if (context == SeptManagerTimeValue) {
        self.timeSlider.value = [JYSeptManager sharedManager].timeValue;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -------------------------> 懒加载baisSlider、ISOSlider、timeSlider、offSetSlider
//- (JYCustomSliderView *)offSetSlider
//{
//    if (!_offSetSlider) {
//        
//        _offSetSlider = [JYCustomSliderView customSliderViewWithTitle:@"曝光偏移"];
//        _offSetSlider.delegate = self;
//        _offSetSlider.maximumValue = 8;
//        _offSetSlider.minimumValue = -8;
//        _offSetSlider.value = 0.5;
//        _offSetSlider.title = [NSString titleChinese:@"曝光偏移" english:@"Offset"];
//        _offSetSlider.sliderTag = 60;
//        _offSetSlider.btnEnabled = NO;
//        
//        [self addSubview:_offSetSlider];
//    }
//    return _offSetSlider;
//}

- (JYBaisSlider *)ISOSlider
{
    if (!_ISOSlider) {
        
        _ISOSlider = [[JYBaisSlider alloc] initWithTitle:@"曝光偏移" buttonType:JYButtonTypeAutoAndLock show:JYShowTypeOhters];
        _ISOSlider.delegate = self;
        _ISOSlider.maximumValue = 640;
        _ISOSlider.minimumValue = 50;
//        _ISOSlider.value = 0.5;
        _ISOSlider.title = [NSString titleChinese:@"感光度" english:@"ISO"];
        _ISOSlider.sliderTag = 12;
        
        [self addSubview:_ISOSlider];
    }
    return _ISOSlider;
}

- (JYBaisSlider *)timeSlider
{
    if (!_timeSlider) {
        
        _timeSlider = [[JYBaisSlider alloc] initWithTitle:@"曝光偏移" buttonType:JYButtonTypeAutoAndLock show:JYShowTypeOhters];
        _timeSlider.delegate = self;
        _timeSlider.maximumValue = 1;
        _timeSlider.minimumValue = 0;
//        _timeSlider.value = 0.5;
        _timeSlider.sliderTag = 11;
        _timeSlider.title = [NSString titleChinese:@"曝光时间" english:@"Time"];
//        _timeSlider.sliderTag = 62;
        
        [self addSubview:_timeSlider];
    }
    return _timeSlider;
}

- (JYBaisSlider *)baisSlider
{
    if (!_baisSlider) {
        
        _baisSlider = [[JYBaisSlider alloc] initWithTitle:@"曝光偏移" buttonType:JYButtonTypeReset show:JYShowTypeExposure];
        _baisSlider.delegate = self;
        _baisSlider.maximumValue = 900;
        _baisSlider.minimumValue = -900;
        _baisSlider.value = 0;
        _baisSlider.sliderTag = 10;
        _baisSlider.title = [NSString titleChinese:@"曝光补偿" english:@"EV"];
        
        [self addSubview:_baisSlider];
    }
    return _baisSlider;
}

- (void)exposureSetCustomSliderValue:(CGFloat)value andCustomSliderTag:(NSInteger)tag
{
    switch (tag) {
        case 60:   // 曝光偏移
//            self.offSetSlider.value = value;
            break;
        case 61:   // 感光度
            self.ISOSlider.value = value;
            break;
        case 62:   // 曝光时间
            self.timeSlider.value = value;
            break;
        case 63:   // 曝光补偿
            self.baisSlider.value = value;
            break;
            
        default:
            break;
    }
}

- (void)baisSliderValueChange:(UISlider *)slider
{
    switch (slider.tag) {
        case 10:
        {
            if (slider.value >= -50 && slider.value < 50) {
                slider.value = 0;
            } else if (slider.value >= 50 && slider.value < 150)
            {
                slider.value = 100;
            } else if (slider.value >= 150 && slider.value < 250)
            {
                slider.value = 200;
            } else if (slider.value > 250 && slider.value <= 350)
            {
                slider.value = 300;
            } else if (slider.value > 350 && slider.value <= 450)
            {
                slider.value = 300;
            } else if (slider.value >= 450 && slider.value < 550)
            {
                slider.value = 500;
            } else if (slider.value >= 550 && slider.value < 650)
            {
                slider.value = 600;
            } else if (slider.value >= 650 && slider.value < 750)
            {
                slider.value = 700;
            } else if (slider.value >= 750 && slider.value < 850)
            {
                slider.value = 800;
            } else if (slider.value >= 850)
            {
                slider.value = 900;
            }
            else if (slider.value > -150 && slider.value <= -50)
            {
                slider.value = -100;
            } else if (slider.value > -250 && slider.value <= -150)
            {
                slider.value = -200;
            } else if (slider.value > -350 && slider.value <= -250)
            {
                slider.value = -300;
            } else if (slider.value > -450 && slider.value <= -350)
            {
                slider.value = -400;
            } else if (slider.value > -550 && slider.value <= -450)
            {
                slider.value = -500;
            } else if (slider.value > -650 && slider.value <= -550)
            {
                slider.value = -600;
            } else if (slider.value > -750 && slider.value <= -650)
            {
                slider.value = -700;
            } else if (slider.value > -850 && slider.value <= -750)
            {
                slider.value = -800;
            } else if (slider.value <= -850)
            {
                slider.value = -900;
            }
        }
            break;
        case 11:
            break;
        case 12:
        {
            int value = (int)slider.value;
            if (value <= 75) {
                slider.value = 50;
            } else if (value > 75 && value <= 113) {
                slider.value = 100;
            } else if (value > 113 && value <= 140) {
                slider.value = 125;
            } else if (value > 140 && value <= 180) {
                slider.value = 160;
            } else if (value > 180 && value <= 222) {
                slider.value = 200;
            } else if (value > 222 && value <= 285) {
                slider.value = 250;
            } else if (value > 285 && value <= 360) {
                slider.value = 320;
            } else if (value > 360 && value <= 450) {
                slider.value = 400;
            } else if (value > 450 && value <= 570) {
                slider.value = 500;
            } else if (value > 570) {
                slider.value = 640;
            }
        }
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(baisSliderValueChange:)]) {
        [self.delegate baisSliderValueChange:slider];
    }
}

- (CGFloat)segmentReturnValue:(CGFloat)value
{
    
    
    
    return value;
}

- (void)baisSliderAutoBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(baisSliderAutoBtnOnClick:)]) {
        [self.delegate baisSliderAutoBtnOnClick:btn];
    }
}

#pragma mark -------------------------> JYCustomSliderViewDelegate
- (void)customSliderValueChange:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(expsureViewCustomSliderValueChange:)]) {
        [self.delegate expsureViewCustomSliderValueChange:slider];
    }
}

- (void)customSliderAutoBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(expsureViewCustomSliderAutoBtnOnClick:)]) {
        [self.delegate expsureViewCustomSliderAutoBtnOnClick:btn];
    }
}

#pragma mark -------------------------> 创建气候按钮
/** 创建五个按钮 -- 气候 */
- (void)createWetherButton
{
    NSArray *titleArray = @[@"logo_view", @"logo_person", @"logo_night",  @"logo_HDR", @"logo_again", @"A"];
    
    CGFloat btnW = 30;
    CGFloat btnH = btnW;
    CGFloat btnY = 10;
    CGFloat space = (self.widthBtn - titleArray.count * btnW) / (titleArray.count + 1);
    
    for (int i = 0; i < titleArray.count; i ++) {
        
        CGFloat btnX = space + i * (btnW + space);
        
        UIButton *btn = [[UIButton alloc] init];
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        btn.backgroundColor = [UIColor yellowColor];
        btn.layer.cornerRadius = btnW / 2;
        btn.alpha = (i == titleArray.count - 1) ? 1 : 0.4;
        btn.tag = 70 + i;
        [btn setImage:[UIImage imageNamed:titleArray[i]] forState:UIControlStateNormal];

//        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
//        btn.titleLabel.font = setFont(10);
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(exposureFiveXiaoGuoButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
    }
}

- (void)exposureFiveXiaoGuoButtonOnClick:(UIButton *)btn
{
    // 1.设置代理，在homeCtl中设置白平衡的模式为手动
    if (self.delegate && [self.delegate respondsToSelector:@selector(exposureFiveXiaoGuoButtonOnClick:)]) {
        [self.delegate exposureFiveXiaoGuoButtonOnClick:btn];
    }
    // 2.遍历所有按钮的背景亮度为0.4
    for (int i = 0; i < 6; i ++) {
        UIButton *allBtn = [self viewWithTag:70 + i];
        allBtn.alpha = 0.4;
    }
    // 当前点击的按钮背景亮度为1.0
    btn.alpha = 1.0;
}

#pragma mark -------------------------> 设置frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIButton *btn = [self viewWithTag:70];
    
    CGFloat sliderH = 50;
    CGFloat space_height = (self.height - (btn.y + btn.height + 20) - 3 * sliderH) / 2;
    
    CGFloat sliderY = btn.y + btn.height + 10;
    // 色温
    self.baisSlider.frame = CGRectMake(0, sliderY, self.width, sliderH);
    
    // 色调
    self.ISOSlider.frame = CGRectMake(0, sliderY + (sliderH + space_height), self.width, sliderH);
    
    // 饱和度
    self.timeSlider.frame = CGRectMake(0, sliderY + (sliderH + space_height) * 2, self.width, sliderH);
}

#if 0
/** 手动或自动按钮的点击事件 */
- (void)exposureAutoBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(exposureAutoBtnOnClick:)]) {
        [self.delegate exposureAutoBtnOnClick:btn];
    }
    
    self.timeSlider.enabled = !self.timeSlider.enabled;
    
    self.isoSlider.enabled = !self.isoSlider.enabled;
    
    self.timeBtn.selected = !btn.selected;
    self.isoBtn.selected = self.timeBtn.selected;
    
    if (!self.isoBtn.selected) {
        [JYSeptManager sharedManager].isAutoFocus = YES;
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"ISOValue" options:NSKeyValueObservingOptionNew context:SeptManagerISOValue];
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"timeValue" options:NSKeyValueObservingOptionNew context:SeptManagerTimeValue];
    } else
    {
        [JYSeptManager sharedManager].isAutoFocus = NO;
        [[JYSeptManager sharedManager] removeObserver:self forKeyPath:@"ISOValue" context:SeptManagerISOValue];
        
        [[JYSeptManager sharedManager] removeObserver:self forKeyPath:@"timeValue" context:SeptManagerTimeValue];
    }
}
#endif

- (void)dealloc
{
    [[JYSeptManager sharedManager] removeObserver:self forKeyPath:@"ISOValue" context:SeptManagerISOValue];
    [[JYSeptManager sharedManager] removeObserver:self forKeyPath:@"timeValue" context:SeptManagerTimeValue];
    
    [[JYSeptManager sharedManager] removeObserver:self forKeyPath:@"offsetValue" context:SeptManagerOffsetValue];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
