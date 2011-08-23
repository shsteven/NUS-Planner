//
//  WeekViewController.m
//  NUS Mod
//
//  Created by Steven Zhang on 9/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "WeekViewController.h"
#import "ZSVerticalGridView.h"
#import "TimelineLabelView.h"
#import "ZSHorizontalGridView.h"
#import "ClassView.h"
#import "UIColor+Random.h"
#import "ModuleClassDetail.h"
#import "ModuleClass.h"
#import "Module.h"
#import "ModuleManager.h"
#import "TimetableController.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "Timetable.h"

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2){
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
};


@implementation WeekViewController
@synthesize eventViews;
@synthesize classView;
@synthesize index;
@synthesize timetableController;

@synthesize delegate = _delegate;

- (void)updateScrollViewWithIndex:(NSInteger)idx {
    if([_delegate respondsToSelector:@selector(updateCurrentTimetableWithIndex:)]) {
        [_delegate performSelector:@selector(updateCurrentTimetableWithIndex:) withObject:[NSNumber numberWithInt:idx]];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eventViews = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (UIImage *)snapshot {
    NSLog(@"weekviewcontroller snapshot");
    
    CGRect originalFrame = self.view.frame;
    CGRect frame = originalFrame;
    frame.size.height = mainHorizontalGridView.frame.size.height + headerVerticalGridView.frame.size.height + 3;
    self.view.frame = frame;
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.frame = originalFrame;
    return resultingImage;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    headerVerticalGridView.numberOfColumns = 6;
    mainVerticalGridView.numberOfColumns = 6;
    mainHorizontalGridView.numberOfRows = 30;  // 48; 7AM to 10pm = 30 * 0.5 hours
    mainHorizontalGridView.numberOfColumns = 6; // Ignore Sunday
    timelineLabelView.numberOfRows = 15;    // 7Am to 10PM
    // Configure scroll view
    
    CGSize size = mainVerticalGridView.frame.size;
    size.height *= 2;

    containerScrollView.contentSize = size;
    CGRect frame;
    frame = mainHorizontalGridView.frame;
    frame.size.height = size.height;
    mainHorizontalGridView.frame = frame;
    frame = timelineLabelView.frame;
    frame.size.height = size.height;
    timelineLabelView.frame = frame;
    
    NSMutableArray *array = [NSMutableArray array];
    NSArray *weekdaySymbols = [[[NSDateFormatter alloc] init ] weekdaySymbols];
    // Make i start from 1 to ignore Sunday
    UIColor *textColor = [UIColor colorWithRed:GRID_COLOR_R green:GRID_COLOR_G blue:GRID_COLOR_B alpha:1.0];
    textColor = [textColor darkerColor];
    
    for (int i=1; i<7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = [weekdaySymbols objectAtIndex:i];

        label.textColor = textColor;
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
        } else
            label.font = [UIFont systemFontOfSize:12];
        
        
        [array addObject:label];
        
        
    }
    [headerVerticalGridView setTitleViews:array];
 
    
    
    array = [NSMutableArray array];
    for (int i= 7; i < 23; i++) {   // 7:00 to 22:00
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = (NSString *)HOURS_AM_PM[i];
        label.textColor = textColor;
        label.font = [UIFont systemFontOfSize:8];
        label.lineBreakMode = UILineBreakModeTailTruncation;
        label.textAlignment = UITextAlignmentRight;
        [array addObject:label];
    }
    
    [timelineLabelView setTitleViews:array];
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPressGR];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGR];
    
//    [self testEventViews];
    overlappingViewsInQuestion = nil;
}

- (void)testEventViews {
    for (int i=0; i<7; i++) {
        UINib *nib = [UINib nibWithNibName:@"ClassView" bundle:nil];
        NSArray *array = [nib instantiateWithOwner:self options:NULL];
        ClassView *view = [array objectAtIndex:0];
        view.columnRange = NSMakeRange(i, 1);
        view.rowRange = NSMakeRange(i, 4);
        view.tintColor = [UIColor randomColor];
        [self addEventView:view];
        self.classView = nil;
    }
}

