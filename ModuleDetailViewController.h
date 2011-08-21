//
//  ModuleDetailViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 8/9/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Module;

@interface ModuleDetailViewController : UITableViewController {
    Module *module;
    __unsafe_unretained id _delegate;
    IBOutlet UIButton *enableButton;
    IBOutlet UIButton *removeButton;
    BOOL showButtons;
    IBOutlet UIView *tableFooterView;
}

@property (strong) Module *module;
@property (assign) id delegate;
@property (assign) BOOL showButtons;
@property (strong) IBOutlet UIView *tableFooterView;
@property (nonatomic, strong) IBOutlet UIButton *enableButton;
@property (nonatomic, strong) IBOutlet UIButton *removeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil showButtons:(BOOL)yesOrNo;

- (IBAction)handleEnableButton:(id)sender;
- (IBAction)handleRemoveButton:(id)sender;

- (void)updateButtons;

@end
