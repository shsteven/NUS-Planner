//
//  MainViewController.m
//  NUS Mod
//
//  Created by Raymond Hendy on 7/1/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "MainViewController.h"

#import "Timetable.h"

#import "Module.h"

#import "ModuleClass.h"
#import "SearchViewController.h"

#import "WeekViewController.h"
#import "ModuleManager.h"
#import "ModuleListViewController.h"
#import "TimetableController.h"
#import "Constants.h"
#import "Timetable.h"

#import "MilestoneViewController.h"
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

#import "ModuleListViewController(iPhone).h"

@implementation MainViewController

@synthesize managedObjectContext = __managedObjectContext;
@synthesize timetable = __timetable;
@synthesize moduleManager;
@synthesize moduleList;
@synthesize searchViewController;
@synthesize popover;
@synthesize moduleListViewController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    moduleManager = [ModuleManager sharedManager];
    self.title = @"My Timetable 1";
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = moduleBtn;
    }
    
    self.navigationItem.rightBarButtonItem = actionButton;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        self.navigationItem.leftBarButtonItem = modulesButton;
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];

    // Calculate dimensions 
    CGRect frame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = moduleListViewController.view.frame;
        frame.origin.x += frame.size.width;
        frame.size.width = self.view.bounds.size.width - frame.size.width;
    } else {
        frame = self.view.bounds;
    }

    
    visiblePages = [NSMutableSet new];
    
    // Paging scroll view (for browsing all timetable combinations)
    pagingScrollView = [[UIScrollView alloc] initWithFrame:frame];
    pagingScrollView.delegate = self;
    pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;


    pagingScrollView.contentSize = frame.size;
    pagingScrollView.pagingEnabled = YES;
    
    
    [self.view addSubview:pagingScrollView];

    [self tilePages];
    
    
    // Watch for notifications from ModuleManager
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configurePagingScrollView) name:kGeneratedCombinationsDidUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configurePagingScrollViewWithoutReloading) name:kNumberOfPagesDidChangeNotification object:nil];
    
    [self setPagingMode:YES];
    
    NSString *cancelBtn = UI_USER_INTERFACE_IDIOM() ==UIUserInterfaceIdiomPad ? nil : @"Cancel";
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelBtn destructiveButtonTitle:nil otherButtonTitles:@"Email my timetable", @"Clear all modules",nil];
}

- (IBAction)handleModuleButton:(id)sender {
    ModuleListViewController_iPhone_ *listVC = [[ModuleListViewController_iPhone_ alloc] initWithNibName:@"ModuleListViewController(iPhone)" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:listVC];
    [self.navigationController presentModalViewController:navController animated:YES];
}

- (IBAction)handleActionButton:(id)sender {
    if([actionSheet isVisible]) {
        [actionSheet dismissWithClickedButtonIndex:4 animated:YES];
        return;
    }
    [actionSheet showFromBarButtonItem:actionButton animated:YES];
}

//- (IBAction)handleModulesButton:(id)sender {
//    // TODO: SHOW MODULE LIST AND SEARCH
//}

- (void)setPagingMode: (BOOL)mode {
    inPagingMode = mode;
    [self configurePagingScrollView];
    if (inPagingMode) {
        for (WeekViewController *weekVC in visiblePages) {
            [weekVC setInPagingMode:inPagingMode animated:YES];
        }
    }
}

- (void)configurePagingScrollView {
    NSLog(@"configure paging scroll view");
    
    NSUInteger pageCount = 1;
    pagingScrollView.contentOffset = CGPointZero;

    
    if (inPagingMode) {
        pageCount = [moduleManager.combinations count];
        if (pageCount == 0) {
            pagingScrollView.scrollEnabled = NO;
            [self setShowsNoCombinationView: YES];
            
            return;
        } else
            [self setShowsNoCombinationView: NO];
        pagingScrollView.scrollEnabled = YES; 
    } else 
        pagingScrollView.scrollEnabled = NO;
    
    CGSize size = pagingScrollView.bounds.size;
    size.width *= pageCount;
    pagingScrollView.contentSize = size;
    
    
    [self reloadData];
    
    [self scrollViewDidEndDecelerating:pagingScrollView]; // Trigger data source to be set correctly


}

