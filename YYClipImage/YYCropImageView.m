//
//  YYCropImageView.m
//  YYClipImage
//
//  Created by yunyunzhang on 2018/7/31.
//  Copyright © 2018年 yunyunzhang. All rights reserved.
//

#import "YYCropImageView.h"
#import "Utility.h"
#import "UIColor+HexColor.h"

typedef NS_ENUM(NSInteger, PanType){
    PanNone,
    PanImage,
    PanCropView,
    PanCropViewConcer1,
    PanCropViewConcer2,
    PanCropViewConcer3,
    PanCropViewConcer4,
    PanCropViewTopBorder,
    PanCropViewBottomBorder,
    PanCropViewLeftBorder,
    PanCropViewRightBorder
};

@interface YYCropImageView()

@property (nonatomic,assign) CGRect cropRect;
@property (nonatomic,assign) CGRect concer1;
@property (nonatomic,assign) CGRect concer2;
@property (nonatomic,assign) CGRect concer3;
@property (nonatomic,assign) CGRect concer4;
@property (nonatomic,assign) CGRect topBorder;
@property (nonatomic,assign) CGRect bottomBorder;
@property (nonatomic,assign) CGRect leftBorder;
@property (nonatomic,assign) CGRect rightBorder;

@property (nonatomic) UIImageView * imageView;
@property (nonatomic) CGRect imageViewOriginFrame;

@property (nonatomic) UIView * cropView;
@property (nonatomic) NSMutableArray<UIView *> *coverViews;

@property (nonatomic) PanType panType;
@property (nonatomic) CGRect cropViewPreFrame;

@property (nonatomic,strong) UIImageView * leftTopCornerImageView;
@property (nonatomic,strong) UIImageView * rightTopCornerImageView;
@property (nonatomic,strong) UIImageView * leftBottomCornerImageView;
@property (nonatomic,strong) UIImageView * rightBottomCornerImageView;

@property (nonatomic,assign) double minSide;
@property (nonatomic,assign) double touchRectSide;

@end


@implementation YYCropImageView

- (instancetype)initWithCropArea:(CGRect)rect CropImage:(UIImage *)image

{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = [UIColor clearColor];
        [self setImageViewWithImage:image];
        [self setupCropViews:rect];
        [self initCoverViews];
        [self setTouchRects];
        [self bindGestureRecognizer];
        _imageViewOriginFrame = _imageView.frame;
    }
    return self;
}

- (void)setImageViewWithImage:(UIImage *)image
{
    CGFloat ratio = image.size.width / image.size.height;
    CGFloat width = SCREEN_WIDTH;
    CGFloat height = width / ratio;
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    _imageView.image = image;
    _imageView.center = self.center;
    [self addSubview:_imageView];
}

- (void)setupCropViews:(CGRect)frame
{
    if (frame.size.width > 0 && frame.size.height > 0)
    {
        _cropView = [[UIView alloc]initWithFrame:frame];
        _minSide = frame.size.width < 64 ? frame.size.width : 64;
        _touchRectSide = frame.size.width > 100 ? 40 : 20;
    }
    else
    {
        _minSide = 64;
        _cropView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _minSide, _minSide)];
        _cropView.center = self.center;
        _touchRectSide = 20;
    }
    [self addSubview:_cropView];
    _leftTopCornerImageView = [[UIImageView alloc]init];
    _leftTopCornerImageView.image = [UIImage imageNamed:@"sticker_face_left_top"];
    [_cropView addSubview:_leftTopCornerImageView];
    
    _rightTopCornerImageView = [[UIImageView alloc]init];
    _rightTopCornerImageView.image = [UIImage imageNamed:@"sticker_face_right_top"];
    [_cropView addSubview:_rightTopCornerImageView];
    
    _leftBottomCornerImageView = [[UIImageView alloc]init];
    _leftBottomCornerImageView.image = [UIImage imageNamed:@"sticker_face_left_bottom"];
    [_cropView addSubview:_leftBottomCornerImageView];
    
    _rightBottomCornerImageView = [[UIImageView alloc]init];
    _rightBottomCornerImageView.image = [UIImage imageNamed:@"sticker_face_right_bottom"];
    [_cropView addSubview:_rightBottomCornerImageView];
    [self layoutCornerViews];
}

