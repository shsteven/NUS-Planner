//
//  ZSVerticalGridView.h
//  NUS Mod
//
//  Created by Steven Zhang on 9/7/11.
//  Copyright 2011 NUS. All rights reserved.
//
//  Draws bounding box and vertical lines

#import <UIKit/UIKit.h>

@interface ZSVerticalGridView : UIView {
    NSUInteger numberOfColumns;
    NSArray *titleViews;
}

@property (assign) NSUInteger numberOfColumns;
@property (strong) NSArray *titleViews;

@end
