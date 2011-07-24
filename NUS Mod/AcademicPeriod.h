//
//  AcademicPeriod.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/15/11.
//  Copyright (c) 2011 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Module, User;

@interface AcademicPeriod : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * period;
@property (nonatomic, retain) NSSet *modules;
@property (nonatomic, retain) User *user;
@end

@interface AcademicPeriod (CoreDataGeneratedAccessors)
- (void)addModulesObject:(Module *)value;
- (void)removeModulesObject:(Module *)value;
- (void)addModules:(NSSet *)value;
- (void)removeModules:(NSSet *)value;

@end