- (ClassView *)newClassView {
    UINib *nib;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nib = [UINib nibWithNibName:@"ClassView" bundle:nil];
    } else {
            nib = [UINib nibWithNibName:@"ClassView(iPhone)" bundle:nil];
    }

    [nib instantiateWithOwner:self options:NULL];
    ClassView *view = self.classView;
    self.classView = nil;
    return view;
}

- (void)viewDidUnload
{
    mainVerticalGridView = nil;
    headerVerticalGridView = nil;
    mainHorizontalGridView = nil;
    timelineLabelView = nil;
    containerScrollView = nil;
    [super viewDidUnload];
}

- (void)setInPagingMode: (BOOL)mode animated: (BOOL)animated {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (void)addEventView: (EventView *)view {
    [eventViews addObject:view];
    [mainHorizontalGridView addSubview:view];
    [self tagEventViews];
    [mainHorizontalGridView setNeedsLayout];
}

- (void)removeEventView: (EventView *)view {
    [view removeFromSuperview];
    [eventViews removeObject:view];
    [self tagEventViews];
    [mainHorizontalGridView setNeedsLayout];
}

- (void)clearAllEventViews {
    for (UIView *view in eventViews)
        [view removeFromSuperview];
    [eventViews removeAllObjects];
}

- (void)classViewWasTapped: (ClassView *)view {
//    [timetableController beginChoosingAlternativeClassesWithModuleClassDetail:view.classDetail];
    // TODO: show detail view

    
    
    
    if (overlappingViewsInQuestion) {
        if ([overlappingViewsInQuestion indexOfObject:view] == NSNotFound) {
            // Not dealing with a bunch of spaced out overlapping views
            [mainHorizontalGridView collapseOverllapingViews:overlappingViewsInQuestion];
            overlappingViewsInQuestion = nil;
        }

        return;
    } 
    
    
    // Space out overlapping views (if any)
    NSArray *overlappingViews = [self overlappingEventViewsForEventView:view];
    if ([overlappingViews count]) {
        [mainHorizontalGridView spaceOutOverlappingViews:overlappingViews];
        overlappingViewsInQuestion = overlappingViews;
    }
    
}

- (void)handleTap: (UITapGestureRecognizer *)gr {
    if (overlappingViewsInQuestion) {
        [mainHorizontalGridView collapseOverllapingViews:overlappingViewsInQuestion];
        overlappingViewsInQuestion = nil;
    }
}

- (void)handleLongPress: (UILongPressGestureRecognizer *) gr {
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            // Picked up a class
            UIView *view = [self.view hitTest:[gr locationInView:self.view] withEvent:nil];
            if ([view isKindOfClass:[ClassView class]] || [view.class isSubclassOfClass:[ClassView class]]) {
                
                if (overlappingViewsInQuestion) {
                    // Leave the picked up view along...restore the positions of the rest
                    NSMutableArray *array = [overlappingViewsInQuestion mutableCopy];
                    [array removeObject:view];
                    [mainHorizontalGridView collapseOverllapingViews:array];
                    
                    overlappingViewsInQuestion = nil;
                }
                
                viewForDragging = view;
                viewForDragging.userInteractionEnabled = NO;

                [UIView animateWithDuration:0.3 animations:^{
                    viewForDragging.transform = CGAffineTransformMakeScale(1.2, 1.2);
                }];
                
                ClassView *cView = (ClassView *)view;
                [timetableController beginChoosingAlternativeClassesWithModuleClassDetail:cView.classDetail];                
                CGPoint point = [gr locationInView:self.view];
                
                viewDraggingOffset = CGPointMake(point.x - view.center.x, point.y - view.center.y);
                proposedDestinationView = nil;
            }
        }
            
            break;
        case UIGestureRecognizerStateChanged: {
            // Dragging a classView around
            if (!viewForDragging)
                return;
            
            CGPoint point = [gr locationInView:self.view];
            point.x -= viewDraggingOffset.x;
            point.y -= viewDraggingOffset.y;
            viewForDragging.center = point;

        }
            break;
        case UIGestureRecognizerStateEnded:
         {
             // Dropped a view
             
            if (!viewForDragging)
                return;
            

            ClassView *cView = [self destinationClassViewForGestureRecognizer:gr];
            
            CGFloat duration = 0.3;

             NSSet *setOfSelections = [[ModuleManager sharedManager] timetable].selections;
            
            if (cView){ 
                if (cView == viewForDragging) {
                    // View dropped on itself
                    // Drop back to original place 
                    [UIView animateWithDuration:duration
                                     animations:^{
                                         viewForDragging.frame = [mainHorizontalGridView frameForEventView:(EventView *)viewForDragging];
                                         viewForDragging.alpha = 1;
                                         viewForDragging.transform = CGAffineTransformIdentity;
                                     } completion:^(BOOL finished) {
                                         [timetableController endChoosingAlternativeClassesWithModuleClassDetail:nil];
                                         
                                     }];
                    viewForDragging = nil;
                    return;
                }
                
                BOOL overlaps = [[ModuleManager sharedManager] overlapsWithSet:setOfSelections withModuleClass:[cView classDetail].moduleClass];
                
                if (overlaps) {
                    // Ask the user: "there's a clash..."
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This time slot is taken by another class" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Ignore clash" otherButtonTitles:@"Cancel", nil];
                    CGPoint point = [gr locationInView:self.view];
                    [actionSheet showFromRect:CGRectMake(point.x, point.y, 1.0, 1.0) inView:self.view animated:YES];
                    proposedDestinationView = cView;  
                    return;
                }

                if (!overlaps) {
                    [UIView animateWithDuration:duration
                                     animations:^{
                                         viewForDragging.frame = cView.frame;
                                     } completion:^(BOOL finished) {
                                         [timetableController endChoosingAlternativeClassesWithModuleClassDetail:cView.classDetail];

                                     }];
                }
                else {
                    [UIView animateWithDuration:duration
                                     animations:^{
                                         viewForDragging.frame = [mainHorizontalGridView frameForEventView:(EventView *)viewForDragging];
                                         viewForDragging.alpha = 1;
                                         viewForDragging.transform = CGAffineTransformIdentity;
                                     } completion:^(BOOL finished) {
                                         [timetableController endChoosingAlternativeClassesWithModuleClassDetail:nil];
                                         
                                     }];
                }
                
            } else {
                [UIView animateWithDuration:duration
                                 animations:^{
                                     viewForDragging.frame = [mainHorizontalGridView frameForEventView:(EventView *)viewForDragging];
                                     viewForDragging.alpha = 1;
                                     viewForDragging.transform = CGAffineTransformIdentity;
                                 } completion:^(BOOL finished) {
                                     [timetableController endChoosingAlternativeClassesWithModuleClassDetail:nil];
                                     
                                 }];

            }
            
            viewForDragging.userInteractionEnabled = YES;
            viewForDragging = nil;
             proposedDestinationView = nil;
            
        }
            break;
        case UIGestureRecognizerStateCancelled: {
            // Restore to original state
            
            CGFloat duration = 0.3;

            [UIView animateWithDuration:duration
                             animations:^{
                                 viewForDragging.frame = [mainHorizontalGridView frameForEventView:(EventView *)viewForDragging];
                                 viewForDragging.alpha = 1;
                                 viewForDragging.transform = CGAffineTransformIdentity;
                             } completion:^(BOOL finished) {
                                 [timetableController endChoosingAlternativeClassesWithModuleClassDetail:nil];
                                 
                             }];
            proposedDestinationView = nil;
        }
            break;
        default:
            break;
    }
}

