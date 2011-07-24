//
//  LoginViewController.m
//  NUS Mod
//
//  Created by Raymond Hendy on 7/15/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

@synthesize delegate = __delegate;

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

- (void)showInvalidLogin {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Incorrect" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert show];
}

- (void)login {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[AccountManager sharedManager] setDelegate:self];
    [[AccountManager sharedManager] loginWithUserID:usernameTextField.text password:passwordTextField.text];
}

- (void)cancel {
    [self.parentViewController dismissModalViewControllerAnimated:YES]; 
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"IVLE Login";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *loginButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(login)];
    self.navigationItem.rightBarButtonItem = loginButtonItem;
    
    usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;

    [usernameTextField becomeFirstResponder];
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

- (void)didLoginWithStatus:(BOOL)isSuccess {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(isSuccess) {
        [self.delegate didLogin];
    } else {
        [self showInvalidLogin];
    }
}

@end
