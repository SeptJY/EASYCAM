//
//  JYExpsureView.m
//  SeptOnCamera
//
//  Created by Sept on 16/1/19.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYExpsureView.h"

#define SLIDER_COUNT 4

static void *SeptManagerBaisValue = &SeptManagerBaisValue;
static void *SeptManagerISOValue = &SeptManagerISOValue;
static void *SeptManagerTimeValue = &SeptManagerTimeValue;
static void *SeptManagerOffsetValue = &SeptManagerOffsetValue;
static void *JYSELFHIDDEN = &JYSELFHIDDEN;

@interface JYExpsureView () <JYCustomSliderViewDelegate>

@property (strong, nonatomic) JYCustomSliderView *baisSlider;

@property (strong, nonatomic) JYCustomSliderView *ISOSlider;

@property (strong, nonatomic) JYCustomSliderView *timeSlider;

@property (strong, nonatomic) JYCustomSliderView *offSetSlider;

@end

@implementation JYExpsureView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        [self addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:JYSELFHIDDEN];
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"offsetValue" options:NSKeyValueObservingOptionNew context:SeptManagerOffsetValue];
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"baisValue" options:NSKeyValueObservingOptionNew context:SeptManagerBaisValue];
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"ISOValue" options:NSKeyValueObservingOptionNew context:SeptManagerISOValue];
        [[JYSeptManager sharedManager] addObserver:self forKeyPath:@"timeValue" options:NSKeyValueObservingOptionNew context:SeptManagerTimeValue];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    }
    return self;
}

/** 语言切换 */
- (void)changeLanguage
{
    self.baisSlider.title = [[JYLanguageTool bundle] localizedStringForKey:@"曝光偏移" value:nil table:@"Localizable"];
    
    self.ISOSlider.title = [[JYLanguageTool bundle] localizedStringForKey:@"感光度" value:nil table:@"Localizable"];
    
    self.timeSlider.title = [[JYLanguageTool bundle] localizedStringForKey:@"曝光时间" value:nil table:@"Localizable"];
    
    self.offSetSlider.title = [[JYLanguageTool bundle] localizedStringForKey:@"曝光补偿" value:nil table:@"Localizable"];
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
        self.offSetSlider.value = [JYSeptManager sharedManager].offsetValue;
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
- (JYCustomSliderView *)offSetSlider
{
    if (!_offSetSlider) {
        
        _offSetSlider = [JYCustomSliderView customSliderViewWithTitle:@"曝光偏移"];
        _offSetSlider.delegate = self;
        _offSetSlider.maximumValue = 8;
        _offSetSlider.minimumValue = -8;
        _offSetSlider.value = 0.5;
        _offSetSlider.title = [NSString titleChinese:@"曝光偏移" english:@"Offset"];
        _offSetSlider.sliderTag = 60;
        _offSetSlider.btnEnabled = NO;
        
        [self addSubview:_offSetSlider];
    }
    return _offSetSlider;
}

- (JYCustomSliderView *)ISOSlider
{
    if (!_ISOSlider) {
        
        _ISOSlider = [JYCustomSliderView customSliderViewWithTitle:@"曝光偏移"];
        _ISOSlider.delegate = self;
        _ISOSlider.maximumValue = 736;
        _ISOSlider.minimumValue = 46;
//        _ISOSlider.value = 0.5;
        _ISOSlider.title = [NSString titleChinese:@"感光度" english:@"ISO"];
        _ISOSlider.sliderTag = 61;
        
        [self addSubview:_ISOSlider];
    }
    return _ISOSlider;
}

- (JYCustomSliderView *)timeSlider
{
    if (!_timeSlider) {
        
        _timeSlider = [JYCustomSliderView customSliderViewWithTitle:@"曝光偏移"];
        _timeSlider.delegate = self;
        _timeSlider.maximumValue = 1;
        _timeSlider.minimumValue = 0;
//        _timeSlider.value = 0.5;
        _timeSlider.title = [NSString titleChinese:@"曝光时间" english:@"Time"];
        _timeSlider.sliderTag = 62;
        
        [self addSubview:_timeSlider];
    }
    return _timeSlider;
}

- (JYCustomSliderView *)baisSlider
{
    if (!_baisSlider) {
        
        _baisSlider = [JYCustomSliderView customSliderViewWithTitle:@"曝光偏移"];
        _baisSlider.delegate = self;
        _baisSlider.maximumValue = 8;
        _baisSlider.minimumValue = -8;
        _baisSlider.value = 0.5;
        _baisSlider.title = [NSString titleChinese:@"曝光补偿" english:@"EV"];
        _baisSlider.sliderTag = 63;
        _baisSlider.sliderEnabled = YES;
        _baisSlider.btnModel = CustomSliderReset;
        
        [self addSubview:_baisSlider];
    }
    return _baisSlider;
}

- (void)exposureSetCustomSliderValue:(CGFloat)value andCustomSliderTag:(NSInteger)tag
{
    switch (tag) {
        case 60:   // 曝光偏移
            self.offSetSlider.value = value;
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

#pragma mark -------------------------> 设置frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat sliderH = 50;
    
    CGFloat space_height = (self.height - SLIDER_COUNT * sliderH) / (SLIDER_COUNT - 1);
    
    self.offSetSlider.frame = CGRectMake(0, 10, self.width, sliderH);
    
    self.ISOSlider.frame = CGRectMake(0, 10 + sliderH + space_height, self.width, sliderH);
    
    self.timeSlider.frame = CGRectMake(0, 10 + (sliderH + space_height) * 2, self.width, sliderH);
    
    self.baisSlider.frame = CGRectMake(0, 10 + (sliderH + space_height) * 3, self.width, sliderH);
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
