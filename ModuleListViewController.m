//
//  ModuleListViewController.m
//  NUS Mod
//
//  Created by Steven Zhang on 13/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "ModuleListViewController.h"
#import "ModuleManager.h"
#import "Timetable.h"
#import "Module.h"
#import "ModuleCell.h"
#import "SearchViewController.h"
#import "MainViewController.h"
#import "ModuleDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AddCell.h"

@implementation ModuleListViewController
@synthesize moduleList;
@synthesize moduleCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    moduleManager = [ModuleManager sharedManager];
    [moduleManager.timetable addObserver:self forKeyPath:@"modules" options:NSKeyValueObservingOptionNew context:NULL];
    moduleList = [moduleManager.timetable.modules allObjects];
//    self.tableView.canCancelContentTouches = NO;
//    self.tableView.delaysContentTouches = NO;
    if (![moduleManager.timetable.modules count])
    [self performSelector:@selector(showBouncingTooltip) withObject:nil afterDelay:1.0];    // After view is shown
}

- (void)viewDidUnload
{
    [moduleManager.timetable removeObserver:self forKeyPath:@"modules"];
    [self setModuleCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)showBouncingTooltip {
    tipView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StartHere.png"]];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGPoint center = cell.center;
    center.y += 75.0;
    tipView.center = center;
    [self.view addSubview:tipView];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGPoint point = tipView.center;
                         point.y += 15.0;
                         tipView.center = point;
                         
                     } completion:^(BOOL finished){
                         
                     }];
                            
    
                      
}

- (void)removeBouncingTooltip {
    if (tipView) {
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            tipView.alpha = 0;
        }completion:^ (BOOL finished) {
            [tipView removeFromSuperview];
            tipView = nil;
        }];

    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
//    if ([moduleManager.timetable.modules count]) return 1;
    if (moduleList) return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    if ([moduleManager.timetable.modules count]) return [moduleManager.timetable.modules count];
    if (section == 0) return 1;
    if (section == 1 && moduleList)
        return [moduleList count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    if (indexPath.section == 0) {
        static NSString *AddCellIdentifier = @"AddCell";
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:AddCellIdentifier];
        if (cell == nil) {
            cell = (UITableViewCell *)[[AddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddCellIdentifier];
        }

        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.backgroundView.backgroundColor = [UIColor lightGrayColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.backgroundView.layer.cornerRadius = 10.0;
        cell.backgroundView.layer.borderWidth = 1.0;
        cell.backgroundView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        
        cell.imageView.image = [UIImage imageNamed:@"CirclePlus.png"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Add Module";
        
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    ModuleCell *cell = (ModuleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"ModuleCell" bundle:nil];
        [nib instantiateWithOwner:self options:nil];
        
        cell = self.moduleCell;
        self.moduleCell = nil;
    }
    
    Module *module = [moduleList objectAtIndex:indexPath.row];
    cell.codeLabel.text = module.code;
    cell.titleLabel.text = module.title;
    cell.examLabel.text = [NSString stringWithFormat:@"Exam date: %@", module.examDate];
    if ([module.enabled boolValue]) 
        cell.tintColor = module.color;
    else
        cell.tintColor = [UIColor lightGrayColor];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 1)
    return YES;
    return NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Module *module = [moduleList objectAtIndex:indexPath.row];
        [moduleManager removeModule:module];
        //        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    // Dismiss popover if any
    if (mainViewController.popover && [mainViewController.popover isPopoverVisible])
        [mainViewController.popover dismissPopoverAnimated:YES];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Add button
    if (indexPath.section == 0) {
        [self removeBouncingTooltip];
        
        mainViewController.popover = [[UIPopoverController alloc] initWithContentViewController:mainViewController.searchViewController];
        [mainViewController.popover presentPopoverFromRect:[mainViewController.view convertRect:[self.tableView rectForSection:0] fromView:self.tableView]
                                                    inView:mainViewController.view
                                  permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        return;
    }
    
    
    
    // Show module detail

    Module *module = [moduleList objectAtIndex:indexPath.row];
//    [moduleManager removeModule:module];
    ModuleDetailViewController *detailVC = [[ModuleDetailViewController alloc] initWithNibName:@"ModuleDetailViewController" bundle:nil];
    
    detailVC.delegate = self;
    [detailVC setModule:module];
    
    detailVC.contentSizeForViewInPopover = detailVC.view.frame.size;
    mainViewController.popover = [[UIPopoverController alloc] initWithContentViewController:detailVC];
    CGRect rowRect = [self.tableView rectForRowAtIndexPath:indexPath];
    [mainViewController.popover presentPopoverFromRect:[mainViewController.view convertRect:rowRect fromView:self.tableView]
                                                inView:mainViewController.view
                              permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];    
}




- (void)enableButtonTappedOnCell: (ModuleCell *)cell {
    
}

- (void)removeButtonTappedOnCell: (ModuleCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Module *module = [moduleList objectAtIndex:indexPath.row];
    [moduleManager removeModule:module];
}

- (void)enableButtonTappedForModule:(Module *)module  {
    if (mainViewController.popover)
        [mainViewController.popover dismissPopoverAnimated:YES];
    if ([module.enabled boolValue])
        [moduleManager disableModule:module];
    else
        [moduleManager enableModule:module];
    [self.tableView reloadData];
}

- (void)removeButtonTappedForModule: (Module *)module {
    if (mainViewController.popover)
        [mainViewController.popover dismissPopoverAnimated:YES];
    [moduleManager removeModule:module];
}



#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"modules"]) {
        moduleList = [moduleManager.timetable.modules allObjects];
        [self.tableView reloadData];
    }
}


@end