- (ClassView *)destinationClassViewForGestureRecognizer: (UIGestureRecognizer *)gr {
    CGPoint point = [gr locationInView:self.view];
    
    UIView *view = [self.view hitTest:point withEvent:nil];

    if ([view isKindOfClass:[ClassView class]] || [view.class isSubclassOfClass:[ClassView class]]) {
        if ([timetableController.alternativeClasses containsObject:view])
            return (ClassView *)view;   // Touch within destination view
        else
            return nil;
    } 
    
    // Find out the closest event view
    CGFloat minDistance = CGFLOAT_MAX;
    CGFloat threashold = 30.0; // For snapping to view
    
    ClassView *viewWithMinDistance = nil;
    
    for (ClassView *cView in timetableController.alternativeClasses) {
        // Calculate distance
        CGFloat distance = DistanceBetweenTwoPoints([gr locationInView:gr.view], cView.center);
        if (distance < minDistance) {
            minDistance = distance;
            viewWithMinDistance = cView;
        }
        
        if (minDistance < threashold) {
            return viewWithMinDistance;
        }
    }
    
    return nil;
}

- (BOOL) eventView: (EventView *)ev1 overlapsWithEventView: (EventView *)ev2 {
    // If both columnRange and rowRange have overlaps
    if (NSIntersectionRange(ev1.columnRange, ev2.columnRange).length && NSIntersectionRange(ev1.rowRange, ev2.rowRange).length)
        return YES;
    
    return NO;
}

