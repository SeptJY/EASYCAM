//
//  JYFlashView.h
//  ESAYCAM
//
//  Created by Sept on 16/5/7.
//  Copyright © 2016年 九月. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JYFlashViewDelegate <NSObject>

@optional
- (void)flashViewCellBtnOnClick:(UIButton *)btn;

@end

@interface JYFlashView : UIView

@property (weak, nonatomic) id<JYFlashViewDelegate> delegate;

@end
