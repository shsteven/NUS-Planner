//
//  NSString+Time.m
//  NUS Mod
//
//  Created by Steven Zhang on 13/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "NSString+Time.h"

@implementation NSString (NSString_Time)

- (NSUInteger)gridIndexValue {
    NSInteger timeValue = [self integerValue];
    NSUInteger index = timeValue / 50 - 14; // Day starts at 7AM
    return  index;
}

@end
