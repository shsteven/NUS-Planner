//
//  TimetableController.h
//  NUS Mod
//
//  Created by Steven Zhang on 13/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WeekViewController;
@class ModuleManager;

@class ClassView;
@class ModuleClassDetail;

@interface TimetableController : NSObject {
    __unsafe_unretained WeekViewController  *weekViewController;
    ModuleManager *moduleManager;
    NSSet *selections;
    
    NSMutableSet *alternativeClasses;

}

@property (assign) WeekViewController *weekViewController;
@property (strong) NSSet *selections;
@property (strong) NSMutableSet *alternativeClasses;

- (void)generatedCombinationsDidUpdate: (NSNotification *)notification;
- (void)reloadData;

- (ClassView *)newClassViewFromClassDetail: (ModuleClassDetail *)detail;

- (void)beginChoosingAlternativeClassesWithModuleClassDetail: (ModuleClassDetail *)detail;
- (void)endChoosingAlternativeClassesWithModuleClassDetail:(ModuleClassDetail *)detail;

int dayToInt(NSString *day); // From ModuleManager

@end
