//
//  ModuleListViewController(iPhone).h
//  NUS Mod
//
//  Created by Raymond Hendy on 8/14/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@class ModuleManager;

@interface ModuleListViewController_iPhone_ : UITableViewController<UISearchDisplayDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate> {
    ModuleManager *moduleManager;
    NSArray *moduleList;
    IBOutlet UIBarButtonItem *doneBtn;
}

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)updatePredicateWithString:(NSString *)searchString segmentIdx:(NSInteger)idx;

- (IBAction)handleDoneButton:(id)sender;

@end
