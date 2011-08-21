//
//  MainViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/1/11.
//  Copyright 2011 NUS. All rights reserved.
//

@class Timetable;
@class  ModuleListViewController;

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
@class SearchViewController;
@class WeekViewController;
@class ModuleManager;
@class TimetableController;
@class MilestoneViewController;

@interface MainViewController : UIViewController <UIPopoverControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate> {
    

    IBOutlet TimetableController *timetableController;
    IBOutlet UITableView *timetableView;
        
    IBOutlet UIBarButtonItem *actionButton;
    IBOutlet UIBarButtonItem *modulesButton;
    IBOutlet UITextField *searchField;
    
    UIBarButtonItem *searchItem;    // Container for searchField
    UIPopoverController *popover;
    
    IBOutlet ModuleListViewController *moduleListViewController;
//    WeekViewController *weekViewController;
    
    
    __unsafe_unretained ModuleManager *moduleManager;
        
    NSArray *moduleList;    // Data source for module list table vie
    SearchViewController *searchViewController;
    
    
    UIScrollView *pagingScrollView;
    NSMutableSet *visiblePages; // Contains BookPageViewControllers
    BOOL inPagingMode;
    NSUInteger currentPageIndex;
    
    MilestoneViewController *milestoneVC;
    UINavigationController *milestoneNavigationVC;
    
    UIActionSheet *actionSheet;
    
    // iPhone
    IBOutlet UIBarButtonItem *moduleBtn;
}

@property (strong, nonatomic) Timetable *timetable;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign) ModuleManager *moduleManager;

@property (strong) NSArray *moduleList;
@property (nonatomic, strong) IBOutlet SearchViewController *searchViewController;

@property (strong) UIPopoverController *popover;

- (IBAction)handleActionButton:(id)sender;

- (IBAction)handleModuleButton:(id)sender;

- (void)setPagingMode: (BOOL)mode;
- (void)configurePagingScrollView;


// Paging
- (void) setShowsNoCombinationView: (BOOL)show;

- (void)reloadData;
- (void) reloadPageAtIndex: (NSUInteger)pageIndex;
- (WeekViewController *)pageAtIndex: (NSUInteger)pageIndex;
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex: (NSUInteger)index;
- (NSUInteger) numberOfPages;
- (WeekViewController *)pageViewControllerAtIndex: (NSUInteger)index;
- (CGRect)frameForPageAtIndex: (NSUInteger) index;

- (void)presentMilestoneVC ;
- (void)emailTimetable;
- (void)clearAllModules;
@end
