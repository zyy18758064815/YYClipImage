//
//  YYCropImageViewController.m
//  YYClipImage
//
//  Created by yunyunzhang on 2018/7/31.
//  Copyright © 2018年 yunyunzhang. All rights reserved.
//

#import "YYCropImageViewController.h"
#import "UIImage+Utils.h"
#import "Utility.h"
#import "YYCropImageView.h"



@interface YYCropImageViewController ()
@property (nonatomic,strong) UIImage * photoImage;
@property (nonatomic,strong) UIImageView * backgroundImageView;
@property (nonatomic,strong) UIImageView * photoImageView;
@property (nonatomic,strong) UIButton * backBtn;

@property (nonatomic,strong) UIButton * selectBtn;
@property (nonatomic,strong) UIButton * replaceBtn;

@property (nonatomic,strong) YYCropImageView * cropImageView;
@property (nonatomic,strong) UIImageView * detectImageView;
@property (nonatomic,assign) CGRect chooseRect;

@end

@implementation YYCropImageViewController

- (instancetype)initWithPhoto:(UIImage *)photoImage
{
    if (self = [super init]) {
        _photoImage = [photoImage fixOrientation];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startScanAnimation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4.5 * NSEC_PER_SEC),dispatch_get_main_queue(), ^{
           [self detach];
       });
}

- (void)startScanAnimation
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       self.detectImageView.frame = CGRectMake(0, -180 , self.view.bounds.size.width, 180);
       [UIView animateWithDuration:1.5 delay:.0 options:UIViewAnimationOptionRepeat  animations:^{
           self.detectImageView.frame = CGRectMake(0, SCREEN_HEIGHT , self.view.bounds.size.width, 180);
       } completion:^(BOOL finished) {
           self.detectImageView.frame = CGRectMake(0, -180 , self.view.bounds.size.width, 180);
       }];
   });
}

- (void)stopScanAnimation
{
    self.detectImageView.hidden = YES;
}

- (void)createUI
{
    _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _backgroundImageView.image = _photoImage;
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_backgroundImageView];
    [self addblurImageView];
    
    UIImageView * shadeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    shadeImageView.image = [UIImage imageNamed:@"sticker_face_shade"];
    [self.view addSubview:shadeImageView];
    
    _photoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    _photoImageView.image = _photoImage;
    [self.view addSubview:_photoImageView];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(15, 20, 18, 18);
    [_backBtn setImage:[UIImage imageNamed:@"login_back_normal"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectBtn.frame = CGRectMake(SCREEN_WIDTH - 118,SCREEN_HEIGHT - 70, 100, 54);
    [_selectBtn setImage:[UIImage imageNamed:@"sticker_face_select_nor"] forState:UIControlStateNormal];
    [_selectBtn addTarget:self action:@selector(selectButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_selectBtn];
    
    _replaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _replaceBtn.frame = CGRectMake(SCREEN_WIDTH - 118, SCREEN_HEIGHT - 70, 100, 54);
    [_replaceBtn setImage:[UIImage imageNamed:@"sticker_face_replace_nor"] forState:UIControlStateNormal];
    [_replaceBtn addTarget:self action:@selector(replaceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_replaceBtn];
    
    _replaceBtn.hidden = _selectBtn.hidden = YES;
    
    self.detectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -180, SCREEN_WIDTH, 180)];
    self.detectImageView.image = [UIImage imageNamed:@"sticker_face_scanning"];
    [self.view addSubview:self.detectImageView];
}

- (void)detach
{
    [self stopScanAnimation];
    [self handleResult];
}

- (void)addblurImageView
{
    UIBlurEffectStyle style = UIBlurEffectStyleExtraLight;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        style = UIBlurEffectStyleRegular;
    }
    UIBlurEffect * beffect = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView * view = [[UIVisualEffectView alloc]initWithEffect:beffect];
    view.frame = self.view.bounds;
    [self.view addSubview:view];
}

- (void)backButtonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)getFaceView:(CGRect)frame
{
    UIView * detachView = [[UIView alloc]initWithFrame:frame];
    UIImageView * leftTopImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 14, 14)];
    leftTopImageView.image = [UIImage imageNamed:@"sticker_face_left_top"];
    [detachView addSubview:leftTopImageView];
    
    UIImageView * rightTopImageView = [[UIImageView alloc]initWithFrame:CGRectMake(detachView.frame.size.width - 14, 0, 14, 14)];
    rightTopImageView.image = [UIImage imageNamed:@"sticker_face_right_top"];
    [detachView addSubview:rightTopImageView];
    
    UIImageView * leftBottomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, detachView.frame.size.height - 14, 14, 14)];
    leftBottomImageView.image = [UIImage imageNamed:@"sticker_face_left_bottom"];
    [detachView addSubview:leftBottomImageView];
    
    UIImageView * rightBottomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(detachView.frame.size.width - 14, detachView.frame.size.height - 14, 14, 14)];
    rightBottomImageView.image = [UIImage imageNamed:@"sticker_face_right_bottom"];
    [detachView addSubview:rightBottomImageView];
    return detachView;
}

- (void)handleResult
{
    CIImage * image = [[CIImage alloc] initWithImage:_photoImage];
    CGSize ciImageSize = [image extent].size;;
    CGRect chooseBound = CGRectMake(300, 100, 400, 400);

    CGSize viewSize = self.photoImageView.bounds.size;
    CGFloat scale = MIN(viewSize.width / ciImageSize.width,
                        viewSize.height / ciImageSize.height);
    CGFloat offsetX = (viewSize.width - ciImageSize.width * scale) / 2;
    CGFloat offsetY = (viewSize.height - ciImageSize.height * scale) / 2;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGRect faceViewBounds = CGRectApplyAffineTransform(chooseBound,scaleTransform);
    faceViewBounds.origin.x += offsetX;
    faceViewBounds.origin.y += offsetY;
    _chooseRect = faceViewBounds;
    UIView * faceView = [self getFaceView:faceViewBounds];
    [self.photoImageView addSubview:faceView];
    _selectBtn.hidden = NO;
    _replaceBtn.hidden = YES;
}

- (void)selectButtonAction
{
    _selectBtn.hidden = YES;
    _photoImageView.hidden = YES;
    _cropImageView = [[YYCropImageView alloc]initWithCropArea:_chooseRect CropImage:_photoImage];
    [self.view addSubview:_cropImageView];
    _replaceBtn.hidden = NO;
    [self.view bringSubviewToFront:_replaceBtn];
    [self.view bringSubviewToFront:_backBtn];
}

- (void)replaceButtonAction
{
    UIImage * image = [_cropImageView getCropImage];
    NSLog(@"截取的图片为 %@",image);
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
