//
//  UIColor+Random.m
//  NUS Mod
//
//  Created by Steven Zhang on 10/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (UIColor_Random)

const double eps = (double)0.01;

+ (UIColor *) randomColor {
    CGFloat minValue = 0.6;
    
    CGFloat red =  minValue + (1-minValue)* (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = minValue + (1-minValue)*(CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = minValue + (1-minValue)*(CGFloat)random()/(CGFloat)RAND_MAX;
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

- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    CGFloat components[3];
    [self getRGBComponents:components];
    *red = components[0];
    *green = components[1];
    *blue = components[2];
   *alpha = 1;  // TODO: get proper alpha
    
    return YES;
}

- (void)getRGBComponents:(CGFloat [3])components {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}

-(CGFloat)sqr:(CGFloat)diff {
    return diff * diff;
}

- (BOOL)colorIsSimilarToColor: (UIColor *)anotherColor {
    CGFloat r,g,b, a;
    CGFloat r2, g2, b2, a2;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    [anotherColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    if ([self sqr:(r - r2)] < eps && [self sqr:(g - g2)] < eps && [self sqr:(b-b2)] < eps && [self sqr:(a - a2)] < eps) {
        return YES;
    }
    return NO;
}

@end
