//
//  TimelineLabelView.h
//  NUS Mod
//
//  Created by Steven Zhang on 9/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineLabelView : UIView {
    NSArray *titleViews;
    NSUInteger numberOfRows;


}

@property (assign) NSUInteger numberOfRows;

@property (strong) NSArray *titleViews;


@end
