//
//  MainViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/1/11.
//  Copyright 2011 NUS. All rights reserved.
//

@class Timetable;

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
@class SearchViewController;
@class WeekViewController;


@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIPopoverControllerDelegate> {
    

    IBOutlet UITableView *timetableView;
    
    IBOutlet SearchViewController *searchViewController;
    
    IBOutlet UIBarButtonItem *actionButton;
    IBOutlet UITextField *searchField;
    
    UIBarButtonItem *searchItem;    // Container for searchField
    UIPopoverController *searchPopOver;
    IBOutlet UITableView *moduleListTableView;
    
    WeekViewController *weekViewController;
    
    
}

@property (strong, nonatomic) Timetable *timetable;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
