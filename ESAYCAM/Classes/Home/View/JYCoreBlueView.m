//
//  JYTestView.m
//  SeptOnCamera
//
//  Created by Sept on 16/1/28.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYCoreBlueView.h"
#import "JYCustomCell.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define headViewHeight 25   // 标题高度

@interface JYCoreBlueView() <UITableViewDataSource, UITableViewDelegate, JYCustomCellDelegate>

@property (strong, nonatomic) JYPeripheral *peripheral;

@property (strong, nonatomic) UIView *headView;

@property (assign, nonatomic) BOOL isSave;   // 判断蓝牙是否需要保存

@property (strong, nonatomic) JYPeripheral *seletedPer;



@end

@implementation JYCoreBlueView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.perArrays = [NSMutableArray array];
        self.tableView.rowHeight = JYCortrolWidth;
        
        [self.tableView registerNib:[UINib nibWithNibName:@"JYCustomCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    }
    return self;
}

- (void)setPeripherals:(NSMutableArray *)peripherals
{
    [self.perArrays removeAllObjects];
    for (CBPeripheral *per in peripherals) {
        JYPeripheral *mPer = [[JYPeripheral alloc] initWithPeripheral:per];
        [self.perArrays addObject:mPer];
    }
}

- (UIView *)headView
{
    if (_headView == nil) {
        
        _headView = [[UIView alloc] init];
        
        _headView.backgroundColor = [UIColor yellowColor];
        _headView.alpha = 0.4;
        
        [self addSubview:_headView];
    }
    return _headView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        
        _titleLabel = [[UILabel alloc] init];
        
        _titleLabel.text = NSLocalizedString(@"其他设备", nil);
        _titleLabel.font = setFont(15);
        _titleLabel.textColor = [UIColor blueColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        [self.headView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] init];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor yellowColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark -------------------------> JYCustomCellDelegate
- (void)customCellAlertBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(coreBlueViewChangePerName:)]) {
        [self.delegate coreBlueViewChangePerName:self.seletedPer];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"%@", self.perArrays); 
    return (self.perArrays.count) ? self.perArrays.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JYCustomCell *cell = [JYCustomCell cellWithTableView:tableView];
    
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    if (self.perArrays.count > 0) {
        JYPeripheral *peripheral = self.perArrays[indexPath.row];
        
        if ([NSKeyedUnarchiver unarchiveObjectWithFile:path_encode] == nil) {
            cell.title = peripheral.name;
        } else {
            [[NSKeyedUnarchiver unarchiveObjectWithFile:path_encode] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JYPeripheral *mPer = obj;
                // 判断保存数据库中是否存在当前选中选中的蓝牙设备
                if ([mPer.identifier isEqualToString:peripheral.identifier]) {
                    cell.title = mPer.name;
                }else {
                    cell.title = peripheral.name;
                }
            }];
        }
        if ([peripheral.identifier isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Checkmark"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.tintColor = [UIColor yellowColor];
            cell.isHidden = NO;
            self.seletedPer = peripheral;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.title = @"未搜索到周围的服务";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%lu", (unsigned long)self.perArrays.count);
    if (self.perArrays.count > 0) {
        self.peripheral = self.perArrays[indexPath.row];
        
        [[NSKeyedUnarchiver unarchiveObjectWithFile:path_encode] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            JYPeripheral *mPer = obj;
            // 判断保存数据库中是否存在当前选中选中的蓝牙设备
            if ([mPer.identifier isEqualToString:self.peripheral.identifier]) {
                self.isSave = YES;
            }
        }];
        
        if (self.isSave == NO && self.perArrays != nil) {
            [[JYSeptManager sharedManager] saveCoreBlueWith:self.peripheral];
        }
        
        // 保存当前选中的值
        [[NSUserDefaults standardUserDefaults] setValue:self.peripheral.identifier forKey:@"Checkmark"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.tableView reloadData];
    }
    [self coreBlueViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath];
}

- (void)coreBlueViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(coreBlueViewDidSelectRowAtIndexPath:)]) {
        [self.delegate coreBlueViewDidSelectRowAtIndexPath:indexPath];
    }
}

- (void)layoutSubviews
{
    CGSize labelSize = [NSString sizeWithText:self.titleLabel.text font:self.titleLabel.font maxSize:CGSizeMake(200, 50)];

    self.headView.frame = CGRectMake(0, 0, self.width, 35);
    
    self.titleLabel.frame = CGRectMake(10, (self.headView.height - labelSize.height) / 2, labelSize.width, labelSize.height);
    
    self.tableView.frame = CGRectMake(0, self.headView.height, self.width, self.height - self.headView.height);
}

@end
