//
//  ModuleVenueViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 8/21/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModuleClass;

@interface ModuleVenueViewController : UITableViewController {
    NSInteger prev;
}

@property (strong) NSArray *classes;
@property (nonatomic, strong) ModuleClass *prevClass;

@end
