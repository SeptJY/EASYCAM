//
//  JYQuickView.m
//  ESAYCAM
//
//  Created by Sept on 16/4/28.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYQuickView.h"

@interface JYQuickView ()

@property (strong, nonatomic) UIImageView *bgImgView;

@property (strong, nonatomic) UIButton *focusBtn;

@property (strong, nonatomic) UIButton *zoomBtn;

@end

@implementation JYQuickView

- (UIImageView *)bgImgView
{
    if (!_bgImgView) {
        
        _bgImgView = [[UIImageView alloc] init];
        
        _bgImgView.image = [UIImage imageNamed:@"quick_bg"];
        
        [self addSubview:_bgImgView];
    }
    return _bgImgView;
}

- (UIButton *)focusBtn
{
    if (!_focusBtn) {
        
        _focusBtn = [[UIButton alloc] init];
        
        [_focusBtn setImage:[UIImage imageNamed:@"MF"] forState:UIControlStateNormal];
        [_focusBtn setImage:[UIImage imageNamed:@"MF_on"] forState:UIControlStateSelected];
        _focusBtn.tag = 10;
        _focusBtn.selected = YES;
        
        [_focusBtn addTarget:self action:@selector(focusAndZoomBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_focusBtn];
    }
    return _focusBtn;
}

- (UIButton *)zoomBtn
{
    if (!_zoomBtn) {
        
        _zoomBtn = [[UIButton alloc] init];
        
        [_zoomBtn setImage:[UIImage imageNamed:@"ZM"] forState:UIControlStateNormal];
        [_zoomBtn setImage:[UIImage imageNamed:@"ZM_on"] forState:UIControlStateSelected];
        _zoomBtn.tag = 11;
        
        [_zoomBtn addTarget:self action:@selector(focusAndZoomBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_zoomBtn];
    }
    return _zoomBtn;
}

- (void)focusAndZoomBtnOnClick:(UIButton *)btn
{
    if (btn.selected == 0) {
        btn.selected = !btn.selected;
    }
    switch (btn.tag) {
        case 10:   // Focus
            self.zoomBtn.selected = !btn.selected;
            break;
        case 11:   // Zoom
            self.focusBtn.selected = !btn.selected;
            break;
    }
}

- (void)layoutSubviews
{
    self.bgImgView.frame = CGRectMake(0, 0, self.width, 80);
    
    CGFloat btnWH = 30;
    self.focusBtn.frame = CGRectMake(4, 4, btnWH, btnWH);
    
    self.zoomBtn.frame = CGRectMake(4, 80 - btnWH - 4, btnWH, btnWH);
}

@end
