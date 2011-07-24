//
//  AddModuleViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/16/11.
//  Copyright 2011 NUS. All rights reserved.
//

@class Categories;
@class ModuleManager;
@protocol AddModuleDelegate;

#import <UIKit/UIKit.h>

@interface AddModuleViewController : UIViewController<UISearchDisplayDelegate, UISearchBarDelegate> {
    NSArray *searchResult;
    ModuleManager *manager;
    NSInteger selectedIdx;
    __unsafe_unretained id <AddModuleDelegate> delegate;
}

@property (strong) Categories *category;
@property (assign) id <AddModuleDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil category:(Categories *)cat;

@end

@protocol AddModuleDelegate <NSObject>

- (void)didAddModuleToCategory;

@end