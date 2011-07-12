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

@implementation WeekViewController
@synthesize eventViews;
@synthesize classView;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    headerVerticalGridView.numberOfColumns = 7;
    mainVerticalGridView.numberOfColumns = 7;
    mainHorizontalGridView.numberOfRows = 48;
    mainHorizontalGridView.numberOfColumns = 7;
    timelineLabelView.numberOfRows = 24;
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
    for (int i=0; i<7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = [weekdaySymbols objectAtIndex:i];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
//        label.adjustsFontSizeToFitWidth = YES;

        [array addObject:label];
    }
    [headerVerticalGridView setTitleViews:array];
 
    
    
    array = [NSMutableArray array];
    for (int i= 0; i < 25; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = (NSString *)HOURS_AM_PM[i];
        label.font = [UIFont systemFontOfSize:8];
        label.lineBreakMode = UILineBreakModeTailTruncation;
        label.textAlignment = UITextAlignmentRight;
        [array addObject:label];
    }
    
    [timelineLabelView setTitleViews:array];
    
    
    [self testEventViews];
}

- (void)testEventViews {
    for (int i=0; i<7; i++) {
        UINib *nib = [UINib nibWithNibName:@"ClassView" bundle:nil];
        NSArray *array = [nib instantiateWithOwner:self options:NULL];
//        NSLog(@"array: %@", array);
//        EventView *view = [[EventView alloc] initWithFrame:CGRectZero];
        ClassView *view = [array objectAtIndex:0];
        view.columnRange = NSMakeRange(i, 1);
        view.rowRange = NSMakeRange(i, 4);
        view.tintColor = [UIColor randomColor];
        [self addEventView:view];
        self.classView = nil;
    }
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
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
    NSLog(@"tapped %@", view);
}

@end
