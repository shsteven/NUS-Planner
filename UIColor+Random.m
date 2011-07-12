//
//  UIColor+Random.m
//  NUS Mod
//
//  Created by Steven Zhang on 10/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (UIColor_Random)

+ (UIColor *) randomColor {
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (UIColor *)darkerColor {
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    if (r > 0.5) r/=2.0;
    if (g>0.5) g/=2.0;
    if (b>0.5) b/=2.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

+ (UIColor *) darkRandomColor {
    CGFloat red =  0.5-  0.5*(CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = 0.5- 0.5*(CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = 0.5- 0.5*(CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
