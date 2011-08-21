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

@synthesize delegate = _delegate;

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
    NSLog(@"reloadData");
#endif
    [weekViewController clearAllEventViews];
    
    if (![selections count]) return;
    
    
    for (ModuleClass *class in selections) {
//        NSLog(@"a class: %@", class.type);
        for (ModuleClassDetail *detail in class.details) {
//            NSLog(@"a detail: %@", detail.venue);
            ClassView *classView = [self newClassViewFromClassDetail:detail];
            
            [weekViewController addEventView:classView];
            
//            [classView setBlinking:YES]; // Testing
            
        }

        
            
    }
    
    
    
}

- (ClassView *)newClassViewFromClassDetail: (ModuleClassDetail *)detail {
    ClassView *classView = [weekViewController newClassView];
    [weekViewController newClassView];
    
    classView.codeLabel.text = detail.moduleClass.module.code;
    
    classView.classDetail = detail;
    
    int day = dayToInt(detail.day);
    NSRange r = NSMakeRange((NSUInteger)day, 1);  
    classView.columnRange = r;
    
    NSUInteger start = [detail.startTime gridIndexValue];
    NSUInteger end = [detail.endTime gridIndexValue];
    classView.rowRange = NSMakeRange(start, end-start);
    
    NSString *type = detail.moduleClass.type;
    if (detail.moduleClass.classNumber)
        type = [type stringByAppendingFormat:@"(%@)", detail.moduleClass.classNumber];
    classView.typeLabel.text = type;
    classView.venueLabel.text = detail.venue;
    
    classView.tintColor = detail.moduleClass.module.color;

    return classView;
}

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
    NSLog(@"detail: %@", detail);
    
    if (detail) {
        // Update logic
        [moduleManager addClass:detail.moduleClass];
    }
    [self.weekViewController updateScrollViewWithIndex:[moduleManager updateGeneratedCombinations:selections]];
    [self reloadData];

}

/*
int dayToInt(NSString *day) {
    if([day isEqual:@"MONDAY"]) {
        return 0;
    } else if([day isEqual:@"TUESDAY"]) {
        return 1;
    } else if([day isEqual:@"WEDNESDAY"]) {
        return 2;
    } else if([day isEqual:@"THURSDAY"]) {
        return 3;
    } else if([day isEqual:@"FRIDAY"]) {
        return 4;
    } else {
        return 5;
    }
}*/
@end
