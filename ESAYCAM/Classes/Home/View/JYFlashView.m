//
//  JYFlashView.m
//  ESAYCAM
//
//  Created by Sept on 16/5/7.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYFlashView.h"
#import "JYDirectionCell.h"

@interface JYFlashView () <JYDirectionCellDelegate>

@property (strong, nonatomic) JYDirectionCell *onCell;

@property (strong, nonatomic) JYDirectionCell *offCell;

@property (strong, nonatomic) JYDirectionCell *autoCell;

//@property (strong, nonatomic) NSString *sizeText;

@end

@implementation JYFlashView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    }
    return self;
}

//- (instancetype)initWithTitle:(NSString *)lableText
//{
//    self = [super init];
//    if (self) {
//        
//        self.sizeText = lableText;
//        
//        self.backgroundColor = [UIColor clearColor];
//    }
//    return self;
//}

- (void)changeLanguage
{
    self.autoCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"自动" value:nil table:@"Localizable"];
    
    self.onCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"开启" value:nil table:@"Localizable"];
    
    self.offCell.title = [[JYLanguageTool bundle] localizedStringForKey:@"关闭" value:nil table:@"Localizable"];
}

- (JYDirectionCell *)autoCell
{
    if (!_autoCell) {
        
        _autoCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"自动" english:@"Auto"]];
        _autoCell.btnTag = 100;
        _autoCell.delegate = self;
        _autoCell.tag = 110;
        
        [self addSubview:_autoCell];
    }
    return _autoCell;
}

- (JYDirectionCell *)onCell
{
    if (!_onCell) {
        
        _onCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"开启" english:@"On"]];
        _onCell.btnTag = 101;
        _onCell.delegate = self;
        _onCell.tag = 111;
        
        [self addSubview:_onCell];
    }
    return _onCell;
}

- (JYDirectionCell *)offCell
{
    if (!_offCell) {
        
        _offCell = [[JYDirectionCell alloc] initWithTitle:[NSString titleChinese:@"关闭" english:@"Off"]];
        _offCell.btnTag = 102;
        _offCell.delegate = self;
        _offCell.tag = 112;
        
        [self addSubview:_offCell];
    }
    return _offCell;
}

- (void)directionCellBtnOnClick:(UIButton *)btn
{
    for (int i = 110; i < 113; i ++) {
        JYDirectionCell *cell = (JYDirectionCell *)[self viewWithTag: i];
        cell.imageHidden = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(flashViewCellBtnOnClick:)]) {
        [self.delegate flashViewCellBtnOnClick:btn];
    }
}

- (void)cameraLensViewShowOneCell
{
//    self.twoCell.imageHidden = YES;
//    self.threeCell.imageHidden = YES;
//    self.oneCell.imageHidden = NO;
}

- (void)layoutSubviews
{
    CGFloat y = (self.height - 3 * JYCortrolWidth) * 0.5;
    
    self.autoCell.frame = CGRectMake(JYSpaceWidth, y + JYCortrolWidth * 0, self.width - JYSpaceWidth, JYCortrolWidth);
    
    self.onCell.frame = CGRectMake(JYSpaceWidth, y + JYCortrolWidth * 1, self.width - JYSpaceWidth, JYCortrolWidth);
    
    self.offCell.frame = CGRectMake(JYSpaceWidth, y + JYCortrolWidth * 2, self.width - JYSpaceWidth, JYCortrolWidth);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
