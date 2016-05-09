//
//  JYSeptDelegate.m
//  Sept数据库
//
//  Created by admin on 15/12/28.
//  Copyright © 2015年 Sept. All rights reserved.
//

#import "JYSeptManager.h"

@implementation JYSeptManager

static id _instace;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        
        _instace = [super allocWithZone:zone];
    });
    
    return _instace;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    
    return _instace;
}

- (instancetype)copeWithZone:(NSZone *)zone
{
    return _instace;
}

- (void)saveCoreBlueWith:(JYPeripheral *)pre
{
    // 1.创建数组
    NSMutableArray *mArray = [NSMutableArray array];
    
    // 2.判断路径是否为空
    if ([NSKeyedUnarchiver unarchiveObjectWithFile:path_encode] != nil) {  // 取出对象 -- 不为空
        //2.1 - 解挡读取对象，遍历数据所有数据
        NSLog(@"aa = %@", [NSKeyedUnarchiver unarchiveObjectWithFile:path_encode]);
        [[NSKeyedUnarchiver unarchiveObjectWithFile:path_encode] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            JYPeripheral *p = obj;
            NSLog(@"写入前遍历 = %@, %@",p.name, p.identifier);
            if (![pre.identifier isEqualToString:p.identifier]) {
                // 添加到数组中
                [mArray addObject:obj];
            }
        }];
    }
    // 把新数据放到最后
    [mArray addObject:pre];
    NSLog(@"新数据保存前 = %@", pre.name);
    
    //3.将自定义的对象保存到文件中
    [NSKeyedArchiver archiveRootObject:mArray toFile:path_encode];
}

- (BOOL)currentLanguage
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSArray* languages = [def objectForKey:@"AppleLanguages"];
    
    NSString *current = [languages objectAtIndex:0];
    
    NSString *str = [current substringWithRange:NSMakeRange(0, 2)];
    if ([str isEqualToString:@"zh"]) {
        return 1;
    } else
    {
        return 0;
    }
}

@end
