//
//  Timetable.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/12/11.
//  Copyright (c) 2011 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Module, ModuleClass;

@interface Timetable : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *modules;
@property (nonatomic, retain) NSSet *selections;
@end

@interface Timetable (CoreDataGeneratedAccessors)
- (void)addModulesObject:(Module *)value;
- (void)removeModulesObject:(Module *)value;
- (void)addModules:(NSSet *)value;
- (void)removeModules:(NSSet *)value;
- (void)addSelectionsObject:(ModuleClass *)value;
- (void)removeSelectionsObject:(ModuleClass *)value;
- (void)addSelections:(NSSet *)value;
- (void)removeSelections:(NSSet *)value;

@end
