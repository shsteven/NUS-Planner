//
//  AccountManager.m
//  NUS Mod
//
//  Created by Raymond Hendy on 7/1/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "NSManagedObjectContext+Fetch.h"
#import "AccountManager.h"
#import "ModuleManager.h"
#import "User.h"
#import "AcademicPeriod.h"
#import "Module.h"
#import "Categories.h"

static AccountManager *sharedManager = nil;

@implementation AccountManager

@synthesize managedObjectContext = __managedObjectContext;
@synthesize user = __user;
@synthesize hasUser = __hasUser;
@synthesize delegate = __delegate;

+ (id)sharedManager {
    if(sharedManager) {
        return sharedManager;
    }
    sharedManager = [[self alloc] init];
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        id appDelegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [appDelegate managedObjectContext];
    }
    
    return self;
}

- (NSArray *)academicYears {
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"period" ascending:YES];
    NSArray *descs = [NSArray arrayWithObject:sortDesc];
    return [self.user.semesters sortedArrayUsingDescriptors:descs];
}

- (NSArray *)categories {
    return [self.user.categories allObjects];
}

- (BOOL)hasUser {
    return !((self.user == nil) || (self.user.accountID == nil) || ([self.user.accountID length] == 0));
}

/*
 * The user of this app.
 */
- (User *)user {
    if(__user != nil) {
        return __user;
    }
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [req setEntity:ent];
    NSArray *arr = [self.managedObjectContext executeFetchRequest:req error:nil];
    if([arr count] == 0) return nil;
    User *u = [arr objectAtIndex:0];
    self.user = u;
    return __user;
}

- (void)resetAccount {
    [self.user setAccountID:@""];
    [self.user setPassword:@""];
    [self.user removeSemesters:self.user.semesters];
    [self.user removeCategories:self.user.categories];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"AcademicPeriod" inManagedObjectContext:self.managedObjectContext];
    req.entity = ent;
    NSArray *periods = [self.managedObjectContext executeFetchRequest:req error:nil];
    
    ent = [NSEntityDescription entityForName:@"Categories" inManagedObjectContext:self.managedObjectContext];
    req.entity = ent;
    NSArray *results = [periods arrayByAddingObjectsFromArray:[self.managedObjectContext executeFetchRequest:req error:nil]];
    
    for(NSManagedObject *obj in results) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    [self.managedObjectContext save:nil];
}

/*
 * EFFECTS: Login to IVLE with the specified ID and password
 */
- (void)loginWithUserID:(NSString *)accID password:(NSString *)pass {
    [self resetAccount];
    [self.user setAccountID:[accID uppercaseString]];
    [self.user setPassword:pass];
    NSString *urlString = [NSString stringWithFormat:@"http://mobapps.nus.edu.sg/api/student/%@/modules",[accID uppercaseString]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [NSMutableData data];
    } else {
        // Inform the user that the connection failed.
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if([elementName isEqualToString:@"response"]) {
        NSString *status = [attributeDict objectForKey:@"status"];
        if([status isEqualToString:@"404"]) {
            [parser abortParsing];
        }
    }
    if([elementName isEqualToString:@"modhist"]) {
        NSString *module = [attributeDict objectForKey:@"module"];
        NSString *sem = [attributeDict objectForKey:@"semester"];
        NSString *year = [attributeDict objectForKey:@"year"];

        NSString *ay = [NSString stringWithFormat:@"AY %@ Semester %@",year,sem];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"period MATCHES[cd] %@",ay];
        NSSet *periods = [self.managedObjectContext fetchObjectsForEntityName:@"AcademicPeriod" withPredicate:pred,nil];
        AcademicPeriod *period = nil;
        if([periods count] == 0) {
            period = [NSEntityDescription insertNewObjectForEntityForName:@"AcademicPeriod" inManagedObjectContext:self.managedObjectContext];
            [period setPeriod:ay];
            [self.user addSemestersObject:period];
        } else {
            period = [[periods allObjects] objectAtIndex:0];
        }
        
        Module *m = [[ModuleManager sharedManager] moduleByCode:module];
        if(m) {
            [period addModulesObject:m];
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.managedObjectContext save:nil];
    [self.delegate didLoginWithStatus:YES];
    
}

- (void)addCategoryWithName:(NSString *)name {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name LIKE[cd] %@",name];
    NSSet *results = [self.managedObjectContext fetchObjectsForEntityName:@"Categories" withPredicate:pre,nil];
    if([results count] > 0) {
        return;
    } else {
        Categories *c = [NSEntityDescription insertNewObjectForEntityForName:@"Categories" inManagedObjectContext:self.managedObjectContext];
        c.name = name;
        [self addCategory:c];
    }
}

- (void)addCategory:(Categories *)c {
    [self.user addCategoriesObject:c];
    [self.managedObjectContext save:nil];
}

- (void)removeCategory:(Categories *)c {
    [self.user removeCategoriesObject:c];
    [self.managedObjectContext deleteObject:c];
    [self.managedObjectContext save:nil];
}

- (void)addModule:(Module *)m toCategory:(Categories *)c {
    [c addModulesObject:m];
    [self.managedObjectContext save:nil];
}

- (void)removeModule:(Module *)m fromCategory:(Categories *)c {
    [c removeModulesObject:m];
    [self.managedObjectContext save:nil];
}

- (NSInteger)countMCInSemester:(AcademicPeriod *)p {
    NSInteger ct = 0;
    for(Module *m in p.modules) {
        ct += [m.modularCredit intValue];
    }
    return ct;
}

- (NSInteger)countMC {
    NSInteger ct = 0;
    for(AcademicPeriod *p in self.user.semesters) {
        ct += [self countMCInSemester:p];
    }
    return ct;
}

#pragma mark Connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    NSLog(@"Connection Error");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{    
    xmlparser = [[NSXMLParser alloc] initWithData:receivedData];
    xmlparser.delegate = self;
    [xmlparser parse];
    if(xmlparser.parserError) {
        [self.delegate didLoginWithStatus:NO];
    }
    
}

@end
