//
//  SearchViewController.h
//  NUS Mod
//
//  Created by Steven Zhang on 8/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class MainViewController;

enum SegmentedControlIndices {
    kSegmentedControlCodeIndex = 0,
    kSegmentedControlTitleIndex = 1,
    kSegmentedControlDescriptionIndex = 2,
    kSegmentedControlAllIndex = 3
    };

enum Modes {
    kModeAddToModuleList = 0,
    kModeAddToCategory
    };

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate> {
    NSString *searchString;
    
    IBOutlet UITableView *_tableView;
    IBOutlet UISegmentedControl *segmentedControl;
    
    NSArray *resultArray;
    IBOutlet MainViewController *mainViewController;
    IBOutlet UISearchBar *searchBar;
    
    NSInteger mode;
    
    UIPopoverController *popover;


	NSFetchedResultsController *fetchedResultsController;
}

@property (strong) NSString *searchString;
@property (strong) NSArray *resultArray;
@property (assign) NSInteger mode;
@property (readonly) NSManagedObjectContext *managedObjectContext;
//@property (readonly)  NSManagedObjectContext *addingManagedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong) UITableView *tableView;


- (void)updatePredicate;
- (IBAction)segmentedControlValueChanged:(id)sender;



@end
