//
//  JYTestView.h
//  SeptOnCamera
//
//  Created by Sept on 16/1/28.
//  Copyright © 2016年 九月. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JYCoreBlueViewDelegate <NSObject>

@optional
- (void)coreBlueViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)coreBlueViewChangePerName:(JYPeripheral *)per;

@end

@interface JYCoreBlueView : UIView

@property (weak, nonatomic) id<JYCoreBlueViewDelegate>delegate;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *titleLabel;


@property (strong, nonatomic) NSMutableArray *peripherals;

@property (strong, nonatomic) NSMutableArray *perArrays;

@end
