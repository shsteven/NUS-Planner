//
//  TimetableController.m
//  NUS Mod
//
//  Created by Steven Zhang on 13/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "TimetableController.h"
#import "WeekViewController.h"
#import "ModuleManager.h"
#import "Timetable.h"
#import "Constants.h"
#import "ModuleClass.h"
#import "ClassView.h"
#import "ModuleClassDetail.h"
#import "NSString+Time.h"
#import "Module.h"

@implementation TimetableController
@synthesize weekViewController;
@synthesize selections;
@synthesize alternativeClasses;

- (id)init
{
    self = [super init];
    if (self) {
        moduleManager = [ModuleManager sharedManager];
        alternativeClasses = [[NSMutableSet alloc] init];

    }
    
    return self;
}


- (void)awakeFromNib {
    [self reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(generatedCombinationsDidUpdate:) name:kGeneratedCombinationsDidUpdateNotification object:nil];
}

- (void)generatedCombinationsDidUpdate: (NSNotification *)notification {
    [self reloadData];
}

- (void)reloadData {
#ifdef DEBUG
    NSLog(@"timetable controller: reloadData");
#endif
    [weekViewController clearAllEventViews];
    
    if (![selections count]) return;
    
    
    for (ModuleClass *class in selections) {
        for (ModuleClassDetail *detail in class.details) {
            ClassView *classView = [self newClassViewFromClassDetail:detail];
            
            [weekViewController addEventView:classView];
            
        }

        
            
    }
    
#ifdef DEBUG
    
    // Debugging only
    for (int i = 0; i < 2; i++) {
        // Testing overlapping event views;
        ClassView *classView = [weekViewController newClassView];
        //    [weekViewController newClassView];
        
        classView.codeLabel.text = @"Test class";
        
        //    classView.classDetail = detail;
        
        int day = 1;
        NSRange r = NSMakeRange((NSUInteger)day, 1);  
        classView.columnRange = r;
        
        NSUInteger start = 4;
        NSUInteger end = 6;
        classView.rowRange = NSMakeRange(start, end-start);
        
        //    NSString *type = detail.moduleClass.type;
        //    if (detail.moduleClass.classNumber)
        //        type = [type stringByAppendingFormat:@"(%@)", detail.moduleClass.classNumber];
        classView.typeLabel.text = @"Type";
        classView.venueLabel.text = @"venue";
        
        classView.tintColor = [UIColor lightGrayColor];
        
        [weekViewController addEventView:classView];
    }

     
     
     
#endif
    
}

- (ClassView *)newClassViewFromClassDetail: (ModuleClassDetail *)detail {
    ClassView *classView = [weekViewController newClassView];
//    [weekViewController newClassView];
    
    classView.codeLabel.text = detail.moduleClass.module.code;
    
    classView.classDetail = detail;
    
    int day = dayToInt(detail.day);
    NSRange r = NSMakeRange((NSUInteger)day, 1);  
    classView.columnRange = r;
    
    NSUInteger start = [detail.startTime gridIndexValue];
    NSUInteger end = [detail.endTime gridIndexValue];
    classView.rowRange = NSMakeRange(start, end-start);
    
    NSString *type;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        type = detail.moduleClass.type;
    else
        type = detail.moduleClass.abbreviatedType;
    if (detail.moduleClass.classNumber)
        type = [type stringByAppendingFormat:@"(%@)", detail.moduleClass.classNumber];
    classView.typeLabel.text = type;
    classView.venueLabel.text = detail.venue;
    
    classView.tintColor = detail.moduleClass.module.color;

    return classView;
}


#pragma mark Drag and Drop
- (void)beginChoosingAlternativeClassesWithModuleClassDetail: (ModuleClassDetail *)detail {
    NSArray *array = [moduleManager alternativesForClass: detail.moduleClass];
    // NSLog(@"%@", [[array objectAtIndex:0] class]);
    if (![array count]) return;
    for (ModuleClass *moduleCalss in array) {
        for (ModuleClassDetail *anotherDetail in moduleCalss.details) {
            ClassView *classView = [self newClassViewFromClassDetail:anotherDetail];   
            [alternativeClasses addObject:classView];
            [classView setBlinking:YES];
            [weekViewController addEventView:classView];
            
        }
    }
}

- (void)endChoosingAlternativeClassesWithModuleClassDetail:(ModuleClassDetail *)detail {   // Detail can be nil
    for (UIView *view in alternativeClasses) [view removeFromSuperview];
    if (![alternativeClasses count]) {
        [self reloadData];
        return;
    }
    
    [alternativeClasses removeAllObjects];
//    NSLog(@"detail: %@", detail);
    
    if (detail) {
        // Update logic
        [moduleManager addClass:detail.moduleClass];
    }
    [self reloadData];

}

@end
