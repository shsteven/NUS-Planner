//
//  MilestoneViewController.m
//  NUS Mod
//
//  Created by Raymond Hendy on 7/13/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "MilestoneViewController.h"
#import "AccountManager.h"
#import "User.h"
#import "AcademicPeriod.h"
#import "Categories.h"
#import "AcademicProgressViewController.h"
#import "CategoryDetailViewController.h"

#define PROGRESS_SECTION 0
#define HISTORY_SECTION 1
#define CATEGORIES_SECTION 2

@implementation MilestoneViewController

@synthesize loggedIn = __loggedIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)showLoginPage {
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginVC.delegate = self;
    
    UINavigationController *loginController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    [self presentModalViewController:loginController animated:YES];
}

- (void)logout {
    [manager resetAccount];
//    self.navigationItem.rightBarButtonItem = loginBtn;
    [self.tableView reloadData];
    loggedIn = NO;
}

- (void)login {
    [self showLoginPage];
}

- (void)didLogin {
    NSLog(@"didLogin");
    [self dismissModalViewControllerAnimated:YES];
    if([manager hasUser]) {
        loggedIn = YES;
//        self.navigationItem.rightBarButtonItem = logoutBtn;
    } else {
        loggedIn = NO;
//        self.navigationItem.rightBarButtonItem = loginBtn;
    }
    [self.tableView reloadData];
}

- (void)didAddNewCategory {
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Milestone";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    manager = [AccountManager sharedManager];
    
    loginBtn.target = self;
    loginBtn.action = @selector(login);
    logoutBtn.target = self;
    logoutBtn.action = @selector(logout);
    
    /*if([manager hasUser]) {
        self.navigationItem.rightBarButtonItem = logoutBtn;
    } else {
        self.navigationItem.rightBarButtonItem = loginBtn;
    }*/
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.navigationItem.rightBarButtonItem = actionButton;

    if ([[AccountManager sharedManager] hasUser]) 
        loggedIn = YES;
    else
        loggedIn = NO;  
    
    NSString *loginTitle = @"Login";
    if (loggedIn) loginTitle = @"Logout";
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:loginTitle, @"Back",nil];
}

- (void)viewDidUnload
{
    progressCell = nil;
    progressCell = nil;
    percentageLabel = nil;
    mcLabel = nil;
    progressView = nil;   
    loginBtn = nil;
    logoutBtn = nil;
    actionButton = nil;
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
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
	[self.tableView beginUpdates];
    
    NSArray *categoriesInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[manager.categories count] inSection:2]]; // TODO
    
    if (editing) {
        [self.tableView insertRowsAtIndexPaths:categoriesInsertIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
	} else {
        [self.tableView deleteRowsAtIndexPaths:categoriesInsertIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section, row = indexPath.row;
    if(section == PROGRESS_SECTION && row == 0)
        return progressCell.frame.size.height;
    return tableView.rowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger categoriesCount = [manager.categories count];
    NSInteger AYcount = [manager.academicYears count];
    
    // Return the number of rows in the section.
    switch (section) {
        case PROGRESS_SECTION:
            return 1;
        case HISTORY_SECTION:
            return AYcount; // TODO
        case CATEGORIES_SECTION:
            if(self.editing) return categoriesCount+1; // TODO
            return categoriesCount;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case PROGRESS_SECTION:
            return @"Progress";
        case HISTORY_SECTION:
            return @"Module History";
        case CATEGORIES_SECTION:
            return @"Module Categories";
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section, row = indexPath.row;
    
    if(section == PROGRESS_SECTION && row == 0) { // TODO
        NSInteger mc = [manager countMC];
        progressView.progress = mc/160.0;
        percentageLabel.text = [NSString stringWithFormat:@"%2d%% to graduation",(int)(progressView.progress*100)];
        mcLabel.text = [NSString stringWithFormat:@"You have obtained %3d/%3d MCs",mc ,160];
        return progressCell;   
    }
    
    UITableViewCell *cell = nil;
    
    if(section == HISTORY_SECTION) {
        static NSString *ModuleCellIdentifier = @"ModuleCell";
        cell = [tableView dequeueReusableCellWithIdentifier:ModuleCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ModuleCellIdentifier];
        }
        AcademicPeriod *AY = [manager.academicYears objectAtIndex:indexPath.row];
        cell.textLabel.text = AY.period;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if(section == CATEGORIES_SECTION) {
        static NSString *CategoryCellIdentifier = @"CategoryCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CategoryCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CategoryCellIdentifier];
        }
        
        if(row != [manager.categories count]) {
            Categories *c = [manager.categories objectAtIndex:indexPath.row];
            cell.textLabel.text = c.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = @"Add category";
        }
    }
    return cell;
}

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
    
    NSInteger section = indexPath.section, row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(section == HISTORY_SECTION) {
        AcademicProgressViewController *ayVC = [[AcademicProgressViewController alloc] initWithNibName:@"AcademicProgressViewController" bundle:nil semester:[manager.academicYears objectAtIndex:row]];
        [self.navigationController pushViewController:ayVC animated:YES];
    } else if(section == CATEGORIES_SECTION) {
        if(row == [manager.categories count]) {
            AddCategoryViewController *addController = [[AddCategoryViewController alloc] initWithNibName:@"AddCategoryViewController" bundle:nil];
            addController.delegate = self;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addController];
            [self presentModalViewController:navigationController animated:YES];
        } else {
            CategoryDetailViewController *detailController = [[CategoryDetailViewController alloc] initWithNibName:@"CategoryDetailViewController" bundle:nil category:[[manager categories] objectAtIndex:row]];
            [self.navigationController pushViewController:detailController animated:YES];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if (indexPath.section == CATEGORIES_SECTION) {
        // If this is the last item, it's the insertion row.
        if (indexPath.row == [manager.categories count]) { // TODO: change to LAST ROW
            style = UITableViewCellEditingStyleInsert;
        }
        else {
            style = UITableViewCellEditingStyleDelete;
        }
    }
    
    return style;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // TODO: REMOVE
        [manager removeCategory:[manager.categories objectAtIndex:indexPath.row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        AddCategoryViewController *addController = [[AddCategoryViewController alloc] initWithNibName:@"AddCategoryViewController" bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addController];
        addController.delegate = self;
        [self presentModalViewController:navigationController animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == CATEGORIES_SECTION;
}

- (void)presentTimetableVC {
    mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    
    mainNavigationVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    mainNavigationVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:mainNavigationVC animated:YES];
    
}

#pragma mark ActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (loggedIn)
                [self logout];
            else
            [self showLoginPage];
            break;
        case 1:
            [self presentTimetableVC];
            break;
        default:
            break;
    }
}

- (IBAction)handleActionButton:(id)sender {
    if([actionSheet isVisible]) {
        [actionSheet dismissWithClickedButtonIndex:2 animated:YES];
        return;
    }
    NSString *loginTitle = @"Login";
    if (loggedIn) loginTitle = @"Logout";
    [actionSheet showFromBarButtonItem:actionButton animated:YES];
}

@end
