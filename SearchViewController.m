//
//  SearchViewController.m
//  NUS Mod
//
//  Created by Steven Zhang on 8/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "SearchViewController.h"
#import "ModuleManager.h"
#import "Module.h"
#import "MainViewController.h"
#import "ModuleDetailViewController.h"

@implementation SearchViewController
@synthesize resultArray;
@synthesize mode;
@synthesize fetchedResultsController;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mode = 0;
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
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewDidUnload
{
    segmentedControl = nil;
    _tableView = nil;
    searchBar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (popover) [popover dismissPopoverAnimated:YES], popover = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [searchBar becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (NSString *)searchString {
    return searchString;
}

- (void)setSearchString:(NSString *)string {
    searchString = string;
    
    if (!searchString || ![searchString length]) return;
    
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    
    
    NSError *error;
    //    fetchedResultsController = nil;
    [self updatePredicate];
    
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    [self.tableView reloadData];
    
    //    if (!searchString) {
    //        // Nothing to search, show empty result
    //        [_tableView reloadData];
    //    }
    //    
    //    // Update search result
    //    ModuleManager *manager = [ModuleManager sharedManager];
    //    
    //    switch (segmentedControl.selectedSegmentIndex) {
    //        case kSegmentedControlCodeIndex: {
    //            resultArray = [manager allModulesByCode:string]; // TODO
    //        }
    //            break;
    //        case kSegmentedControlTitleIndex: {
    //            resultArray = [manager allModulesByTitle:string]; // TODO
    //        }
    //            break;
    //        case kSegmentedControlDescriptionIndex: {
    //            resultArray = [manager allModulesByDescription:string]; // TODO
    //        }
    //            break;
    //        case kSegmentedControlAllIndex: {
    //            resultArray = [manager modulesBySearchTerm:string];
    //        }
    //            break;
    //        default:
    //            break;
    //    }
    //    
    //
    //    [_tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[fetchedResultsController sections] count];
    
    if (resultArray)
        return 1;
    
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
    
    if (resultArray)
        return [resultArray count];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Module *aModule = [fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = aModule.code;
    cell.detailTextLabel.text = aModule.title;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Module *aModule = [fetchedResultsController objectAtIndexPath:indexPath]; //[resultArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (mainViewController.popover) {        
        ModuleDetailViewController *detailVC = [[ModuleDetailViewController alloc] initWithNibName:@"ModuleDetailViewController" bundle:nil showButtons:NO];
        detailVC.module = aModule;
        popover = [[UIPopoverController alloc] initWithContentViewController:detailVC];
        [popover presentPopoverFromRect:[mainViewController.view convertRect:cell.frame fromView:_tableView] inView:mainViewController.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        
    }
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
    
    if (popover) [popover dismissPopoverAnimated:YES], popover = nil;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Module *aModule = [[self fetchedResultsController] objectAtIndexPath:indexPath];// [resultArray objectAtIndex:indexPath.row];
    
    ModuleManager *manager = [ModuleManager sharedManager];
    switch (mode) {
        case kModeAddToModuleList:
            [manager addModule:aModule];
            
            break;
        case kModeAddToCategory:
            break;
        default:
            break;
    }
    
    
    [searchBar resignFirstResponder];
    //    [mainViewController.popover dismissPopoverAnimated:YES];
    // Optional: an animation that makes a module jump to 
    
}


- (IBAction)segmentedControlValueChanged:(id)sender {
    fetchedResultsController = nil;
    
    [self setSearchString:self.searchString]; // Trigger a search
    [self updatePredicate];
    
}

#pragma mark - Search Bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self setSearchString:searchText];
    
}



#pragma mark - Accessors
- (NSManagedObjectContext *)managedObjectContext {
    return [[ModuleManager sharedManager] managedObjectContext];
}


#pragma mark -
#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
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
	fetchedResultsController.delegate = self;
	
	// Memory management.
	
	return fetchedResultsController;
}    


- (void)updatePredicate {
    NSPredicate *pre;
    NSFetchRequest *req = self.fetchedResultsController.fetchRequest;

    switch (segmentedControl.selectedSegmentIndex) {
        case kSegmentedControlCodeIndex: {
            pre = [NSPredicate predicateWithFormat:@"code CONTAINS[cd] %@",searchString];
            
            req.predicate = pre;
            req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
        }
            break;
        case kSegmentedControlTitleIndex: {
            pre = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@",searchString];
        }
            break;
        case kSegmentedControlDescriptionIndex: {
            pre = [NSPredicate predicateWithFormat:@"moduleDescription CONTAINS[cd] %@",searchString];
        }
            break;
        case kSegmentedControlAllIndex: {
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

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[_tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	UITableView *tableView = _tableView;
    
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
            //			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}



@end
