//
//  JYBaisSlider.m
//  ESAYCAM
//
//  Created by Sept on 16/5/19.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYBaisSlider.h"
#import "ASValueTrackingSlider.h"

// 控件高度
#define HEIGHT_SUBVIEWS 20
// 间隙宽度
#define SPACE_WIDTH 8

@interface JYBaisSlider ()

@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) ASValueTrackingSlider *slider;

@property (strong, nonatomic) UIButton *btn;

@property (strong, nonatomic) NSString *sizeTitle;

@end

@implementation JYBaisSlider

+ (instancetype)customSliderViewWithTitle:(NSString *)sizeTitle
{
    return [[self alloc] initWithTitle:sizeTitle];
}

- (instancetype)initWithTitle:(NSString *)sizeTitle
{
    self = [super init];
    if (self) {
        
        self.sizeTitle = sizeTitle;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    }
    return self;
}

/** 切换语言 */
- (void)changeLanguage
{
    [self.btn setTitle:[[JYLanguageTool bundle] localizedStringForKey:self.btn.currentTitle value:nil table:@"Localizable"] forState:UIControlStateSelected];
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

- (UILabel *)label
{
    if (!_label) {
        
        _label = [[UILabel alloc] init];
        
        _label.font = setBoldFont(15);
        _label.textColor = [UIColor yellowColor];
        _label.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:_label];
    }
    return _label;
}

- (UIButton *)btn
{
    if (!_btn) {
        
        _btn = [[UIButton alloc] init];
        
        [_btn setBackgroundColor:[UIColor yellowColor]];
        _btn.titleLabel.font = setFont(10);
        [_btn setTitleColor:setColor(127, 127, 127) forState:UIControlStateSelected];
        [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [_btn setTitle:[NSString titleChinese:@"重置" english:@"Reset"] forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(customSliderAutoBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        _btn.selected = YES;
        
        [self addSubview:_btn];
    }
    return _btn;
}

- (void)customSliderAutoBtnOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(baisSliderAutoBtnOnClick:)]) {
        [self.delegate baisSliderAutoBtnOnClick:btn];
    }
    
    self.slider.value = 0.0;
}

- (ASValueTrackingSlider *)slider
{
    if (!_slider) {
        
        _slider = [[ASValueTrackingSlider alloc] init];
        
        [_slider setThumbImage:[UIImage imageWithImage:[UIImage imageNamed:@"home_slider_thump_icon"] scaledToWidth:15] forState:UIControlStateNormal];
        
        [_slider setThumbImage:[UIImage imageWithImage:[UIImage imageNamed:@"home_slider_thump_icon"] scaledToWidth:15] forState:UIControlStateHighlighted];
//        _slider.tintColor = [UIColor yellowColor];
        [_slider addTarget:self action:@selector(customSliderValueChange:) forControlEvents:UIControlEventValueChanged];
        
        _slider.popUpViewColor = [UIColor yellowColor];
        _slider.font = [UIFont fontWithName:@"Menlo-Bold" size:15];
        _slider.textColor = setColor(102, 102, 102);
        
        [self addSubview:_slider];
    }
    return _slider;
}

/** 设置slider的最 大 值 */
- (void)setMaximumValue:(CGFloat)maximumValue
{
    _maximumValue = maximumValue;
    
    self.slider.maximumValue = maximumValue;
}

/** 设置slider的最 小 值 */
- (void)setMinimumValue:(CGFloat)minimumValue
{
    _minimumValue = minimumValue;
    
    self.slider.minimumValue = minimumValue;
}

/** 设置slider的当前值 */
- (void)setValue:(CGFloat)value
{
    _value = value;
    
    self.slider.value = value;
}

/** 设置label的text */
- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.label.text = title;
}

- (void)customSliderValueChange:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(baisSliderValueChange:)]) {
        [self.delegate baisSliderValueChange:slider];
    }
}

- (void)layoutSubviews
{
    // 1.设置label的frame
    CGSize labelSize = [NSString sizeWithText:self.sizeTitle font:self.label.font maxSize:CGSizeMake(100, 50)];
    
    self.label.frame = CGRectMake(10, (self.height - labelSize.height) * 0.5, labelSize.width, labelSize.height);
    
    // 2.设置竖线的frame
    CGFloat lineX = self.label.x + self.label.width + SPACE_WIDTH;
    CGFloat lineY = (self.height - HEIGHT_SUBVIEWS) * 0.5;
    CGFloat lineW = 2;
    CGFloat lineH = HEIGHT_SUBVIEWS;
    
    self.lineView.frame = CGRectMake(lineX, lineY, lineW, lineH);
    
    // 3.设置button的frame
    CGFloat btnW = HEIGHT_SUBVIEWS * 16 / 9;
    CGFloat btnH = HEIGHT_SUBVIEWS;
    CGFloat btnX = self.width - btnW - SPACE_WIDTH;
    CGFloat btnY = self.lineView.y;
    
    self.btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    
    // 设置slider的frame
    CGFloat sliderX = self.lineView.x - 1;
    CGFloat sliderY = (self.height - 31) * 0.5 - 0.5;
    CGFloat sliderW = self.btn.x - self.lineView.x + 3;
    CGFloat sliderH = 31;
    
    self.slider.frame = CGRectMake(sliderX, sliderY, sliderW, sliderH);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeLanguage" object:nil];
}

@end