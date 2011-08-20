//
//  ModuleDetailViewController.m
//  NUS Mod
//
//  Created by Raymond Hendy on 8/9/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "ModuleDetailViewController.h"
#import "Module.h"

@implementation ModuleDetailViewController

@synthesize delegate = _delegate;
@synthesize tableFooterView = __tableFooterView;
@synthesize enableButton = __enableButton, removeButton = __removeButton;
@synthesize showButtons;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil showButtons:(BOOL)yesOrNo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.showButtons = yesOrNo;
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
    
    if (module) {
        [self updateButtons];
    }; // trigger UI update
    
    [[NSBundle mainBundle] loadNibNamed:@"ModuleDetailFooterView" owner:self options:nil];
    
    self.enableButton.hidden = !self.showButtons;
    self.removeButton.hidden = !self.showButtons;
    
    self.tableView.tableFooterView = __tableFooterView;
    self.tableView.allowsSelectionDuringEditing = YES;

    CGRect frame = self.tableView.frame;
    self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, 600, 550);
}

- (void)viewDidUnload
{
    enableButton = nil;
    removeButton = nil;
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

- (void)viewWillDisappear:(BOOL)animated {
    [self setModule:nil];
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

- (void)setModule:(Module *)newModule {
    if (module)
        [module removeObserver:self forKeyPath:@"enabled"];
    
    //NSLog(@"setModule:");
    
    module = newModule;

    [self updateButtons];
    [module addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
    
}

- (Module *)module {
    return module;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"enabled"]) {
        [self updateButtons];
    }
}

- (void)updateButtons {
    if ([module.enabled boolValue]) {
        [enableButton setTitle:@"Hide" forState:UIControlStateNormal];
        [enableButton setTitle:@"Hide" forState:UIControlStateHighlighted];
    } else  {
        [enableButton setTitle:@"Show" forState:UIControlStateNormal];
        [enableButton setTitle:@"Show" forState:UIControlStateHighlighted];
    }
}

- (IBAction)handleEnableButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(enableButtonTappedForModule:)]) {
        [_delegate performSelector:@selector(enableButtonTappedForModule:) withObject:module];
    }
}

- (IBAction)handleRemoveButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(removeButtonTappedForModule:)]) {
        [_delegate performSelector:@selector(removeButtonTappedForModule:) withObject:module];
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return module.code;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ModuleDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *textLabel = @"", *detailTextLabel = @"";
    switch (indexPath.row) {
        case 0:
            textLabel = @"title";
            detailTextLabel = module.title;
            break;
        case 1:
            textLabel = @"mc";
            detailTextLabel = module.modularCredit;
            break;
        case 2:
            textLabel = @"workload";
            detailTextLabel = module.workload;
            break;
        case 3:
            textLabel = @"description";
            detailTextLabel = module.moduleDescription;
            break;
        default:
            break;
    }
    
    cell.textLabel.text = textLabel;
    cell.detailTextLabel.text = detailTextLabel;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.numberOfLines = 0;
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *text = @"";
    switch (indexPath.row) {
        case 0:
            text = module.title;
            break;
        case 1:
            text = module.modularCredit;
            break;
        case 2:
            text = module.workload;
            break;
        case 3:
            text = module.moduleDescription;
            break;
        default:
            break;
    }
    
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont labelFontSize]];
    
    CGFloat width = self.tableView.frame.size.width * 0.7;
    
    CGSize size = CGSizeMake(width, 1e9);
    
    return [text sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap].height;
}

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
}

@end
