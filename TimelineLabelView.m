//
//  TimelineLabelView.m
//  NUS Mod
//
//  Created by Steven Zhang on 9/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "TimelineLabelView.h"

@implementation TimelineLabelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        numberOfRows = 0;
    }
    return self;
}

- (void)layoutSubviews {
    if (titleViews && [titleViews count] && numberOfRows > 0) {
        CGFloat height = self.bounds.size.height / numberOfRows;
        CGRect frame;
        CGFloat y = 0.0;
        CGFloat width = self.bounds.size.width;
        for (int i=0; i<[titleViews count]; i++) {
            frame = CGRectMake(0.0, floorf(y), width, ceilf(height));
            UIView *view = [titleViews objectAtIndex:i];
            view.frame = frame;
//            NSLog(@"layout view: %@", NSStringFromCGRect(frame));
            y+=height;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSArray *)titleViews {
    return titleViews;
}

- (void)setTitleViews:(NSArray *)array {
    if (titleViews)
        for (UIView *view in titleViews)
            [view removeFromSuperview];
    titleViews = array;
    for (UIView *view in array)
        [self addSubview:view];
    [self setNeedsLayout];
}

- (NSUInteger)numberOfRows {
    return numberOfRows;
}

- (void)setNumberOfRows:(NSUInteger)n {
    numberOfRows = n;
    [self setNeedsDisplay];
}

@end
