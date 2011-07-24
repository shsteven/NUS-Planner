//
//  AddModuleViewController.m
//  NUS Mod
//
//  Created by Raymond Hendy on 7/16/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "AddModuleViewController.h"
#import "SearchViewController.h"
#import "ModuleManager.h"
#import "AccountManager.h"
#import "Module.h"

@implementation AddModuleViewController

@synthesize category = __category;
@synthesize delegate = __delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil category:(Categories *)cat
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.category = cat;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)cancel {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{    
    [super viewDidLoad];
    self.title = @"Add Module";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    searchResult = [[NSArray alloc] init];
    manager = [ModuleManager sharedManager];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
    return [searchResult count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
	}
	
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	Module *m = [searchResult objectAtIndex:indexPath.row];
	cell.textLabel.text = m.code;
    cell.detailTextLabel.text = m.title;
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	/*
	 If the requesting table view is the search display controller's table view, configure the next view controller using the filtered content, otherwise use the main list.
	 */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[AccountManager sharedManager] addModule:[searchResult objectAtIndex:indexPath.row] toCategory:self.category];
    [self.delegate didAddModuleToCategory];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)updateResultWithSearchString:(NSString *)searchString {
    switch (selectedIdx) {
        case 0:
            searchResult = [manager allModulesByCode:searchString];
            break;
        case 1:
            searchResult = [manager allModulesByTitle:searchString];
            break;
        case 2:
            searchResult = [manager allModulesByDescription:searchString];
            break;
        case 3:
            searchResult = [manager modulesBySearchTerm:searchString];
        default:
            break;
    }
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateResultWithSearchString:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    selectedIdx = searchOption;
    [self updateResultWithSearchString:controller.searchBar.text];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
