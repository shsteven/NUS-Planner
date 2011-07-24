//
//  User.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/15/11.
//  Copyright (c) 2011 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AcademicPeriod, Categories;

@interface User : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * matric;
@property (nonatomic, retain) NSSet *semesters;
@property (nonatomic, retain) NSSet *categories;
@end

@interface User (CoreDataGeneratedAccessors)
- (void)addSemestersObject:(AcademicPeriod *)value;
- (void)removeSemestersObject:(AcademicPeriod *)value;
- (void)addSemesters:(NSSet *)value;
- (void)removeSemesters:(NSSet *)value;
- (void)addCategoriesObject:(Categories *)value;
- (void)removeCategoriesObject:(Categories *)value;
- (void)addCategories:(NSSet *)value;
- (void)removeCategories:(NSSet *)value;

@end
