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
    
//    [self testEventViews];
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
    UINib *nib = [UINib nibWithNibName:@"ClassView" bundle:nil];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//    isHandlingLongPress = NO;
}

- (void)setInPagingMode: (BOOL)mode animated: (BOOL)animated {
//    CGFloat duration = 0.0;
//    if (animated) duration = 0.3;
//    [UIView animateWithDuration:duration
//                     animations:^{
//                        if (mode)
//                            self.view.transform = CGAffineTransformMakeScale(0.8, 0.8);
//                         else
//                             self.view.transform = CGAffineTransformIdentity;
//                     }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    CGSize size = containerScrollView.bounds.size;
//    size.height *= 2;
//    containerScrollView.contentSize = size;
}

- (void)addEventView: (EventView *)view {
    [eventViews addObject:view];
    [mainHorizontalGridView addSubview:view];
    [mainHorizontalGridView setNeedsLayout];
}

- (void)removeEventView: (EventView *)view {
    [view removeFromSuperview];
    [eventViews removeObject:view];
}

- (void)clearAllEventViews {
    for (UIView *view in eventViews)
        [view removeFromSuperview];
    [eventViews removeAllObjects];
}

- (void)classViewWasTapped: (ClassView *)view {
//    [timetableController beginChoosingAlternativeClassesWithModuleClassDetail:view.classDetail];
}

- (void)handleLongPress: (UILongPressGestureRecognizer *) gr {
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            UIView *view = [self.view hitTest:[gr locationInView:self.view] withEvent:nil];
            if ([view isKindOfClass:[ClassView class]] || [view.class isSubclassOfClass:[ClassView class]]) {
                
//                isHandlingLongPress = YES;
                viewForDragging = view;
                viewForDragging.userInteractionEnabled = NO;

                [UIView animateWithDuration:0.3 animations:^{
//                    viewForDragging.alpha = 0.9;

                    viewForDragging.transform = CGAffineTransformMakeScale(1.2, 1.2);
                }];
                
                ClassView *cView = (ClassView *)view;
                [timetableController beginChoosingAlternativeClassesWithModuleClassDetail:cView.classDetail];
                
                CGPoint point = [gr locationInView:self.view];
                
                viewDraggingOffset = CGPointMake(point.x - view.center.x, point.y - view.center.y);
            }
        }
            
            break;
        case UIGestureRecognizerStateChanged: {
            if (!viewForDragging)
                return;
            
            CGPoint point = [gr locationInView:self.view];
            point.x -= viewDraggingOffset.x;
            point.y -= viewDraggingOffset.y;
            viewForDragging.center = point;

        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (!viewForDragging)
                return;
            

            ClassView *cView = [self destinationClassViewForGestureRecognizer:gr];
            
            CGFloat duration = 0.3;
            //NSMutableArray *temp = [[NSMutableArray alloc] init];
            //NSMutableSet *minusSet = [timetableController alternativeClasses];
            NSSet *setOfSelections = [[ModuleManager sharedManager] timetable].selections;
            /*for (UIView *view in mainHorizontalGridView.subviews) {
                if ([view class] == [ClassView class]) {
                    ClassView *aClassView = (ClassView *)view;
                    if ([minusSet containsObject:[aClassView classDetail].moduleClass]) continue;
                    [temp addObject:[aClassView classDetail].moduleClass];
                }
            }
            NSSet *selections = [[NSSet alloc] initWithArray:temp];*/
            
            if (cView){ 
                BOOL overlaps = [[ModuleManager sharedManager] overlapsWithSet:setOfSelections withModuleClass:[cView classDetail].moduleClass];
                if (!overlaps && (ClassView *)viewForDragging != cView) {
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
//            isHandlingLongPress = NO;
            
        }
            break;
        default:
            break;
    }
}

- (ClassView *)destinationClassViewForGestureRecognizer: (UIGestureRecognizer *)gr {
    UIView *view = [self.view hitTest:[gr locationInView:self.view] withEvent:nil];

    if ([view isKindOfClass:[ClassView class]] || [view.class isSubclassOfClass:[ClassView class]]) {
        if ([timetableController.alternativeClasses containsObject:view])
        return (ClassView *)view;   // Touch within destination view
        else
            return nil;
    }
    
    
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
            return cView;
        }
    }
    
    return nil;
}


@end