- (NSArray *)overlappingEventViewsForEventView: (EventView *)eventView {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:eventView];
    for (EventView *view in self.eventViews) {
        if (eventView == view) continue;
        if ([self eventView:view overlapsWithEventView:eventView])
            [array addObject:view];
    }
    
    // Sort event views
    // Earlier event comes first
    // Larger event comes first
    [array sortUsingComparator:^(id obj1, id obj2) {
        EventView *ev1 = (EventView *)obj1;
        EventView *ev2 = (EventView *)obj2;
        if (ev1.rowRange.location < ev2.rowRange.location) return NSOrderedAscending;
        if (ev1.rowRange.location > ev2.rowRange.location) return NSOrderedDescending;

        if (ev1.rowRange.length > ev2.rowRange.length) return NSOrderedAscending;
        if (ev1.rowRange.length < ev2.rowRange.length) return NSOrderedDescending;

        return NSOrderedSame;
    }];

    return [array copy];
}

- (void)tagEventViews {
    NSMutableArray *array = [[self.eventViews allObjects] mutableCopy];
    while ([array count]) {
        EventView *eventView = [array lastObject];
        NSArray *clashingEventViews = [self overlappingEventViewsForEventView:eventView];
        [array removeObjectsInArray:clashingEventViews];
        if ([clashingEventViews count]) {
            for (EventView *anEventView in clashingEventViews)
                anEventView.tag = [clashingEventViews indexOfObject:anEventView];
        }
    }
}


#pragma mark Action Sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    CGFloat duration = 0.3;
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        // Restore to original position
        [UIView animateWithDuration:duration
                         animations:^{
                             viewForDragging.frame = [mainHorizontalGridView frameForEventView:(EventView *)viewForDragging];
                             viewForDragging.alpha = 1;
                             viewForDragging.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [timetableController endChoosingAlternativeClassesWithModuleClassDetail:nil];
                             
                         }];
        
    
    
        viewForDragging.userInteractionEnabled = YES;
        viewForDragging = nil;
        return;
    }
    
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        ClassView *destinationClassView = proposedDestinationView;  // Remember the value before it's set to nil
        [UIView animateWithDuration:duration
                         animations:^{
                             viewForDragging.frame = proposedDestinationView.frame;
                         } completion:^(BOOL finished) {
                             [timetableController endChoosingAlternativeClassesWithModuleClassDetail:destinationClassView.classDetail];
                             
                         }];
        viewForDragging = nil;
        proposedDestinationView = nil;
        return;
    }
}
@end
