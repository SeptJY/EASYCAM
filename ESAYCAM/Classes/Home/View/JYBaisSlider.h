//
//  JYBaisSlider.h
//  ESAYCAM
//
//  Created by Sept on 16/5/19.
//  Copyright © 2016年 九月. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASValueTrackingSlider.h"

@protocol JYBaisSliderDelegate <NSObject>

@optional
- (void)baisSliderValueChange:(UISlider *)slider;
- (void)baisSliderAutoBtnOnClick:(UIButton *)btn;

@end


typedef NS_ENUM(NSUInteger, JYButtonType) {
    JYButtonTypeAutoAndLock,
    JYButtonTypeReset,
};

@interface JYBaisSlider : UIView

/** slider的最小值 、最大值、 当前值*/
@property (assign, nonatomic) CGFloat minimumValue;
@property (assign, nonatomic) CGFloat maximumValue;
@property (assign, nonatomic) CGFloat value;

@property (copy, nonatomic) NSString *title;

- (instancetype)initWithTitle:(NSString *)sizeTitle buttonType:(JYButtonType)btnType show:(JYShowType)showType;

@property (weak, nonatomic) id<JYBaisSliderDelegate> delegate;

@property (assign, nonatomic) NSInteger sliderTag;

@end