- (void)initCoverViews
{
    _coverViews = [NSMutableArray arrayWithCapacity:4];
    for(int i = 0; i < 4; i++){
        UIView *coverView = [self getCoverView];
        [_coverViews addObject:coverView];
        [self addSubview:coverView];
    }
    [self layoutCoverViews];
    [self bringSubviewToFront:_cropView];
}

- (UIView *)getCoverView
{
    UIView * coverView = [UIView new];
    coverView.backgroundColor = [UIColor colorFromHexCode:@"21212C" alpha:0.8];
    return coverView;
}

#pragma mark - Layout
- (void)layoutCornerViews
{
    _leftTopCornerImageView.frame = CGRectMake(-2, -2, 14, 14);
    _rightTopCornerImageView.frame = CGRectMake(_cropView.frame.size.width - 12, -2, 14, 14);
    _leftBottomCornerImageView.frame = CGRectMake(-2, _cropView.frame.size.height - 12, 14, 14);
    _rightBottomCornerImageView.frame = CGRectMake(_cropView.frame.size.width - 12, _cropView.frame.size.height - 12, 14, 14);
}

- (void)layoutCoverViews
{
    CGRect frame = _cropView.frame;
    _coverViews[0].frame = CGRectMake(0, 0, CGRectGetMaxX(frame), CGRectGetMinY(frame));
    _coverViews[1].frame = CGRectMake(0, CGRectGetMinY(frame), CGRectGetMinX(frame), SCREEN_HEIGHT - CGRectGetMinY(frame));
    _coverViews[2].frame = CGRectMake(CGRectGetMaxX(frame), 0, SCREEN_WIDTH - CGRectGetMaxX(frame), CGRectGetMaxY(frame));
    _coverViews[3].frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame), SCREEN_WIDTH - CGRectGetMinX(frame), SCREEN_HEIGHT - CGRectGetMaxY(frame));
}

- (void)setTouchRects
{
    CGPoint point = _cropView.frame.origin;
    _concer1 = CGRectMake(point.x - _touchRectSide / 2, point.y - _touchRectSide / 2, _touchRectSide, _touchRectSide);
    point.x += _cropView.frame.size.width;
    _concer2 = CGRectMake(point.x - _touchRectSide / 2, point.y - _touchRectSide / 2, _touchRectSide, _touchRectSide);
    point.y += _cropView.frame.size.height;
    _concer4 = CGRectMake(point.x - _touchRectSide / 2, point.y - _touchRectSide / 2, _touchRectSide, _touchRectSide);
    point.x -= _cropView.frame.size.width;
    _concer3 = CGRectMake(point.x - _touchRectSide / 2, point.y - _touchRectSide / 2, _touchRectSide, _touchRectSide);
    _topBorder = CGRectMake(_concer1.origin.x + _concer1.size.width, _concer1.origin.y, _cropView.frame.size.width - _touchRectSide, _touchRectSide);
    CGRect temp = _topBorder;
    temp.origin.y += _cropView.frame.size.height;
    _bottomBorder = temp;
    _leftBorder = CGRectMake(_concer1.origin.x, _concer1.origin.y + _concer1.size.height, _touchRectSide, _cropView.frame.size.height - _touchRectSide);
    temp = _leftBorder;
    temp.origin.x += _cropView.frame.size.width;
    _rightBorder = temp;
    _cropRect = CGRectMake(_concer1.origin.x + _touchRectSide, _concer1.origin.y + _touchRectSide, _cropView.frame.size.width - _touchRectSide, _cropView.frame.size.height - _touchRectSide);
}

