//
//  Categories.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/16/11.
//  Copyright (c) 2011 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Module, User;

@interface Categories : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *modules;
@property (nonatomic, retain) User *user;
@end

@interface Categories (CoreDataGeneratedAccessors)
- (void)addModulesObject:(Module *)value;
- (void)removeModulesObject:(Module *)value;
- (void)addModules:(NSSet *)value;
- (void)removeModules:(NSSet *)value;

@end
