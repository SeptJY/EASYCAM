//
//  JYHandwheelView.h
//  ESAYCAM
//
//  Created by admin on 16/4/27.
//  Copyright © 2016年 九月. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JYHandwheelViewDelegte <NSObject>

@optional
- (void)handwheelDirectionCellBtnOnClick:(UIButton *)btn;

@end

@interface JYHandwheelView : UIView

@property (weak, nonatomic) id<JYHandwheelViewDelegte> delegate;

@end
