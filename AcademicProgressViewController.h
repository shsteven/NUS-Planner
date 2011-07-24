//
//  AcademicProgressViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/15/11.
//  Copyright 2011 NUS. All rights reserved.
//

@class AcademicPeriod;

#import <UIKit/UIKit.h>

@interface AcademicProgressViewController : UITableViewController {
    NSArray *modules;
}

@property (strong) AcademicPeriod *semester;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil semester:(AcademicPeriod *)AY;

@end
