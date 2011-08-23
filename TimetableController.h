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

    __unsafe_unretained id delegate;
    
}

@property (assign) WeekViewController *weekViewController;
@property (strong) NSSet *selections;
@property (strong) NSMutableSet *alternativeClasses;

@property (assign) id delegate;

- (void)generatedCombinationsDidUpdate: (NSNotification *)notification;
- (void)reloadData;

- (ClassView *)newClassViewFromClassDetail: (ModuleClassDetail *)detail;

- (void)beginChoosingAlternativeClassesWithModuleClassDetail: (ModuleClassDetail *)detail;
- (void)endChoosingAlternativeClassesWithModuleClassDetail:(ModuleClassDetail *)detail;
//- (NSArray *)arrayByRemovingDuplicateClasses: (NSArray *)array; // Removes duplicates with the same time slot
- (BOOL)classView: (ClassView *)classView1 hasIdenticalTimeSlotToClassView: (ClassView *)classView2;
int dayToInt(NSString *day); // From ModuleManager

@end
