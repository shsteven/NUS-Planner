//
//  Module.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/16/11.
//  Copyright (c) 2011 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AcademicPeriod, Categories, CodeWords, DescriptionWords, Keyword, ModuleClass, Timetable, TitleWords;

@interface Module : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) UIColor * color;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * examDate;
@property (nonatomic, retain) NSString * modularCredit;
@property (nonatomic, retain) NSString * moduleDescription;
@property (nonatomic, retain) NSString * preclusion;
@property (nonatomic, retain) NSString * prerequisite;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * workload;
@property (nonatomic, retain) Categories *category;
@property (nonatomic, retain) NSSet *moduleClasses;
@property (nonatomic, retain) NSSet *normalizedCodeWords;
@property (nonatomic, retain) NSSet *normalizedDescriptionWords;
@property (nonatomic, retain) NSSet *normalizedTitleWords;
@property (nonatomic, retain) NSSet *normalizedWords;
@property (nonatomic, retain) AcademicPeriod *semester;
@property (nonatomic, retain) Timetable *timetable;
@end

@interface Module (CoreDataGeneratedAccessors)
- (void)addModuleClassesObject:(ModuleClass *)value;
- (void)removeModuleClassesObject:(ModuleClass *)value;
- (void)addModuleClasses:(NSSet *)value;
- (void)removeModuleClasses:(NSSet *)value;
- (void)addNormalizedCodeWordsObject:(CodeWords *)value;
- (void)removeNormalizedCodeWordsObject:(CodeWords *)value;
- (void)addNormalizedCodeWords:(NSSet *)value;
- (void)removeNormalizedCodeWords:(NSSet *)value;
- (void)addNormalizedDescriptionWordsObject:(DescriptionWords *)value;
- (void)removeNormalizedDescriptionWordsObject:(DescriptionWords *)value;
- (void)addNormalizedDescriptionWords:(NSSet *)value;
- (void)removeNormalizedDescriptionWords:(NSSet *)value;
- (void)addNormalizedTitleWordsObject:(TitleWords *)value;
- (void)removeNormalizedTitleWordsObject:(TitleWords *)value;
- (void)addNormalizedTitleWords:(NSSet *)value;
- (void)removeNormalizedTitleWords:(NSSet *)value;
- (void)addNormalizedWordsObject:(Keyword *)value;
- (void)removeNormalizedWordsObject:(Keyword *)value;
- (void)addNormalizedWords:(NSSet *)value;
- (void)removeNormalizedWords:(NSSet *)value;

@end
