//
//  ModuleClass.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/12/11.
//  Copyright (c) 2011 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Module, ModuleClassDetail, Timetable;

@interface ModuleClass : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * classNumber;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *details;
@property (nonatomic, retain) Module *module;
@property (nonatomic, retain) Timetable *timetable;
@end

@interface ModuleClass (CoreDataGeneratedAccessors)
- (void)addDetailsObject:(ModuleClassDetail *)value;
- (void)removeDetailsObject:(ModuleClassDetail *)value;
- (void)addDetails:(NSSet *)value;
- (void)removeDetails:(NSSet *)value;

@end
