//
//  ModuleDetailViewController.m
//  NUS Mod
//
//  Created by Steven Zhang on 12/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "ModuleDetailViewController.h"

@implementation ModuleDetailViewController
@synthesize titleLabel;
@synthesize timeLabel;
@synthesize descriptionTextView;
@synthesize delegate = _delegate;
//@synthesize showButtons;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        showButtons = YES;
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
    [self setShowButtons:showButtons];

    if (module) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@: %@", module.code, module.title];
        self.timeLabel.text = [NSString stringWithFormat:@"%@: %@", @"Workload:", module.workload];
        self.descriptionTextView.text = module.moduleDescription;
        [self updateButtons];
    }; // trigger UI update
}


- (void)viewWillDisappear:(BOOL)animated {
    [self setModule:nil];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setTimeLabel:nil];
    [self setDescriptionTextView:nil];
    enableButton = nil;
    removeButton = nil;
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)setModule:(Module *)newModule {
    if (module)
        [module removeObserver:self forKeyPath:@"enabled"];
    
    NSLog(@"setModule:");
    
    module = newModule;

    self.titleLabel.text = [NSString stringWithFormat:@"%@: %@", module.code, module.title];
    self.timeLabel.text = module.workload;
    self.descriptionTextView.text = module.moduleDescription;
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

- (BOOL)showButtons {
    return showButtons;
}

- (void)setShowButtons:(BOOL)show {
    showButtons = show;
    enableButton.hidden = !show;
    removeButton.hidden = !show;
        

}

@end
