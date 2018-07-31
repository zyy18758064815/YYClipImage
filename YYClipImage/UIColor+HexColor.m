//
//  UIColor+HexColor.m
//  LOFTERCam
//
//  Created by ZQP on 14-7-10.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "UIColor+HexColor.h"

@implementation UIColor (UIColor_HexColor)

+ (UIColor *) colorFromHexCode:(NSString *)hexString
{
    return [self colorFromHexCode:hexString alpha:1.0];
}

+ (UIColor *) colorFromHexCode:(NSString *)hexString
                         alpha:(CGFloat)alpha
{
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    if (alpha >= 0.99) {
        alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end
