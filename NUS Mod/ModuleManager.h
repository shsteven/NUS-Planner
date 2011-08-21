//
//  ModuleManager.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/4/11.
//  Copyright 2011 NUS. All rights reserved.
//

@class Module;
@class ModuleClass;
@class Timetable;
@class User;

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ModuleManager : NSObject {
    NSMutableData *responseData;
    NSString *htmlContent;
    NSManagedObjectContext *context;
    
    NSArray *sessions;
    NSMutableArray *selections;
    NSMutableArray *generatedCombinations;
    NSMutableSet *constraints;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/*
 * RETURNS: The timetable singleton created by user
 */
@property (strong, nonatomic) Timetable *timetable;

/*
 * RETURNS: Array of possible valid timetable of modules listed by user
 */
@property (strong, nonatomic) NSMutableArray *combinations;

@property (strong) NSMutableSet *constraints;

/*
 * RETURNS: Array of of subarrays of ModuleClass objects (auto-generated slots for timetable). Subarrays are categorized by day, sorted by time.
 */
@property (readonly, strong, nonatomic) NSMutableArray *categorizedSelections;

/*
 * RETURNS: ModuleManager singleton instance
 */
+ (id)sharedManager;

/*
 * EFFECTS: Download module weblinks from CORS and save to links.txt
 */
- (void)grabLink;

/*
 * EFFECTS: Download module info from CORS and convert to Core Data model objects then save to database
 */
- (void)readModule;

/*
 * EFFECTS: Populating generatedCombinations array.
 */
- (void)generateCombinations;

/*
 * Interface for database query.
 * RETURNS: Modules that contain the specified keyword(s). Returns an empty array if not found.
 */
- (NSArray *)modulesBySearchTerm:(NSString *)keywordsString;

- (NSArray *)allModulesByCode:(NSString *)code;

- (NSArray *)allModulesByTitle:(NSString *)title;

- (NSArray *)allModulesByDescription:(NSString *)description;

/*
 * Interface for database query.
 * RETURNS: Module with the specified code. Returns nil if not found.
 */
- (Module *)moduleByCode:(NSString *)code;

/*
 * Interface for database query.
 * RETURNS: ModuleClass with the specified parameters. Returns nil if not found.
 */
- (ModuleClass *)classByModuleCode:(NSString *)code
                           classNo:(NSString *)no
                              type:(NSString *)type;


/*
 * RETURNS: Alternative ModuleClass objects
 */
- (NSArray *)alternativesForClass:(ModuleClass *)class;

/*
 * EFFECTS: Add the specified module into timetable. Context is saved.
 */
- (void)addModule:(Module *)m;

- (void)removeModule:(Module *)m;

- (void)enableModule:(Module *)m;

- (void)disableModule:(Module *)m;

/*
 * REQUIRES: Time slot is available/not occupied
 * EFFECTS: Remove a class slot with the same module code and same class type (Lecture,Tutorial, etc.) and add the new one. (in other words, move the session). Context is saved.
 */
- (void)addClass:(ModuleClass *)c;

- (void)addConstraint:(NSNumber *)constraint;

- (void)removeConstraint:(NSNumber *)constraint;

- (BOOL)overlapModuleClass:(ModuleClass *)a withOtherModuleClass: (ModuleClass *)b;

- (BOOL)overlapsWithSet:(NSSet *)setOfSelections withModuleClass:(ModuleClass *)c;

- (BOOL)colorIsUsed: (UIColor *)color;

- (NSMutableSet *)splitAndNormalized:(NSString *)str;

- (NSInteger)updateGeneratedCombinations:(NSSet *)selected;
@end
