//
//  JYVideoView.m
//  SeptEsayCamera
//
//  Created by Sept on 16/3/17.
//  Copyright © 2016年 九月. All rights reserved.
//

#import "JYVideoView.h"

#import "JQIndicatorView.h"

static void *IMAGE_ICONS = &IMAGE_ICONS;

@interface JYVideoView()

//@property (strong, nonatomic) UIButton *resetBtn;
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) JQIndicatorView *indacatorView;

@property (strong, nonatomic) UIButton *videoBtn;

@property (strong, nonatomic) UIButton *photoBtn;

@property (strong, nonatomic) UIButton *iconsBtn;

@property (strong, nonatomic) UIButton *hiddenBtn;

@end

@implementation JYVideoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        // 程序一启动设置图片选择按钮的图片
        [[JYSaveVideoData sharedManager] homeOfSetupImageWithSeletedBtn];
        [[JYSaveVideoData sharedManager] addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:IMAGE_ICONS];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == IMAGE_ICONS) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.iconsBtn setImage:[JYSaveVideoData sharedManager].image forState:UIControlStateNormal];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (UIButton *)videoBtn
{
    if (!_videoBtn) {
        
        _videoBtn = [[UIButton alloc] init];
        
//        _videoBtn.backgroundColor = [UIColor yellowColor];
        [_videoBtn setImage:[UIImage imageNamed:@"record_stop"] forState:UIControlStateNormal];
        [_videoBtn setImage:[UIImage imageNamed:@"record_start"] forState:UIControlStateSelected];
        _videoBtn.adjustsImageWhenHighlighted = NO;
        _videoBtn.tag = 21;
        _videoBtn.alpha = 0.7;
        _videoBtn.hidden = [[NSUserDefaults standardUserDefaults] boolForKey:@"video"];
        [_videoBtn addTarget:self action:@selector(videoViewButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_videoBtn];
    }
    return _videoBtn;
}

- (UIButton *)photoBtn
{
    if (!_photoBtn) {
        
        _photoBtn = [[UIButton alloc] init];
        
//        _photoBtn.backgroundColor = [UIColor whiteColor];
        [_photoBtn setImage:[UIImage imageNamed:@"camara"] forState:UIControlStateNormal];
        [_photoBtn setImage:[UIImage imageNamed:@"camara_on"] forState:UIControlStateHighlighted];
        _photoBtn.tag = 22;
        _photoBtn.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"video"];
        [_photoBtn addTarget:self action:@selector(videoViewButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_photoBtn];
    }
    return _photoBtn;
}

- (UIButton *)iconsBtn
{
    if (!_iconsBtn) {
        
        _iconsBtn = [[UIButton alloc] init];
        
        _iconsBtn.backgroundColor = [UIColor whiteColor];
        [_iconsBtn setImage:[UIImage imageNamed:@"download_ic_bg_normal"] forState:UIControlStateNormal];
        _iconsBtn.tag = 23;
        [_iconsBtn addTarget:self action:@selector(videoViewButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_iconsBtn];
    }
    return _iconsBtn;
}

/** 重复提示的背景View */
- (UIView *)bgView
{
    if (!_bgView) {
        
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_bgView];
    }
    return _bgView;
}

/** 重复播放提示 */
- (JQIndicatorView *)indacatorView
{
    if (!_indacatorView) {
        
        _indacatorView = [[JQIndicatorView alloc] initWithType:JQIndicatorTypeBounceSpot1 tintColor:[UIColor yellowColor]];
        [self.bgView addSubview:_indacatorView];
    }
    return _indacatorView;
}
- (void)startResetVideoing
{
    [self.indacatorView startAnimating];
}

- (void)stopResetVideoing
{
    [self.indacatorView stopAnimating];
}

- (void)videoViewButtonOnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoViewButtonOnClick:)]) {
        [self.delegate videoViewButtonOnClick:btn];
    }
}

- (void)setImageData:(NSData *)imageData
{
    _imageData = imageData;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.iconsBtn setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
    });
}

- (void)setImgUrl:(NSURL *)imgUrl
{
    _imgUrl = imgUrl;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.iconsBtn setImage:[UIImage getImage:imgUrl] forState:UIControlStateNormal];
    });
}

- (void)setBtnSeleted:(BOOL)btnSeleted
{
    _btnSeleted = btnSeleted;
    
    self.videoBtn.selected = btnSeleted;
}

- (void)setIsVideo:(BOOL)isVideo
{
    _isVideo = isVideo;
    
    self.videoBtn.hidden = isVideo;
    self.photoBtn.hidden = !isVideo;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    [self.iconsBtn setImage:image forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    CGFloat magin = 10;
    
    CGFloat videoW = self.width;
    CGFloat videoH = videoW;
    CGFloat videoY = (self.height - videoH) /2;
    
    self.videoBtn.frame = CGRectMake(0, videoY, videoW, videoH);
    // ***************************************************************
    
    self.photoBtn.frame = self.videoBtn.frame;
    // ***************************************************************
    
    
    CGFloat iconsW = self.width - magin;   // 50
    CGFloat iconsH = 30;
    CGFloat iconsY = self.height - iconsH - magin;
    
    self.iconsBtn.frame = CGRectMake(0, iconsY, iconsW, iconsH);
    // ***************************************************************
    
//    CGFloat resetW = JYCortrolWidth;
//    CGFloat resetH = 30;
//    CGFloat resetY = JYSpaceWidth;
//    
//    self.resetBtn.frame = CGRectMake(0, resetY, resetW, resetH);
    // ***************************************************************
    CGFloat bgW = 30;
    CGFloat bgH = bgW;
    CGFloat bgX = (self.width - bgW) * 0.5;
    
    self.bgView.frame = CGRectMake(bgX, magin, bgW, bgH);
    
    // ***************************************************************
    self.indacatorView.frame = CGRectMake(bgW/2, self.videoBtn.y - 30, 0, 0);
    
    self.hiddenBtn.frame = CGRectMake(self.iconsBtn.x, self.iconsBtn.y - 50, 50, 30);
}

- (void)dealloc
{
    [[JYSaveVideoData sharedManager].image removeObserver:self forKeyPath:@"image" context:IMAGE_ICONS];
}

- (UIButton *)hiddenBtn
{
    if (!_hiddenBtn) {
        
        _hiddenBtn = [[UIButton alloc] init];
        _hiddenBtn.tag = 24;
        [_hiddenBtn addTarget:self action:@selector(videoViewButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_hiddenBtn];
    }
    return _hiddenBtn;
}

@end
