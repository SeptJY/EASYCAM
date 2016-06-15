//
//  JYCollectionView.m
//  TestCollection
//
//  Created by Sept on 16/6/15.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYCollectionView.h"
#import "JYCollectionCell.h"

@interface JYCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UICollectionViewFlowLayout *collectionLayout;

@property (strong, nonatomic) NSArray *numArray;
@property (strong, nonatomic) NSArray *realArray;

@property (assign, nonatomic) CGSize size;

@end

@implementation JYCollectionView

+ (instancetype)collectionViewWithSize:(CGSize)size
{
    return [[self alloc] initWithSize:size];
}

- (instancetype)initWithSize:(CGSize)size
{
    self = [super init];
    if (self) {
        
        self.size = size;
        self.numArray = @[@"1/1k", @"1/500", @"1/250", @"1/125", @"1/60", @"1/30", @"1/15", @"1/8", @"1/4", @"1/2", @"1", @"2", @"4", @"8", @"15", @"30", @"B"];
        self.realArray = @[@"0.12", @"0.31", @"0.39", @"0.464", @"0.543", @"0.626", @"0.724", @"0.819", @"0.944", @"1.0", @"3", @"6", @"12", @"24", @"45", @"60", @"100"];
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[JYCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.numArray = @[@"1/1k", @"1/500", @"1/250", @"1/125", @"1/60", @"1/30", @"1/15", @"1/8", @"1/4", @"1/2", @"1", @"2", @"4", @"8", @"15", @"30", @"B"];
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[JYCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return self;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        
        _collectionLayout.itemSize = CGSizeMake(50, 40);
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        // 设置之间的距离
        _collectionLayout.minimumLineSpacing = 5;
        _collectionLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height) collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.bounces = NO;
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 200;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JYCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.title = self.numArray[indexPath.row % self.numArray.count];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewDidSelectIndex:)]) {
        [self.delegate collectionViewDidSelectIndex:[self.realArray[indexPath.row % self.numArray.count] floatValue]];
    }
}

@end
