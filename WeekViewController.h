//
//  WeekViewController.h
//  NUS Mod
//
//  Created by Steven Zhang on 9/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSVerticalGridView;
@class TimelineLabelView;
@class ZSHorizontalGridView;
@class EventView;
@class ClassView;
@class TimetableController;
static NSString const * const HOURS_AM_PM[] = {
	@" 12 AM", @" 1 AM", @" 2 AM", @" 3 AM", @" 4 AM", @" 5 AM", @" 6 AM", @" 7 AM", @" 8 AM", @" 9 AM", @" 10 AM", @" 11 AM",
	@" Noon", @" 1 PM", @" 2 PM", @" 3 PM", @" 4 PM", @" 5 PM", @" 6 PM", @" 7 PM", @" 8 PM", @" 9 PM", @" 10 PM", @" 11 PM", @" 12 PM"
};

static NSString const * const HOURS_24[] = {
	@" 0:00", @" 1:00", @" 2:00", @" 3:00", @" 4:00", @" 5:00", @" 6:00", @" 7:00", @" 8:00", @" 9:00", @" 10:00", @" 11:00",
	@" 12:00", @" 13:00", @" 14:00", @" 15:00", @" 16:00", @" 17:00", @" 18:00", @" 19:00", @" 20:00", @" 21:00", @" 22:00", @" 23:00", @" 0:00"
};


@interface WeekViewController : UIViewController {
    
    IBOutlet ZSVerticalGridView *headerVerticalGridView;
    IBOutlet ZSVerticalGridView *mainVerticalGridView;
    IBOutlet TimelineLabelView *timelineLabelView;
    IBOutlet ZSHorizontalGridView *mainHorizontalGridView;
    
    IBOutlet UIScrollView *containerScrollView;
    
    NSMutableSet *eventViews;
    
    ClassView *classView; // For loading from nib only
    
    NSUInteger index;
    
    TimetableController *timetableController;
//    BOOL isHandlingLongPress;

    UIView *viewForDragging;
    
    CGPoint viewDraggingOffset;
}

@property (assign) id delegate;

@property (strong) NSMutableSet *eventViews;
@property (strong, atomic) IBOutlet ClassView *classView;
@property (assign) NSUInteger index;
@property (strong) TimetableController *timetableController;
- (void)addEventView: (EventView *)view;
- (void)removeEventView: (EventView *)view;
- (void)clearAllEventViews;

- (ClassView *)newClassView;

- (void)testEventViews;


- (void)classViewWasTapped: (ClassView *)view;

- (void)setInPagingMode: (BOOL)mode animated: (BOOL)animated;

- (ClassView *)destinationClassViewForGestureRecognizer: (UIGestureRecognizer *)gr;

- (UIImage *)snapshot;

- (void)updateScrollViewWithIndex:(NSInteger)idx;

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);

@end

@protocol WeekViewControllerDataSource <NSObject>

- (NSUInteger)numberOfColumnsInWeekViewController: (id)controller;
- (NSUInteger)numberOfItemsInWeekViewController: (id)controller column: (NSUInteger)columnIndex;
- (UIView *)viewForItemInWeekViewController: (id)controller atIndexPath: (NSIndexPath *)indexPath;


@end


@protocol WeekViewControllerDelegate <NSObject>



@end