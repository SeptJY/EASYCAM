//
//  JYQualityView.h
//  ESAYCAM
//
//  Created by admin on 16/5/13.
//  Copyright © 2016年 九月. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JYQualityViewDelegate <NSObject>

@optional
- (void)qualityBtnOnClick:(UIButton *)btn;

@end

@interface JYQualityView : UIView

@property (weak, nonatomic) id<JYQualityViewDelegate> delegate;

@end