- (UIImage *)getCropImage
{
    CGRect cropFrame = _cropView.frame;
    CGRect imageFrame = _imageView.frame;
    CGRect targetFrame = CGRectMake(CGRectGetMinX(cropFrame) - CGRectGetMinX(imageFrame), CGRectGetMinY(cropFrame) - CGRectGetMinY(imageFrame), CGRectGetWidth(cropFrame), CGRectGetHeight(cropFrame));
    float scale = _imageView.image.size.width / imageFrame.size.width;
    targetFrame.origin.x *= scale;
    targetFrame.origin.y *= scale;
    targetFrame.size.width *= scale;
    targetFrame.size.height *= scale;
    targetFrame.origin.x = (int)(targetFrame.origin.x + 0.5);
    targetFrame.origin.y = (int)(targetFrame.origin.y + 0.5);
    targetFrame.size.width = (int)(targetFrame.size.width + 0.5);
    targetFrame.size.height = (int)(targetFrame.size.height + 0.5);
    return [UIImage imageWithCGImage:CGImageCreateWithImageInRect(_imageView.image.CGImage, targetFrame)];
}

#pragma mark - GestureRecognizer
- (void)bindGestureRecognizer
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:pinch];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint touchPoint = [recognizer locationInView:self];
        _cropViewPreFrame = _cropView.frame;
        if(CGRectContainsPoint(_cropRect, touchPoint)) _panType = PanCropView;
        else if(CGRectContainsPoint(_concer1, touchPoint)) _panType = PanCropViewConcer1;
        else if(CGRectContainsPoint(_concer2, touchPoint)) _panType = PanCropViewConcer2;
        else if(CGRectContainsPoint(_concer3, touchPoint)) _panType = PanCropViewConcer3;
        else if(CGRectContainsPoint(_concer4, touchPoint)) _panType = PanCropViewConcer4;
        else if(CGRectContainsPoint(_topBorder, touchPoint)) _panType = PanCropViewTopBorder;
        else if(CGRectContainsPoint(_bottomBorder, touchPoint)) _panType = PanCropViewBottomBorder;
        else if(CGRectContainsPoint(_leftBorder, touchPoint)) _panType = PanCropViewLeftBorder;
        else if(CGRectContainsPoint(_rightBorder, touchPoint)) _panType = PanCropViewRightBorder;
        else _panType = PanImage;
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGRect nextFrame;
        CGPoint transPoint;
        if(_panType == PanImage)
        {
            transPoint = [recognizer translationInView:self];
            nextFrame = _imageView.frame;
            nextFrame.origin.x += transPoint.x;
            nextFrame.origin.y += transPoint.y;
            if(CGRectGetMinY(nextFrame) > CGRectGetMinY(_cropViewPreFrame)) nextFrame.origin.y = CGRectGetMinY(_cropViewPreFrame);
            if(CGRectGetMinX(nextFrame) > CGRectGetMinX(_cropViewPreFrame)) nextFrame.origin.x = CGRectGetMinX(_cropViewPreFrame);
            if(CGRectGetMaxX(nextFrame) < CGRectGetMaxX(_cropViewPreFrame)) nextFrame.origin.x = CGRectGetMaxX(_cropViewPreFrame) - CGRectGetWidth(nextFrame);
            if(CGRectGetMaxY(nextFrame) < CGRectGetMaxY(_cropViewPreFrame)) nextFrame.origin.y = CGRectGetMaxY(_cropViewPreFrame) - CGRectGetHeight(nextFrame);
            _imageView.frame = nextFrame;
            [recognizer setTranslation:CGPointZero inView:self];
        }
        else
        {
            transPoint = [recognizer translationInView:self];
            nextFrame = _cropView.frame;
            CGFloat maxTop = MAX(64, CGRectGetMinY(_imageView.frame));
            CGFloat maxLeft = MAX(0, CGRectGetMinX(_imageView.frame));
            CGFloat minRight = MIN(SCREEN_WIDTH, CGRectGetMaxX(_imageView.frame));
            CGFloat minBottom = MIN(SCREEN_HEIGHT, CGRectGetMaxY(_imageView.frame));
            if(_panType == PanCropView)
            {
                nextFrame.origin.x += transPoint.x;
                nextFrame.origin.y += transPoint.y;
                if(CGRectGetMinY(nextFrame) < maxTop) nextFrame.origin.y = maxTop;
                if(CGRectGetMinX(nextFrame) < maxLeft) nextFrame.origin.x = maxLeft;
                if(CGRectGetMaxX(nextFrame) > minRight){
                    nextFrame.origin.x = minRight - CGRectGetWidth(_cropViewPreFrame);
                }
                if(CGRectGetMaxY(nextFrame) > minBottom){
                    nextFrame.origin.y = minBottom - CGRectGetHeight(_cropViewPreFrame);
                }
            }else if(_panType == PanCropViewConcer1){
                nextFrame.origin.x += transPoint.x;
                nextFrame.size.width -= transPoint.x;
                nextFrame.size.height = nextFrame.size.width;
                if(CGRectGetWidth(nextFrame) < _minSide){
                    nextFrame.size.width = _minSide;
                    nextFrame.origin.x = CGRectGetMaxX(_cropViewPreFrame) - _minSide;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMinX(nextFrame) < maxLeft){
                    nextFrame.origin.x = maxLeft;
                    nextFrame.size.width = CGRectGetMaxX(_cropViewPreFrame) - maxLeft;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMinY(nextFrame) < maxTop){
                    nextFrame.origin.y = maxTop;
                    nextFrame.size.height = CGRectGetMaxY(_cropViewPreFrame) - maxTop;
                    nextFrame.size.width = nextFrame.size.height;
                }
                if(CGRectGetMaxY(nextFrame) > minBottom){
                    nextFrame.origin.y = _cropViewPreFrame.origin.y;
                    nextFrame.size.height = minBottom - CGRectGetMinY(_cropViewPreFrame);
                    nextFrame.size.width = nextFrame.size.height;
                }
            }else if(_panType == PanCropViewConcer2){
                nextFrame.size.width += transPoint.x;
                nextFrame.size.height = nextFrame.size.width;
                if(CGRectGetWidth(nextFrame) < _minSide){
                    nextFrame.size.width = _minSide;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMaxX(nextFrame) > minRight){
                    nextFrame.size.width = minRight - CGRectGetMinX(_cropViewPreFrame);
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMinY(nextFrame) < maxTop){
                    nextFrame.origin.y = maxTop;
                    nextFrame.size.height = CGRectGetMaxY(_cropViewPreFrame) - maxTop;
                    nextFrame.size.width = nextFrame.size.height;
                }
                if(CGRectGetMaxY(nextFrame) > minBottom){
                    nextFrame.origin.y = _cropViewPreFrame.origin.y;
                    nextFrame.size.height = minBottom - CGRectGetMinY(_cropViewPreFrame);
                    nextFrame.size.width = nextFrame.size.height;
                }
            }else if(_panType == PanCropViewConcer3){
                nextFrame.origin.x += transPoint.x;
                nextFrame.size.width -= transPoint.x;
                nextFrame.size.height = nextFrame.size.width;
                if(CGRectGetWidth(nextFrame) < _minSide){
                    nextFrame.size.width = _minSide;
                    nextFrame.origin.x = CGRectGetMaxX(_cropViewPreFrame) - _minSide;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMinY(nextFrame) < maxTop){
                    nextFrame.origin.y = maxTop;
                    nextFrame.size.height = CGRectGetMaxY(_cropViewPreFrame) - maxTop;
                    nextFrame.size.width = nextFrame.size.height;
                }
                if(CGRectGetMaxX(nextFrame) > minRight)
                {
                    nextFrame.size.width = minRight - CGRectGetMinX(_cropViewPreFrame);
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMinX(nextFrame) < maxLeft){
                    nextFrame.origin.x = maxLeft;
                    nextFrame.size.width = CGRectGetMaxX(_cropViewPreFrame) - maxLeft;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMaxY(nextFrame) > minBottom){
                    nextFrame.origin.y = _cropViewPreFrame.origin.y;
                    nextFrame.size.height = minBottom - CGRectGetMinY(_cropViewPreFrame);
                    nextFrame.size.width = nextFrame.size.height;
                }
            }else if(_panType == PanCropViewConcer4){
                nextFrame.size.width += transPoint.x;
                nextFrame.size.height = nextFrame.size.width;
                if(CGRectGetWidth(nextFrame) < _minSide)
                {
                    nextFrame.size.width = _minSide;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMaxX(nextFrame) > minRight)
                {
                    nextFrame.size.width = minRight - CGRectGetMinX(_cropViewPreFrame);
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMaxY(nextFrame) > minBottom)
                {
                    nextFrame.origin.y = _cropViewPreFrame.origin.y;
                    nextFrame.size.height = minBottom - CGRectGetMinY(_cropViewPreFrame);
                    nextFrame.size.width = nextFrame.size.height;
                }
            }else if(_panType == PanCropViewTopBorder){
                nextFrame.origin.y += transPoint.y;
                nextFrame.size.height -= transPoint.y;
                nextFrame.size.width = nextFrame.size.height;
                if(CGRectGetMinY(nextFrame) < maxTop) nextFrame.origin.y = maxTop;
                if(CGRectGetHeight(nextFrame) < _minSide){
                    nextFrame.size.height = _minSide;
                    nextFrame.origin.y = CGRectGetMaxY(_cropViewPreFrame) - _minSide;
                    nextFrame.size.width = nextFrame.size.height;
                }
                if(CGRectGetMinX(nextFrame) < maxLeft){
                    nextFrame.origin.x = maxLeft;
                    nextFrame.size.width = CGRectGetMaxX(_cropViewPreFrame) - maxLeft;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMaxY(nextFrame) > minBottom){
                    nextFrame.size.height = minBottom - CGRectGetMinY(_cropViewPreFrame);
                    nextFrame.size.width = nextFrame.size.height;
                }
                if(CGRectGetMaxX(nextFrame) > minRight)
                {
                    nextFrame.size.width = minRight - CGRectGetMinX(_cropViewPreFrame);
                    nextFrame.size.height = nextFrame.size.width;
                }
            }else if(_panType == PanCropViewLeftBorder){
                nextFrame.origin.x += transPoint.x;
                nextFrame.size.width -= transPoint.x;
                nextFrame.size.height = nextFrame.size.width;
                if(CGRectGetWidth(nextFrame) < _minSide){
                    nextFrame.size.width = _minSide;
                    nextFrame.origin.x =  CGRectGetMaxX(_cropViewPreFrame) - _minSide;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMinX(nextFrame) < maxLeft){
                    nextFrame.origin.x = maxLeft;
                    nextFrame.size.width = CGRectGetMaxX(_cropViewPreFrame) - maxLeft;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMaxY(nextFrame) > minBottom){
                    nextFrame.size.height = minBottom - CGRectGetMinY(_cropViewPreFrame);
                    nextFrame.size.width = nextFrame.size.height;
                }
                
            }else if(_panType == PanCropViewRightBorder){
                nextFrame.size.width += transPoint.x;
                nextFrame.size.height = nextFrame.size.width;
                if(CGRectGetWidth(nextFrame) < _minSide){
                    nextFrame.size.width = _minSide;
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMaxX(nextFrame) > minRight){
                    nextFrame.size.width = minRight - CGRectGetMinX(_cropViewPreFrame);
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMaxY(nextFrame) > minBottom){
                    nextFrame.size.height = minBottom - CGRectGetMinY(_cropViewPreFrame);
                    nextFrame.size.width = nextFrame.size.height;
                }
                
            }else if(_panType == PanCropViewBottomBorder){
                nextFrame.size.height += transPoint.y;
                nextFrame.size.width = nextFrame.size.height;
                if(CGRectGetHeight(nextFrame) < _minSide){
                    nextFrame.size.height = _minSide;
                    nextFrame.size.width = nextFrame.size.height;
                }
                if(CGRectGetMaxX(nextFrame) > minRight){
                    nextFrame.size.width = minRight - CGRectGetMinX(_cropViewPreFrame);
                    nextFrame.size.height = nextFrame.size.width;
                }
                if(CGRectGetMaxY(nextFrame) > minBottom){
                    nextFrame.size.height = minBottom - CGRectGetMinY(_cropViewPreFrame);
                    nextFrame.size.width = nextFrame.size.height;
                }
            }
            _cropView.frame = nextFrame;
            [self layoutCoverViews];
            [self layoutCornerViews];
            [recognizer setTranslation:CGPointZero inView:self];
        }
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        [self setTouchRects];
        _panType = PanNone;
    }
}
- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer{
    CGRect currentImageFrame = _imageView.frame;
    CGRect nextImageFrame = currentImageFrame;
    CGFloat scale = recognizer.scale;
    CGFloat nextWidth = scale * CGRectGetWidth(currentImageFrame);
    CGFloat nextHeight = scale * CGRectGetHeight(currentImageFrame);
    if(nextWidth > CGRectGetWidth(_imageViewOriginFrame) * 3){
        nextWidth = CGRectGetWidth(_imageViewOriginFrame) * 3;
    }
    if(nextHeight > CGRectGetHeight(_imageViewOriginFrame) * 3){
        nextHeight = CGRectGetHeight(_imageViewOriginFrame) * 3;
    }
    if(nextWidth < CGRectGetWidth(_imageViewOriginFrame) * 1){
        nextWidth = CGRectGetWidth(_imageViewOriginFrame) * 1;
    }
    if(nextHeight < CGRectGetHeight(_imageViewOriginFrame) * 1){
        nextHeight = CGRectGetHeight(_imageViewOriginFrame) * 1;
    }
    
    nextImageFrame.size.width = nextWidth;
    nextImageFrame.size.height = nextHeight;
    nextImageFrame.origin.x -= (CGRectGetWidth(nextImageFrame) - CGRectGetWidth(currentImageFrame)) / 2;
    nextImageFrame.origin.y -= (CGRectGetHeight(nextImageFrame) - CGRectGetHeight(currentImageFrame)) / 2;
    
    CGRect cropViewFrame = _cropView.frame;
    if(scale < 1 && !CGRectContainsRect(nextImageFrame, cropViewFrame)){
        if(CGRectGetWidth(nextImageFrame) <= CGRectGetWidth(cropViewFrame) || CGRectGetHeight(nextImageFrame) <= CGRectGetHeight(cropViewFrame)){
            if(CGRectGetWidth(nextImageFrame) <= CGRectGetWidth(cropViewFrame)){
                cropViewFrame.size.width = CGRectGetWidth(nextImageFrame);
                cropViewFrame.origin.x = CGRectGetMinX(nextImageFrame);
                if(CGRectGetMinY(nextImageFrame) > CGRectGetMinY(cropViewFrame)){
                    nextImageFrame.origin.y = CGRectGetMinY(currentImageFrame);
                }
                if(CGRectGetMaxY(nextImageFrame) < CGRectGetMaxY(cropViewFrame)){
                    nextImageFrame.origin.y = CGRectGetMaxY(cropViewFrame) - CGRectGetHeight(nextImageFrame);
                }
            }
            if(CGRectGetHeight(nextImageFrame) <= CGRectGetHeight(cropViewFrame)){
                cropViewFrame.size.height = CGRectGetHeight(nextImageFrame);
                cropViewFrame.origin.y = CGRectGetMinY(nextImageFrame);
                if(CGRectGetMinX(nextImageFrame) > CGRectGetMinX(cropViewFrame)){
                    nextImageFrame.origin.x = CGRectGetMinX(currentImageFrame);
                }
                if(CGRectGetMaxX(nextImageFrame) < CGRectGetMaxX(cropViewFrame)){
                    nextImageFrame.origin.x = CGRectGetMaxX(cropViewFrame) - CGRectGetWidth(nextImageFrame);
                }
            }
            _cropView.frame = cropViewFrame;
            [self layoutCoverViews];
            [self layoutCornerViews];
        }else{
            if(CGRectGetMinX(nextImageFrame) > CGRectGetMinX(cropViewFrame)){
                nextImageFrame.origin.x = CGRectGetMinX(currentImageFrame);
            }
            if(CGRectGetMinY(nextImageFrame) > CGRectGetMinY(cropViewFrame)){
                nextImageFrame.origin.y = CGRectGetMinY(currentImageFrame);
            }
            if(CGRectGetMaxX(nextImageFrame) < CGRectGetMaxX(cropViewFrame)){
                nextImageFrame.origin.x = CGRectGetMaxX(cropViewFrame) - CGRectGetWidth(nextImageFrame);
            }
            if(CGRectGetMaxY(nextImageFrame) < CGRectGetMaxY(cropViewFrame)){
                nextImageFrame.origin.y = CGRectGetMaxY(cropViewFrame) - CGRectGetHeight(nextImageFrame);
            }
        }
    }
    _imageView.frame = nextImageFrame;
    recognizer.scale = 1.0;
}


@end
