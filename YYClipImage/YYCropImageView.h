//
//  YYCropImageView.h
//  YYClipImage
//
//  Created by yunyunzhang on 2018/7/31.
//  Copyright © 2018年 yunyunzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYCropImageView : UIView
- (instancetype)initWithCropArea:(CGRect)rect CropImage:(UIImage *)image;
- (UIImage *)getCropImage;
@end
