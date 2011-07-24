//
//  UIColor+Random.h
//  NUS Mod
//
//  Created by Steven Zhang on 10/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColor_Random)

+ (UIColor *) randomColor;
+ (UIColor *) darkRandomColor;
- (UIColor *)darkerColor;

- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;

- (void)getRGBComponents:(CGFloat [3])components;

- (BOOL)colorIsSimilarToColor: (UIColor *)anotherColor;
@end
