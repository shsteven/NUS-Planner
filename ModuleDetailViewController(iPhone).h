//
//  ModuleDetailViewController(iPhone).h
//  NUS Mod
//
//  Created by Raymond Hendy on 8/16/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Module;

@interface ModuleDetailViewController_iPhone_ : UITableViewController {
    __unsafe_unretained id _delegate;
//    IBOutlet UIBarButtonItem *enableButton;
//    IBOutlet UIBarButtonItem *removeButton;
    IBOutlet UIBarButtonItem *addButton;
    IBOutlet UIButton *enableButton;
    IBOutlet UIButton *removeButton;
    IBOutlet UIView *footerView;
}

@property (assign) id delegate;
@property (nonatomic, strong) Module *module;
@property BOOL searchMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil module:(Module *)m searchMode:(BOOL)yesOrNo delegate:(id)del;

- (IBAction)handleAddButton:(id)sender;
- (IBAction)handleEnableButton:(id)sender;
- (IBAction)handleRemoveButton:(id)sender;

- (void)updateButtons;

@end
