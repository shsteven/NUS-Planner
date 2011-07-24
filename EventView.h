//
//  EventView.h
//  NUS Mod
//
//  Created by Steven Zhang on 10/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventView : UIView {
    // Layout is handled by superview
    // According to the ranges
    // Example: columnRange = (0,1) ->starts at column 0, width is 1
    NSRange columnRange;
    NSRange rowRange;
    
//    NSTimer *blinkTimer;
//    UIColor *tintColor;
}

@property (assign) NSRange columnRange;
@property (assign) NSRange rowRange;

@property (weak) UIColor *tintColor;

- (void)configureView;
- (void)setBlinking: (BOOL)blink;

@end
