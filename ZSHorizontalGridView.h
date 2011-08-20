//
//  ZSHorizontalGridView.h
//  NUS Mod
//
//  Created by Steven Zhang on 10/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventView;

@interface ZSHorizontalGridView : UIView {
    NSUInteger numberOfRows;
    NSUInteger numberOfColumns; // Need this for laying out subviews
}


@property (assign) NSUInteger numberOfRows;
@property (assign) NSUInteger numberOfColumns;

- (CGRect)frameForEventView: (EventView *)view;

// Overlapping views: tapped->space out so that they can be dragged
- (void)spaceOutOverlappingViews: (NSArray *)views;
- (void)collapseOverllapingViews: (NSArray *)views;
@end
