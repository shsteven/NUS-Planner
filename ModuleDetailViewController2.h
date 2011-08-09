//
//  ModuleDetailViewController.h
//  NUS Mod
//
//  Created by Steven Zhang on 12/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Module.h"

@interface ModuleDetailViewController : UIViewController {
    Module *module;
    UILabel *titleLabel;
    UILabel *timeLabel;
    UITextView *descriptionTextView;
    __unsafe_unretained id _delegate;
    IBOutlet UIButton *enableButton;
    
    IBOutlet UIButton *removeButton;
    BOOL showButtons;
}

@property (strong) Module *module;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UITextView *descriptionTextView;
@property (assign) id delegate;
@property (assign) BOOL showButtons;
- (IBAction)handleEnableButton:(id)sender;
- (IBAction)handleRemoveButton:(id)sender;

- (void)updateButtons;


@end
