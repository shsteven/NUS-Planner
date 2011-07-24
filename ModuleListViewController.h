//
//  ModuleListViewController.h
//  NUS Mod
//
//  Created by Steven Zhang on 13/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ModuleManager;
@class ModuleCell;
@class MainViewController;
@class Module;
@interface ModuleListViewController : UITableViewController {
    ModuleManager *moduleManager;
    NSArray *moduleList;
    ModuleCell *moduleCell;
    IBOutlet MainViewController *mainViewController;
    UIImageView *tipView; 
}

@property (strong) NSArray *moduleList;
@property (nonatomic, strong) IBOutlet ModuleCell *moduleCell;
- (void)enableButtonTappedOnCell: (ModuleCell *)cell;   // deprecated

- (void)removeButtonTappedOnCell: (ModuleCell *)cell;   // deprecated

- (void)enableButtonTappedForModule:(Module *)module;

- (void)removeButtonTappedForModule: (Module *)module;

- (void)showBouncingTooltip;
- (void)removeBouncingTooltip;
@end
