//
//  ZSVerticalGridView.m
//  NUS Mod
//
//  Created by Steven Zhang on 9/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "ZSVerticalGridView.h"
#import "Constants.h"

@implementation ZSVerticalGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        numberOfColumns = 0;
    }
    return self;
}


- (void)layoutSubviews {
    if (titleViews && [titleViews count] && numberOfColumns > 0) {
        CGFloat width = self.bounds.size.width / numberOfColumns;
        CGRect frame;
        CGFloat x = 0.0;
        CGFloat height = self.bounds.size.height;
        for (int i=0; i<[titleViews count]; i++) {
            frame = CGRectMake(floorf(x), 0, ceilf(width), height);
            UIView *view = [titleViews objectAtIndex:i];
            view.frame = frame;
            x+= width;
        }
    }
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
    
    CGContextSaveGState(ctx);
    
    // Draw a bounding box    

    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    
    CGContextBeginPath(ctx);
    CGContextAddRect(ctx,CGRectInset(self.bounds, 0.5, 0.5));
    CGContextStrokePath(ctx);

    CGContextRestoreGState(ctx);
     
    
    // Draw vertical lines
    if (numberOfColumns <= 1) {
        return;
    }
    
    
    CGContextSaveGState(ctx);

    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    
    CGFloat x = 0.0;
    CGFloat spacing = self.bounds.size.width / numberOfColumns;
    CGFloat height = self.bounds.size.height;
    while (x < self.bounds.size.width) {
//        if (x >= self.bounds.size.width)
//            x-=1; // Prevent clipping
        
        CGContextMoveToPoint(ctx, floorf(x)+0.5, 0.0);
        CGContextAddLineToPoint(ctx, floorf(x)+0.5, height);
        
        CGContextStrokePath(ctx);

        x+=spacing;

    }
    


    
	CGContextRestoreGState(ctx);
    
    

    
}

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

- (NSUInteger)numberOfColumns {
    return numberOfColumns;
}

- (void)setNumberOfColumns:(NSUInteger)n {
    numberOfColumns = n;
    [self setNeedsDisplay];
}

@end
