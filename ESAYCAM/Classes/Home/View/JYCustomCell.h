//
//  JYCustomCell.h
//  ESAYCAM
//
//  Created by Sept on 16/5/7.
//  Copyright © 2016年 九月. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JYCustomCellDelegate <NSObject>

@optional
- (void)customCellAlertBtnClick:(UIButton *)btn;

@end

@interface JYCustomCell : UITableViewCell

@property (copy, nonatomic) NSString *title;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (weak, nonatomic) id<JYCustomCellDelegate> delegate;

@property (assign, nonatomic) BOOL isHidden;

@end
