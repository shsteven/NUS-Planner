//
//  NUS_ModAppDelegate.m
//  NUS Mod
//
//  Created by Raymond Hendy on 7/1/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "NUS_ModAppDelegate.h"

#import "MainViewController.h"

#import "NSManagedObjectContext+Fetch.h"
#import "ModuleManager.h"
#import "User.h"
#import "Timetable.h"
#import "Module.h"
#import "ModuleClass.h"
#import "ModuleClassDetail.h"
#import "Keyword.h"

@implementation NUS_ModAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize manager;


+ (void)initialize {
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], @"DataLoaded", 
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)printEachDay:(NSMutableArray *)day {
    for(ModuleClassDetail *d in day) {
        printf("%4s-%4s\t%s\t%s %s [%s]\n",[d.startTime UTF8String],
               [d.endTime UTF8String], [d.venue UTF8String],d.moduleClass.module.code.UTF8String,d.moduleClass.type.UTF8String,d.moduleClass.classNumber.UTF8String);
    }
}

- (void)printTimetable {
    Timetable *tt = [manager timetable];
    printf("Modules chosen:");
    for(Module *m in tt.modules) {
        printf(" %s",[m.code UTF8String]);
    }
    printf("\nSchedule:\n");
    
    if([tt.selections count] == 0) {
        printf("N/A\n");
        return;   
    }
    
    NSArray *arr = [manager categorizedSelections];
    
    int i = 1;
    for(; i < 6; i++) {
        printf("Day %d\n",i);
        [self printEachDay:[arr objectAtIndex:i-1]];
        printf("---------------------------------------------------\n");
    }
    
    /*
    for(ModuleClass *c in tt.selections) {
        printf("%s %s [%s]\n",[c.module.code UTF8String],[c.type UTF8String],[c.classNumber UTF8String]);
        for(ModuleClassDetail *d in c.details) {
            printf("%s from %s to %s in %s\n",
                   [d.day UTF8String], [d.startTime UTF8String],
                   [d.endTime UTF8String], [d.venue UTF8String]);
            printf("%s\n",[d.weeks UTF8String]);
        }
        printf("\n");
    }*/
}

- (void)searchTesting {
    NSArray *set = [manager modulesBySearchTerm:@"DiSCreTe algorithms"];
    for(Module *k in set) {
        NSLog(@"%@",k.code);
    }
}

- (void)initTesting {
//    const char mods_arr[][10] = {"CS1010","CS1231","CS1020","CS1281","CS2010","CS2101", "CS3230"};
//    NSMutableArray *mods = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 6; i++) {
//        [mods addObject:[NSString stringWithCString:mods_arr[i] encoding:NSUTF8StringEncoding]];
//    }
//    
//    [manager.timetable removeModules:manager.timetable.modules];
//    [manager.timetable removeSelections:manager.timetable.selections];
//    
//    for (NSString *str in mods) {
//        Module *m = [manager moduleByCode:str];
//        [manager addModule:m];
//    }
//
//    int LIMIT = 5, count = 0;
//    NSArray *allArr = [manager generateCombinations];
//    for(NSMutableArray *arr in allArr) {
//        if(count >= LIMIT) break;
//        printf("\n############### Timetable %d ###############\n\n",++count);
//    NSSet *set = [[NSSet alloc] initWithArray:arr];
//    [manager.timetable setSelections:set];
//    [self printTimetable];
//    }
}

- (void)dataInit {
    // create our timetable (singleton)
    Timetable *tt = [NSEntityDescription insertNewObjectForEntityForName:@"Timetable" inManagedObjectContext:self.managedObjectContext];
    [tt setId:[NSNumber numberWithInt:1]];
    
    [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    
    [self saveContext];
    
    // download to links.txt
    [manager grabLink];
    
    // read from links.txt and download data
    [manager readModule];

    [self saveContext];
}

- (void)copyBundleData {
    NSURL *source = [[NSBundle mainBundle] URLForResource:@"NUS Mod" withExtension:@"sqlite"];
    NSURL *url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NUS Mod.sqlite"];
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:source toURL:url error:&error];
    if (!success) {
        NSLog(@"error copying bundle data: %@", [error description]);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DataLoaded"]) {
        [self copyBundleData];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DataLoaded"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    manager = [ModuleManager sharedManager];
    
    // uncomment for first time use
    //[self dataInit];
//    [self searchTesting];
    //[self initTesting];
    
    mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    [self testData];
    
    return YES;
}

- (void)testData {
    // Test fetching data from Core Data
//    NSSet *set = [self.managedObjectContext fetchObjectsForEntityName:@"Module" withPredicate:nil];
//    NSLog(@"%@", set);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NUS Mod" withExtension:@"momd"];

    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NUS Mod.sqlite"];
    //NSString *storePath = [storeURL path];
    
    /*
    if (![[NSFileManager defaultManager] fileExistsAtPath:storePath]) {
        NSString *bundleStore = [[NSBundle mainBundle] pathForResource:@"NUS Mod" ofType:@"sqlite"];
        
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:bundleStore toPath:storePath error:&error];
        
        if (error){
            NSLog(@"Error copying: %@", error);
        }
    }
    */
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
