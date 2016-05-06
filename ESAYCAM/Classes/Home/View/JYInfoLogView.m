//
//  JYInfoLogView.m
//  ESAYCAM
//
//  Created by Sept on 16/5/5.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYInfoLogView.h"

@interface JYInfoLogView ()


@end

@implementation JYInfoLogView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"JYInfoLogView" owner:nil options:nil] lastObject];
    }
    return self;
}

@end