- (void)configurePagingScrollViewWithoutReloading {
    NSLog(@"configure paging scroll view");
    
    NSUInteger pageCount = 1;
//    pagingScrollView.contentOffset = CGPointZero;
    
    
    if (inPagingMode) {
        pageCount = [moduleManager.combinations count];
        if (pageCount == 0) {
            pagingScrollView.scrollEnabled = NO;
            [self setShowsNoCombinationView: YES];
            
            return;
        } else
            [self setShowsNoCombinationView: NO];
        pagingScrollView.scrollEnabled = YES; 
    } else 
        pagingScrollView.scrollEnabled = NO;
    
    CGSize size = pagingScrollView.bounds.size;
    size.width *= pageCount;
    pagingScrollView.contentSize = size;
    
    
//    [self reloadData];
    
    [self scrollViewDidEndDecelerating:pagingScrollView]; // Trigger data source to be set correctly
    

}


- (void) setShowsNoCombinationView: (BOOL)show {
    if (show) {
        WeekViewController *weekVC = [self pageAtIndex:0];
        [weekVC clearAllEventViews];
        
        CGRect frame = CGRectMake(0, 0, 500, 44);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        label.textColor = [UIColor whiteColor];
        label.text = @"Unable to generate timetables because of clashes.\nPlease try removing a module from the list.";
        [weekVC.view addSubview:label];
        label.numberOfLines = 2;
        label.textAlignment = UITextAlignmentCenter;
        label.center = weekVC.view.center;
        label.layer.cornerRadius = 10.0;
    }
}


- (void)reloadData {
    for (WeekViewController *page in visiblePages) {
        [page.view removeFromSuperview];
    }
    
    [visiblePages removeAllObjects];
    
    if (![moduleManager.combinations count]) return;
    [self tilePages];
    NSSet *set = [NSSet setWithArray:[moduleManager.combinations objectAtIndex:0]];
    moduleManager.timetable.selections = set;
    
    [self scrollViewDidEndDecelerating:pagingScrollView];   // Update page number etc.
}

- (void) reloadPageAtIndex: (NSUInteger)pageIndex {
    WeekViewController *page = [self pageAtIndex:pageIndex];
    if (page)
        [page.view setNeedsDisplay];
    
}


- (BOOL)isDisplayingPageForIndex: (NSUInteger)index {
    for (WeekViewController *pageVC in visiblePages) {
        if (pageVC.index == index) return YES;
    }
    
    return NO;
}

- (WeekViewController *)pageAtIndex: (NSUInteger)pageIndex {
    for (WeekViewController *page in visiblePages) {
        if (page.index == pageIndex)
            return page;
    }
    return nil;
}


- (CGRect)frameForPageAtIndex: (NSUInteger) index {
    CGRect frame = pagingScrollView.bounds;
    frame.origin.x = index * frame.size.width;
    return frame;

}

#pragma mark - PagingScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self tilePages];
    self.title = [NSString stringWithFormat:@"My Timetable %d", currentPageIndex + 1];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSSet *set = [NSSet setWithArray:[moduleManager.combinations objectAtIndex:currentPageIndex]];
    moduleManager.timetable.selections = set;

    for (WeekViewController *pageVC in visiblePages) {
        // Swap the data source if appropriate
        if (pageVC.index == currentPageIndex) {
            WeekViewController *pageVC = [self pageAtIndex:currentPageIndex];
            pageVC.timetableController.selections = moduleManager.timetable.selections;
        } else {
            pageVC.timetableController.selections = [moduleManager.combinations objectAtIndex:pageVC.index];
        }
    }
    
}

- (NSUInteger) numberOfPages {
    return MAX(1, [moduleManager.combinations count]);
}

- (void)tilePages
{    
    // Calculate which pages are visible
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    

    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self numberOfPages] - 1);
    
    currentPageIndex = firstNeededPageIndex;
    
    
    // Check datasource
    if (![moduleManager.timetable.selections count] && ![moduleManager.combinations count]) return;
    
//    [pageVC.timetableController reloadData];
    
    // Recycle no-longer-visible pages 
    
    NSMutableSet *removedPages = [NSMutableSet set];
    
    for (WeekViewController *pageVC in visiblePages) {

        
        if (pageVC.index < firstNeededPageIndex || pageVC.index > lastNeededPageIndex) {
            //            [recycledPages addObject:page];
            [pageVC.view removeFromSuperview];
            [removedPages addObject:pageVC];
        }
    }
    [visiblePages minusSet:removedPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index] && index < self.numberOfPages) {
            // ImageScrollView *page = [self dequeueRecycledPage];
            NSLog(@"addPage: %d", index);
            WeekViewController *pageVC = [self pageViewControllerAtIndex:index];
            
            
            CGRect frame;
            

                frame = CGRectMake(visibleBounds.size.width * index, 0, visibleBounds.size.width, visibleBounds.size.height);
            
            pageVC.view.frame = frame;

            [pagingScrollView addSubview:pageVC.view];
            [visiblePages addObject:pageVC];
        }
    }    
}


