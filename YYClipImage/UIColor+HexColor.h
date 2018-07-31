//
//  UIColor+HexColor.h
//  LOFTERCam
//
//  Created by ZQP on 14-7-10.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)

+ (UIColor *)colorFromHexCode:(NSString *)hexString;

+ (UIColor *) colorFromHexCode:(NSString *)hexString
                         alpha:(CGFloat)alpha;

@end
