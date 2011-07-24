//
//  ModuleCell.h
//  NUS Mod
//
//  Created by Steven Zhang on 14/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ModuleListViewController;

@interface ModuleCell : UITableViewCell {
    UILabel *codeLabel;
    UILabel *titleLabel;
    UILabel *examLabel;
    IBOutlet ModuleListViewController *moduleListViewController;
}

@property (nonatomic, strong) IBOutlet UILabel *codeLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *examLabel;
@property (weak) UIColor *tintColor;


- (IBAction)handleEnableButton:(id)sender;
- (IBAction)handleRemoveButton:(id)sender;


@end
