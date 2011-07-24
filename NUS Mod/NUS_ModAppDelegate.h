//
//  NUS_ModAppDelegate.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/1/11.
//  Copyright 2011 NUS. All rights reserved.
//

@class ModuleManager;
@class MainViewController;

#import <UIKit/UIKit.h>

@interface NUS_ModAppDelegate : UIResponder <UIApplicationDelegate> {
    MainViewController *mainViewController;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) ModuleManager *manager;

@property (strong, nonatomic) UINavigationController *navigationController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)testData;

- (void)copyBundleData;
@end
