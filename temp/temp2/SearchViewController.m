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
    
    // Do any additional setup after loading the view from its nib.
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
    
    if (!searchString) {
        // Nothing to search, show empty result
        [_tableView reloadData];
    }
    
    // Update search result
    ModuleManager *manager = [ModuleManager sharedManager];
    
    switch (segmentedControl.selectedSegmentIndex) {
        case kSegmentedControlCodeIndex: {
            resultArray = [manager allModulesByCode:string]; // TODO
        }
            break;
        case kSegmentedControlTitleIndex: {
            resultArray = [manager allModulesByTitle:string]; // TODO
        }
            break;
        case kSegmentedControlDescriptionIndex: {
            resultArray = [manager allModulesByDescription:string]; // TODO
        }
            break;
        case kSegmentedControlAllIndex: {
            resultArray = [manager modulesBySearchTerm:string];
        }
            break;
        default:
            break;
    }
    

    [_tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (resultArray)
    return 1;
    
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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
    Module *aModule = [resultArray objectAtIndex:indexPath.row];
    cell.textLabel.text = aModule.code;
    cell.detailTextLabel.text = aModule.title;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Module *aModule = [resultArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (mainViewController.popover) {        
        ModuleDetailViewController *detailVC = [[ModuleDetailViewController alloc] initWithNibName:@"ModuleDetailViewController" bundle:nil];
        detailVC.module = aModule;
        detailVC.showButtons = NO;
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
    Module *aModule = [resultArray objectAtIndex:indexPath.row];
    
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
    [self setSearchString:self.searchString]; // Trigger a search
}

#pragma mark - Search Bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self setSearchString:searchBar.text];

}

@end
