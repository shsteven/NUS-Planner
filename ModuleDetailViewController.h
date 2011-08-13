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
    __unsafe_unretained id _delegate;
    Module *module;
}

@property (assign) id delegate;
@property (strong) Module *module;

@end
