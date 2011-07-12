//
//  EventView.m
//  NUS Mod
//
//  Created by Steven Zhang on 10/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "EventView.h"
#import <QuartzCore/QuartzCore.h>

@implementation EventView
@synthesize columnRange, rowRange;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self configureView];

    return self;
}

- (void)awakeFromNib {
    [self configureView];
}

- (void)configureView {
    // Initialization code
    columnRange.length = 0;
    rowRange.length = 0;
    self.layer.cornerRadius = 5.0;
    self.opaque = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIColor *)tintColor {
    CGFloat r, g, b, a;
    [self.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    return color;
}

- (void)setTintColor:(UIColor *)color {
//    tintColor = color;
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:0.5];
}

@end
