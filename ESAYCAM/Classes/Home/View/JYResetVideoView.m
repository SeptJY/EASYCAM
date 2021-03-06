//
//  JYResetVideoView.m
//  Esaycamera
//
//  Created by Sept on 16/4/20.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYResetVideoView.h"
#import "JYDirectionCell.h"

@interface JYResetVideoView () <JYDirectionCellDelegate>

@property (strong, nonatomic) JYDirectionCell *oneCell;

@property (strong, nonatomic) JYDirectionCell *twoCell;

@end

@implementation JYResetVideoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 设置语言切换通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreDefaults) name:@"RestoreDefaults" object:nil];
    }
    return self;
}

- (void)restoreDefaults
{
    self.oneCell.imageHidden = NO;
    self.twoCell.imageHidden = YES;
}

/** 切换语言 */
- (void)changeLanguage
{
    self.oneCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"两点" value:nil table:@"Localizable"];
    
    self.twoCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"实时" value:nil table:@"Localizable"];
    
}

- (JYDirectionCell *)oneCell
{
    if (!_oneCell) {
        
        _oneCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"两点" english:@"Linear"]];
        _oneCell.btnTag = 80;
        _oneCell.delegate = self;
        _oneCell.tag = 70;
        _oneCell.imageHidden = [[NSUserDefaults standardUserDefaults] boolForKey:@"ResetVideo"];
        
        [self addSubview:_oneCell];
    }
    return _oneCell;
}

- (JYDirectionCell *)twoCell
{
    if (!_twoCell) {
        
        _twoCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"实时" english:@"RealTime"]];
        _twoCell.btnTag = 81;
        _twoCell.delegate = self;
        _twoCell.tag = 71;
        _twoCell.imageHidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"ResetVideo"];;
        
        [self addSubview:_twoCell];
    }
    return _twoCell;
}

- (void)directionCellBtnOnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 80:
            self.twoCell.imageHidden = YES;
            self.oneCell.imageHidden = NO;
            break;
        case 81:
            self.twoCell.imageHidden = NO;
            self.oneCell.imageHidden = YES;
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(resetVideoDirectionCellBtnOnClick:)]) {
        [self.delegate resetVideoDirectionCellBtnOnClick:btn];
    }
}

- (void)layoutSubviews
{
    self.oneCell.frame = CGRectMake(JYSpaceWidth, (self.height - 2 * JYCortrolWidth) / 2, self.width - JYSpaceWidth, JYCortrolWidth);
    
    self.twoCell.frame = CGRectMake(JYSpaceWidth, self.oneCell.y + JYCortrolWidth, self.width - JYSpaceWidth, JYCortrolWidth);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeLanguage" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RestoreDefaults" object:nil];
}

@end
