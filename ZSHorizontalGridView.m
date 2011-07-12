//
//  ZSHorizontalGridView.m
//  NUS Mod
//
//  Created by Steven Zhang on 10/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "ZSHorizontalGridView.h"
#import "Constants.h"
#import "EventView.h"

@implementation ZSHorizontalGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        numberOfRows = 0;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews {
    for (UIView *aView in self.subviews) {
        if (aView.class == [EventView class] || [aView.class isSubclassOfClass:[EventView class]]) {
            EventView *eventView = (EventView *)aView;
            eventView.frame = [self frameForEventView:eventView];
        }
    }
}

- (CGRect)frameForEventView: (EventView *)view {
    if (numberOfRows <1 || numberOfColumns < 1) return CGRectZero;
    // Calculate event view position according to column / row numbers
    CGFloat unitWidth = self.bounds.size.width / numberOfColumns;
    CGFloat unitHeight = self.bounds.size.height / numberOfRows;
    
    CGRect frame = CGRectZero;
    
    
    frame.origin.x = floorf(unitWidth * view.columnRange.location);
    frame.size.width = ceilf(unitWidth * view.columnRange.length);
    frame.origin.y = floorf(unitHeight * view.rowRange.location);
    frame.size.height = ceilf(unitHeight * view.rowRange.length);
    
    frame = CGRectInset(frame, 1.0, 1.0);
    return frame;
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIColor *color = [UIColor colorWithRed:GRID_COLOR_R green:GRID_COLOR_G blue:GRID_COLOR_B alpha:1.0];
    [color set];
    
    CGFloat lineWidth = 1.0;
    
    color = [UIColor redColor]; // Debug
    
    /*
    CGContextSaveGState(ctx);
    
    // Draw a bounding box    
    
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    
    CGContextBeginPath(ctx);
    CGContextAddRect(ctx,CGRectInset(self.bounds, 1.0, 1.0));
    CGContextStrokePath(ctx);
    
    CGContextRestoreGState(ctx);
    */
    
    
    
    // Draw vertical lines
    if (numberOfRows <= 1) {
        return;
    }
    
    
    CGContextSaveGState(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    
    
//    CGFloat height = self.bounds.size.height / numberOfRows;
    CGFloat width = self.bounds.size.width;

    CGFloat y = 0.0;
    CGFloat spacing = self.bounds.size.height / numberOfRows;
    
    BOOL useDashedLine = NO;
//    NSLog(@"%f", self.bounds.size.height);
    while (y <= self.bounds.size.height+1.0) {
        if (useDashedLine) {
            // Dashed line
            CGFloat dashes[] = {1,1};
            CGContextSetLineDash(ctx, 0.0, dashes, 2);
        } else {
            CGContextSetLineDash(ctx, 0.0, NULL, 0);
        }

        if (y >= self.bounds.size.height)
            y=self.bounds.size.height-1; // Otherwise line gets clipped
        
        CGContextMoveToPoint(ctx, 0.0, floorf(y)+0.5);
        CGContextAddLineToPoint(ctx, width, floorf(y)+0.5);
        y+=spacing;
        useDashedLine = !useDashedLine;
        
        CGContextStrokePath(ctx);
    }
    
//    CGContextStrokePath(ctx);
    
//    CGContextMoveToPoint(ctx, 0.0, 938+0.5);
//    CGContextAddLineToPoint(ctx, width, 938+0.5);
//    CGContextStrokePath(ctx);

	CGContextRestoreGState(ctx);
    
    
    
    
}


- (NSUInteger)numberOfRows {
    return numberOfRows;
}

- (void)setNumberOfRows:(NSUInteger)n {
    numberOfRows = n;
    [self setNeedsDisplay];
}

- (NSUInteger)numberOfColumns {
    return numberOfRows;
}

- (void)setNumberOfColumns:(NSUInteger)n {
    numberOfColumns = n;
    [self setNeedsLayout];
}

@end
