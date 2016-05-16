//
//  JYQualityView.m
//  ESAYCAM
//
//  Created by admin on 16/5/13.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYQualityView.h"

#import "JYDirectionCell.h"

@interface JYQualityView () <JYDirectionCellDelegate>

@property (strong, nonatomic) JYDirectionCell *highCell;

@property (strong, nonatomic) JYDirectionCell *lowCell;

@property (strong, nonatomic) JYDirectionCell *mediaCell;

@property (strong, nonatomic) JYDirectionCell *defautlCell;

@end

@implementation JYQualityView

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
    self.lowCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"低" value:nil table:@"Localizable"];
    
    self.defautlCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"标准" value:nil table:@"Localizable"];
    
    self.mediaCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"中" value:nil table:@"Localizable"];
    
    self.highCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"高" value:nil table:@"Localizable"];
    
}

- (JYDirectionCell *)lowCell
{
    if (!_lowCell) {
        
        _lowCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"低" english:@"Low"]];
        _lowCell.btnTag = 80;
        _lowCell.delegate = self;
        _lowCell.tag = 70;
        _lowCell.imageHidden = YES;
        
        [self addSubview:_lowCell];
    }
    return _lowCell;
}

- (JYDirectionCell *)defautlCell
{
    if (!_defautlCell) {
        
        _defautlCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"标准" english:@"Standard"]];
        _defautlCell.btnTag = 81;
        _defautlCell.delegate = self;
        _defautlCell.tag = 71;
        _defautlCell.imageHidden = NO;
        
        [self addSubview:_defautlCell];
    }
    return _defautlCell;
}

- (JYDirectionCell *)mediaCell
{
    if (!_mediaCell) {
        
        _mediaCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"中" english:@"Medium"]];
        _mediaCell.btnTag = 82;
        _mediaCell.delegate = self;
        _mediaCell.tag = 72;
        _mediaCell.imageHidden = YES;
        
        [self addSubview:_mediaCell];
    }
    return _mediaCell;
}

- (JYDirectionCell *)highCell
{
    if (!_highCell) {
        
        _highCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"高" english:@"High"]];
        _highCell.btnTag = 83;
        _highCell.delegate = self;
        _highCell.tag = 73;
        _highCell.imageHidden = YES;
        
        [self addSubview:_highCell];
    }
    return _highCell;
}

- (void)directionCellBtnOnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 80:
            self.lowCell.imageHidden = NO;
            self.highCell.imageHidden = YES;
            self.defautlCell.imageHidden = YES;
            self.mediaCell.imageHidden = YES;
            break;
        case 81:
            self.lowCell.imageHidden = YES;
            self.highCell.imageHidden = YES;
            self.defautlCell.imageHidden = NO;
            self.mediaCell.imageHidden = YES;
            break;
        case 82:
            self.lowCell.imageHidden = YES;
            self.highCell.imageHidden = YES;
            self.defautlCell.imageHidden = YES;
            self.mediaCell.imageHidden = NO;
            break;
        case 83:
            self.lowCell.imageHidden = YES;
            self.highCell.imageHidden = NO;
            self.defautlCell.imageHidden = YES;
            self.mediaCell.imageHidden = YES;
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(qualityBtnOnClick:)]) {
        [self.delegate qualityBtnOnClick:btn];
    }
}

- (void)layoutSubviews
{
    self.lowCell.frame = CGRectMake(JYSpaceWidth, (self.height - 4 * JYCortrolWidth) / 2, self.width - JYSpaceWidth, JYCortrolWidth);
    
    self.defautlCell.frame = CGRectMake(JYSpaceWidth, self.lowCell.y + JYCortrolWidth, self.width - JYSpaceWidth, JYCortrolWidth);
    self.mediaCell.frame = CGRectMake(JYSpaceWidth, self.defautlCell.y + JYCortrolWidth, self.width - JYSpaceWidth, JYCortrolWidth);
    
    self.highCell.frame = CGRectMake(JYSpaceWidth, self.mediaCell.y + JYCortrolWidth, self.width - JYSpaceWidth, JYCortrolWidth);
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeLanguage" object:nil];
}

@end

