//
//  ClassView.h
//  NUS Mod
//
//  Created by Steven Zhang on 12/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "EventView.h"
@class WeekViewController;
@class ModuleClassDetail;

typedef NSInteger ClassType;

enum ClassType {
    kLectureClassType,
    kTutorialClassType,
    kLabClassType
    };

@interface ClassView : EventView {
    ClassType classType;
    UILabel *codeLabel;
    UILabel *typeLabel;
    UILabel *venueLabel;
    
    __unsafe_unretained WeekViewController *weekViewController;
    
    __unsafe_unretained ModuleClassDetail *classDetail;
    
}

@property (assign) ClassType classType;
@property (nonatomic, strong) IBOutlet UILabel *codeLabel;
@property (nonatomic, strong) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) IBOutlet UILabel *venueLabel;
@property (weak) UIColor *tintColor;
@property (assign) IBOutlet WeekViewController *weekViewController;
@property (assign) ModuleClassDetail *classDetail;

@end