- (WeekViewController *)pageViewControllerAtIndex: (NSUInteger)index {
    // Create a week view controller and hook up to a timetable controller
    
    WeekViewController *weekVC;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    weekVC = [[WeekViewController alloc] initWithNibName:@"WeekViewController" bundle:nil];
    else
        weekVC = [[WeekViewController alloc] initWithNibName:@"WeekViewController(iPhone)" bundle:nil];

    weekVC.view.frame = [self frameForPageAtIndex:index];
    
    weekVC.index = index;
    
    weekVC.mainViewController = self;
    
    // Hook up to timetableController
    TimetableController *tc = [[TimetableController alloc] init];
    if (index < [moduleManager.combinations count])
    tc.selections = [moduleManager.combinations objectAtIndex:index];
    tc.weekViewController = weekVC;
    weekVC.timetableController = tc;   // WeekVC owns timetableController
    
    [weekVC setInPagingMode:inPagingMode animated:NO];
    
    [tc reloadData];
      
    
    return weekVC;
    
}


#pragma mark PagingScrollView


- (void)viewDidUnload
{
    timetableView = nil;
    actionButton = nil;
    searchField = nil;
    searchItem = nil;
//    weekViewController = nil;
    moduleListViewController = nil;
    timetableController = nil;
    [self setSearchViewController:nil];
    modulesButton = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self configurePagingScrollView];
//    [weekViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
//    if (popoverController == searchPopOver)
//        [searchField resignFirstResponder];
}

#pragma mark ActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
//        case 0:
//            [self presentMilestoneVC];
//            break;
        case 0:
            [self emailTimetable];
            break;
        case 1:
            [self clearAllModules];
            break;
        default:
            break;
    }
}

- (void)presentMilestoneVC {

    milestoneVC = [[MilestoneViewController alloc] initWithNibName:@"MilestoneViewController" bundle:nil];
    
    milestoneNavigationVC = [[UINavigationController alloc] initWithRootViewController:milestoneVC];
    milestoneNavigationVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:milestoneNavigationVC animated:YES];
    
}


#pragma mark Mailing Timetable
- (void)emailTimetable {
    //Create a string with HTML formatting for the email body
    NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"];
    //Add some text to it however you want
    [emailBody appendString:@"<p>Hey, check out the attached timetable!</p>"];

    WeekViewController *currentWeekVC = [self pageAtIndex:currentPageIndex];
    
    UIImage *emailImage = [currentWeekVC snapshot];

    
    //Convert the image into data
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(emailImage)];
    //Create a base64 string representation of the data using NSData+Base64

//    NSString *base64String = [imageData base64EncodedString];
    //Add the encoded string to the emailBody string
    //Don't forget the "<b>" tags are required, the "<p>" tags are optional
//    [emailBody appendString:[NSString stringWithFormat:@"<p><b><img src='data:image/png;base64,%@'></b></p>",base64String]];
//    [emailBody appendString:[NSString stringWithFormat:@"<p><b><img src='timetable.png'></b></p>"]];

    
    //You could repeat here with more text or images, otherwise
    //close the HTML formatting
    [emailBody appendString:@"</body></html>"];
    NSLog(@"%@",emailBody);
    
    //Create the mail composer window
    MFMailComposeViewController *emailDialog = [[MFMailComposeViewController alloc] init];
    emailDialog.mailComposeDelegate = (id)self;
    [emailDialog setSubject:@"My Timetable"];
    [emailDialog setMessageBody:emailBody isHTML:YES];
    
    [emailDialog addAttachmentData:imageData mimeType:@"image/png" fileName:@"timetable.png"];
    
    [self presentModalViewController:emailDialog animated:YES];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"Email Sent!");
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)clearAllModules {
    [moduleManager.timetable setModules:[NSSet set]];
    [moduleManager generateCombinations];
}

- (void)showAbout {
    
}


@end
