//
//  JYHandwheelView.m
//  ESAYCAM
//
//  Created by admin on 16/4/27.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYHandwheelView.h"
#import "JYDirectionCell.h"

@interface JYHandwheelView () <JYDirectionCellDelegate>

@property (strong, nonatomic) JYDirectionCell *zhengCell;

@property (strong, nonatomic) JYDirectionCell *fanCell;

@end

@implementation JYHandwheelView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 设置语言切换通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    }
    return self;
}

/** 切换语言 */
- (void)changeLanguage
{
    self.zhengCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"正" value:nil table:@"Localizable"];
    
    self.fanCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"反" value:nil table:@"Localizable"];
    
}

- (JYDirectionCell *)zhengCell
{
    if (!_zhengCell) {
        
        _zhengCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"正" english:@"Positive"]];
        _zhengCell.btnTag = 80;
        _zhengCell.delegate = self;
        _zhengCell.tag = 70;
        _zhengCell.imageHidden = NO;
        
        [self addSubview:_zhengCell];
    }
    return _zhengCell;
}

- (JYDirectionCell *)fanCell
{
    if (!_fanCell) {
        
        _fanCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"反" english:@"Negative"]];
        _fanCell.btnTag = 81;
        _fanCell.delegate = self;
        _fanCell.tag = 71;
        _fanCell.imageHidden = YES;
        
        [self addSubview:_fanCell];
    }
    return _fanCell;
}

- (void)directionCellBtnOnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 80:
            self.fanCell.imageHidden = YES;
            self.zhengCell.imageHidden = NO;
            break;
        case 81:
            self.fanCell.imageHidden = NO;
            self.zhengCell.imageHidden = YES;
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(handwheelDirectionCellBtnOnClick:)]) {
        [self.delegate handwheelDirectionCellBtnOnClick:btn];
    }
}

- (void)layoutSubviews
{
    self.zhengCell.frame = CGRectMake(JYSpaceWidth, (self.height - 2 * JYCortrolWidth) / 2, self.width - JYSpaceWidth, JYCortrolWidth);
    
    self.fanCell.frame = CGRectMake(JYSpaceWidth, self.zhengCell.y + JYCortrolWidth, self.width - JYSpaceWidth, JYCortrolWidth);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeLanguage" object:nil];
}

@end