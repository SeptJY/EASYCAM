//
//  JYCustomCell.m
//  ESAYCAM
//
//  Created by Sept on 16/5/7.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYCustomCell.h"

@interface JYCustomCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *alertBtn;

@end

@implementation JYCustomCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    
    JYCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[JYCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = title;
}

- (void)setIsHidden:(BOOL)isHidden
{
    _isHidden = isHidden;
    
    self.alertBtn.hidden = isHidden;
}

- (IBAction)alertButtonOnClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customCellAlertBtnClick:)]) {
        [self.delegate customCellAlertBtnClick:sender];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
