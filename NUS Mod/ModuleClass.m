//
//  ModuleClass.m
//  NUS Mod
//
//  Created by Raymond Hendy on 7/15/11.
//  Copyright (c) 2011 NUS. All rights reserved.
//

#import "ModuleClass.h"
#import "Module.h"
#import "ModuleClassDetail.h"
#import "Timetable.h"


@implementation ModuleClass
@dynamic classNumber;
@dynamic type;
@dynamic details;
@dynamic module;
@dynamic timetable;

- (NSString *)abbreviatedType {
    if ([self.type isEqualToString:@"DESIGN LECTURE"] ||
        [self.type isEqualToString:@"LECTURE"] ||
        [self.type isEqualToString:@"PACKAGED LECTURE"] ||
        [self.type isEqualToString:@"SECTIONAL TEACHING"] ||
        [self.type isEqualToString:@"SEMINAR-STYLE MODULE CLASS"] ||
        [self.type isEqualToString:@"RECITATION"])
        return @"LEC";
    
    if ([self.type isEqualToString:@"TUTORIAL"] ||
        [self.type isEqualToString:@"PACKAGED TUTORIAL"])
        return @"TUT";
    
    if ([self.type isEqualToString:@"TUTORIAL TYPE 2"])
        return @"TUT2";
    if ([self.type isEqualToString:@"TUTORIAL TYPE 3"])
        return @"TUT3";
    
    if ([self.type isEqualToString:@"LABORATORY"])
        return @"LAB";
    
    return @"";
}

@end
