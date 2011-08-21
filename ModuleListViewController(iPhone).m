//
//  ModuleListViewController(iPhone).m
//  NUS Mod
//
//  Created by Raymond Hendy on 8/14/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "ModuleListViewController(iPhone).h"

#import "ModuleManager.h"
#import "Timetable.h"
#import "Module.h"

#import "ModuleDetailViewController(iPhone).h"

@implementation ModuleListViewController_iPhone_

@synthesize managedObjectContext = __managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)reloadDataFromManager {
    moduleList = [moduleManager.timetable.modules allObjects];
    [self.tableView reloadData];
}

- (IBAction)handleDoneButton:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    
    self.title = @"Modules Taking";
    
    self.navigationItem.rightBarButtonItem = doneBtn;
    
    self.navigationController.toolbarHidden = YES;
    
    moduleManager = [ModuleManager sharedManager];
    moduleList = [moduleManager.timetable.modules allObjects];
    
    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchDisplayController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Code", @"Title", @"Desc", @"All", nil];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewDidUnload
{
    doneBtn = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[__fetchedResultsController sections] objectAtIndex:0];
        return [sectionInfo numberOfObjects];
    } else {
        return [moduleList count]; 
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ModuleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Module *m;
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        m = [__fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        m = [moduleList objectAtIndex:indexPath.row];        
    }

    cell.textLabel.text = m.code;
    if (tableView == self.tableView) {
        cell.textLabel.alpha = [m.enabled boolValue] ? 1.0 : 0.6;
        cell.detailTextLabel.alpha = [m.enabled boolValue] ? 1.0 : 0.6;
    }
    
    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Exam date: %@", m.examDate];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */

    BOOL searchMode;
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        searchMode = YES;
    } else {
        searchMode = NO;
    }
    
    Module *m;
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        m = [__fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        m = [moduleList objectAtIndex:indexPath.row];        
    }
    
    ModuleDetailViewController_iPhone_ *detailViewController =
    [[ModuleDetailViewController_iPhone_ alloc] initWithNibName:@"ModuleDetailViewController(iPhone)" bundle:nil module:m searchMode:searchMode delegate:self];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{   
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    
    NSInteger idx = controller.searchBar.selectedScopeButtonIndex;
    [self updatePredicateWithString:searchString segmentIdx:idx];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self updatePredicateWithString:controller.searchBar.text segmentIdx:searchOption];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Book entity.
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setFetchBatchSize:20];
    
    NSEntityDescription *ent;
    NSPredicate *pre;
    
    ent = [NSEntityDescription entityForName:@"Module" inManagedObjectContext:self.managedObjectContext];
    req.entity = ent;
    
    
    // Configure according to search type
    
    pre = [NSPredicate predicateWithValue:YES];
    req.predicate = pre;
    req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
    
    
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
	self.fetchedResultsController = aFetchedResultsController;
	__fetchedResultsController.delegate = self;
	
	return __fetchedResultsController;
}    

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.searchDisplayController.searchResultsTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	UITableView *tableView = self.searchDisplayController.searchResultsTableView;
    
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    UITableView *tableView = self.searchDisplayController.searchResultsTableView;
    
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.searchDisplayController.searchResultsTableView endUpdates];
}

- (void)updatePredicateWithString:(NSString *)searchString segmentIdx:(NSInteger)idx {
    NSPredicate *pre;
    NSFetchRequest *req = self.fetchedResultsController.fetchRequest;
    
    switch (idx) {
        case 0: {
            pre = [NSPredicate predicateWithFormat:@"code CONTAINS[cd] %@",searchString];
            
            req.predicate = pre;
            req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
        }
            break;
        case 1: {
            pre = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@",searchString];
        }
            break;
        case 2: {
            pre = [NSPredicate predicateWithFormat:@"moduleDescription CONTAINS[cd] %@",searchString];
        }
            break;
        case 3: {
            pre = [NSPredicate predicateWithFormat:@"code CONTAINS[cd] %@ OR title CONTAINS[cd] %@ OR moduleDescription CONTAINS[cd] %@",searchString,searchString,searchString];
        }
            break;
        default:
            break;
    }
    
    req.predicate = pre;
    req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
    self.fetchedResultsController.fetchRequest.predicate = pre;
}

- (NSManagedObjectContext *)managedObjectContext {
    return [[ModuleManager sharedManager] managedObjectContext];
}

- (void)addButtonTappedForModule:(Module *)module {
    module.enabled = [NSNumber numberWithBool:YES];
    [moduleManager addModule:module];
    [self reloadDataFromManager];
    [self.searchDisplayController setActive:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)enableButtonTappedForModule:(Module *)module  {
    if ([module.enabled boolValue])
        [moduleManager disableModule:module];
    else
        [moduleManager enableModule:module];
    [self reloadDataFromManager];
}

- (void)removeButtonTappedForModule: (Module *)module {
    [moduleManager removeModule:module];
    [self reloadDataFromManager];
}

@end
