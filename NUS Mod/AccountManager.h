//
//  AccountManager.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/1/11.
//  Copyright 2011 NUS. All rights reserved.
//

@class User;
@class Categories;
@class AcademicPeriod;
@class Module;

@protocol AccountManagerLoginDelegate;

#import <Foundation/Foundation.h>

@interface AccountManager : NSObject<NSXMLParserDelegate> {
    NSXMLParser *xmlparser;
    __unsafe_unretained id <AccountManagerLoginDelegate> delegate;
    NSMutableData *receivedData;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign) id <AccountManagerLoginDelegate> delegate;

/*
 * The user of this app
 */
@property (strong, nonatomic) User *user;

@property (readonly, assign, nonatomic) BOOL hasUser;

@property (readonly, strong, nonatomic) NSArray *academicYears;

@property (readonly, strong, nonatomic) NSArray *categories;

+ (id)sharedManager;

/*
 * EFFECTS: Login to IVLE with the specified ID and password
 */
- (void)loginWithUserID:(NSString *)accID password:(NSString *)pass;

- (void)resetAccount;

- (void)addCategoryWithName:(NSString *)name;

- (void)addCategory:(Categories *)c;

- (void)removeCategory:(Categories *)c;

- (void)addModule:(Module *)m toCategory:(Categories *)c;

- (void)removeModule:(Module *)m fromCategory:(Categories *)c;

- (NSInteger)countMCInSemester:(AcademicPeriod *)p;

- (NSInteger)countMC;

@end

@protocol AccountManagerLoginDelegate <NSObject>

- (void)didLoginWithStatus:(BOOL)isSuccess;

@end
