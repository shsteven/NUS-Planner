//
//  CategoryDetailViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/13/11.
//  Copyright 2011 NUS. All rights reserved.
//

@class Categories;

#import <UIKit/UIKit.h>
#import "AddModuleViewController.h"

@interface CategoryDetailViewController : UITableViewController<AddModuleDelegate> {
    NSArray *modules;
}

@property (strong) Categories *category;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil category:(Categories *)cat;

@end
