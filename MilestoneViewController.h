//
//  MilestoneViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/13/11.
//  Copyright 2011 NUS. All rights reserved.
//

@class AccountManager;

#import <UIKit/UIKit.h>

#import "LoginViewController.h"

#import "AddCategoryViewController.h"

#import "MainViewController.h"

@interface MilestoneViewController : UITableViewController<LoginViewControllerDelegate,AddCategoryDelegate> {
    IBOutlet UITableViewCell *progressCell;
    IBOutlet UILabel *percentageLabel;
    IBOutlet UILabel *mcLabel;
    IBOutlet UIProgressView *progressView;
    
    IBOutlet UIBarButtonItem *actionButton;
    IBOutlet UIBarButtonItem *loginBtn;
    IBOutlet UIBarButtonItem *logoutBtn;
    
    AccountManager *manager;
    MainViewController *mainVC;
    UINavigationController *mainNavigationVC;
    
    BOOL loggedIn;
    
    UIActionSheet *actionSheet;
}

@property (nonatomic) BOOL loggedIn;

- (IBAction)handleActionButton:(id)sender;

@end
