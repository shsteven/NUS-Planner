//
//  ModuleManager.m
//  NUS Mod
//
//  Created by Raymond Hendy on 7/4/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "ModuleManager.h"
#import "Module.h"
#import "ModuleClass.h"
#import "ModuleClassDetail.h"
#import "Timetable.h"
#import "Keyword.h"
#import "TitleWords.h"
#import "CodeWords.h"
#import "DescriptionWords.h"
#import "UIColor+Random.h"
#import "Constants.h"
#include <dispatch/dispatch.h>

@interface ModuleManager()
int dayToInt(NSString *day);
int convertTimeToIndex(NSString *time, NSString *day);
NSInteger sort(id arr1, id arr2, void *context);
NSInteger sortByTime(id arr1, id arr2, void *context);
NSInteger sortByClashes(id arr1, id arr2, void *context);
NSInteger sortByCounter(id arr1, id arr2, void *context);

- (void)readModuleFromHtml;
- (NSURL *)applicationDocumentsDirectory;
@end

static ModuleManager *sharedManager = nil;

@implementation ModuleManager

@synthesize managedObjectContext = __managedObjectContext;
@synthesize timetable = __timetable;
@synthesize combinations = __combinations;
@synthesize constraints = __constraints;

+ (id)sharedManager {
    if(sharedManager) {
        return sharedManager;
    }
    sharedManager = [[self alloc] init];
    return sharedManager;
}

- (id)init {
    self = [super init];
    if(self) {
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
        [self generateCombinations];
    }
    return self;
}

#pragma mark Timetabling algorithm

NSInteger sortByTime(id arr1, id arr2, void *context) {
    ModuleClassDetail *d1 = (ModuleClassDetail *)arr1;
    ModuleClassDetail *d2 = (ModuleClassDetail *)arr2;
    return [d1.startTime intValue] > [d2.startTime intValue];
}

int dayToInt(NSString *day) {
    if([day isEqual:@"MONDAY"]) {
        return 0;
    } else if([day isEqual:@"TUESDAY"]) {
        return 1;
    } else if([day isEqual:@"WEDNESDAY"]) {
        return 2;
    } else if([day isEqual:@"THURSDAY"]) {
        return 3;
    } else if([day isEqual:@"FRIDAY"]) {
        return 4;
    } else {
        return 5;
    }
}

int convertTimeToIndex(NSString *time, NSString *day) {
    int dayI = dayToInt(day);
    int timeI = [time intValue];
    int idx = timeI - 800;
    return (dayI*28) + (idx/100*2) + (idx%100/30);
}

NSInteger sort(id arr1, id arr2, void *context) {
    NSMutableArray *a1 = (NSMutableArray *)arr1;
    NSMutableArray *a2 = (NSMutableArray *)arr2;
    if([a1 count] < [a2 count]) {
        return NSOrderedAscending;
    } else if([a1 count] > [a2 count]) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

NSInteger sortByClashes(id arr1, id arr2, void *context) {
    NSMutableArray *a1 = (NSMutableArray *)arr1;
    NSMutableArray *a2 = (NSMutableArray *)arr2;
    NSNumber *n1 = (NSNumber *)[a1 objectAtIndex:1];
    NSNumber *n2 = (NSNumber *)[a2 objectAtIndex:1];
    return [n1 intValue] < [n2 intValue];
}

NSInteger sortByCounter(id arr1, id arr2, void *context) {
    NSMutableArray *a1 = (NSMutableArray *)arr1;
    NSMutableArray *a2 = (NSMutableArray *)arr2;
    NSString *m1 = (NSString *)[a1 objectAtIndex:0];
    NSString *m2 = (NSString *)[a2 objectAtIndex:0];
    NSNumber *n1 = (NSNumber *)[a1 objectAtIndex:1];
    NSNumber *n2 = (NSNumber *)[a2 objectAtIndex:1];
    
    if([n1 intValue] > [n2 intValue]) {
        return NSOrderedAscending;
    } else if([n1 intValue] < [n2 intValue]) {
        return NSOrderedDescending;
    } else {
        return [m1 compare:m2];
    }
}

- (NSArray *)alternativesForClass:(ModuleClass *)class {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    Module *m = class.module;
    NSString *type = class.type;
    for(ModuleClass *c in m.moduleClasses) {
        if(class != c && [c.type isEqualToString:type]) {
            [results addObject:c];
        }
    }
    return [results copy];
}

bool used_slots[28*6+1]; // 28 30-min slots, 6 days
bool flagFreeSlots[28*6+1];

/*
 * PRIVATE
 * Create an array with subarrays of ModuleClass, categorized based on module code and class type.
 */
- (void)groupSession {
    NSMutableArray *sessionArray = [[NSMutableArray alloc] init];
    for (Module *m in self.timetable.modules) {
        if(![m.enabled boolValue]) continue;
        NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES]];
        NSArray *classes = [[m.moduleClasses allObjects] sortedArrayUsingDescriptors:sortDescriptors];
        
        NSMutableArray *newGroup = [[NSMutableArray alloc] init];
        NSString *type = @"";
        int i;
        for(i = 0; i < [classes count]; i++) {
            ModuleClass *c = (ModuleClass *)[classes objectAtIndex:i];
            if(![c.type isEqual:type]) {
                NSMutableArray *newArr = [[NSMutableArray alloc] init];
                [sessionArray addObject:newArr];
                [newGroup addObject:newArr];
                type = c.type;
            }
        }
        
        type = @"";
        int counter = 0;
        for(i = 0; i < [classes count]; i++) {
            ModuleClass *c = (ModuleClass *)[classes objectAtIndex:i];
            if(i == 0) type = c.type;
            if(![c.type isEqual:type]) {
                type = c.type;
                counter++;
            }
            NSMutableArray *arr = [newGroup objectAtIndex:counter];
            [arr addObject:c];
        }
    }
    
    sessions = [sessionArray sortedArrayUsingFunction:sort context:NULL];
}

- (BOOL)overlaps:(ModuleClass *)c {
    for(ModuleClassDetail *d in c.details) {
        int s = convertTimeToIndex(d.startTime, d.day);
        int e = convertTimeToIndex(d.endTime, d.day);
        int i;
        for(i = s; i < e; i++) {
            if(used_slots[i]) return YES;
        }
    }
    return NO;
}

- (BOOL)overlapModuleClass:(ModuleClass *)a withOtherModuleClass: (ModuleClass *)b {
    //NSLog(@"check overlaps");
    
    for (ModuleClassDetail *d in a.details) {
        for (ModuleClassDetail *e in b.details) {
            int sa = convertTimeToIndex(d.startTime, d.day);
            int ea = convertTimeToIndex(d.endTime, d.day);
            int sb = convertTimeToIndex(e.startTime, e.day);
            int eb = convertTimeToIndex(e.endTime, e.day);
            //NSLog(@"%@ %d %d %@ %d %d", d.day, sa, ea, e.day, sb, eb);
            if (sa <= sb && sb < ea) return YES;
            if (sa < eb && eb < ea) return YES;
            if (sb <= sa && sa < eb) return YES;
            if (sb < ea && ea < eb) return YES;
        }
    }
    //NSLog(@"Fine");
    return NO;
}

- (BOOL)overlapsWithSet:(NSSet *)setOfSelections withModuleClass:(ModuleClass *)c {
    //NSLog(@"Count = %d", [setOfSelections count]);
    for (ModuleClass *sel in setOfSelections) {
        if (![sel.module.code isEqualToString:c.module.code]) {
            if ([self overlapModuleClass:sel withOtherModuleClass:c]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)markTimetable:(ModuleClass *)c withBoolean:(bool)b{
    for(ModuleClassDetail *d in c.details) {
        int s = convertTimeToIndex(d.startTime, d.day);
        int e = convertTimeToIndex(d.endTime, d.day);
        int i;
        for(i = s; i < e; i++) {
            used_slots[i] = b;
        }
    }
}

- (void)permute:(NSInteger)idx {
    if([generatedCombinations count] > 20) return;
    if(idx == [sessions count]) {
        NSMutableArray *newSelections = [[NSMutableArray alloc] initWithArray:selections];
        [generatedCombinations addObject:newSelections];
        return;
    }
    
    NSArray *arr = [sessions objectAtIndex:idx];
    int i;
    for(i = 0; i < [arr count]; i++) {
        ModuleClass *c = [arr objectAtIndex:i];
        if(![self overlaps:c]) {
            [self markTimetable:c withBoolean:true];
            [selections addObject:c];
            [self permute:idx + 1];
            [self markTimetable:c withBoolean:false];
            [selections removeObject:c];
        }
    }
    return;
}

- (NSMutableArray *)sortCombinationsFromGenerator:(NSMutableArray *)generator withConstraint:(NSArray *)freeSlots{
    int i, j, k;
    memset(flagFreeSlots, false, sizeof(flagFreeSlots));
    for (i = 0; i < [freeSlots count]; i++) {
        NSNumber *slot = [[NSNumber alloc] initWithInt:[(NSNumber *)[freeSlots objectAtIndex:i] intValue]];
        int idx = [slot intValue];
        flagFreeSlots[idx] = true;
    }
    
    for (i = 0; i < [generator count]; i++) {
        NSMutableArray *timeTable = [generator objectAtIndex:i];
        int cnt = 0;
        for (j = 0; j < [timeTable count]; j++) {
            NSSet *moduleDetails = [[timeTable objectAtIndex:j] details];
            for (ModuleClassDetail *d in moduleDetails) {
                int s = convertTimeToIndex(d.startTime, d.day);
                int e = convertTimeToIndex(d.endTime, d.day);
                for (k = s; k < e; k++) {
                    cnt += (flagFreeSlots[k] == true?1:0);
                }
            }
        }
        NSNumber *cnt2 = [[NSNumber alloc] initWithInt:cnt];
        [[generator objectAtIndex:i] addObject:cnt2];
    }
    
    [generator sortedArrayUsingFunction:sortByClashes context:NULL];
    for (i = 0; i < [generator count]; i++) {
        [[generator objectAtIndex:i] removeLastObject];
    }
    return generator;
}

/*
 * RETURNS: Array of possible valid timetable of modules listed by user
 */
- (void)generateCombinations {
    //NSLog(@"Generating timetable...");
//    [self willChangeValueForKey:@"generatedCombinations"];
    memset(used_slots, false, sizeof(used_slots));
    generatedCombinations = [[NSMutableArray alloc] init];
    selections = [[NSMutableArray alloc] init];
    [self groupSession];
    [self permute:0];
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kGeneratedCombinationsDidUpdateNotification object:self];
//     [self didChangeValueForKey:@"generatedCombinations"];
    //NSLog(@"Done!");
}

- (NSMutableArray *)combinations {
    self.combinations = generatedCombinations;
    return __combinations;
}

/*
 * RETURNS: Array of of subarrays of ModuleClass objects (auto-generated slots for timetable). Subarrays are categorized by day, sorted by time.
 */
- (NSMutableArray *)categorizedSelections {
    NSMutableArray *categorized = [[NSMutableArray alloc] init];
    int i;
    for(i = 0; i < 5; i++) [categorized addObject:[[NSMutableArray alloc] init]];
    for(ModuleClass *c in self.timetable.selections) {
        for(ModuleClassDetail *d in c.details) {
            [[categorized objectAtIndex:dayToInt(d.day)] addObject:d];
        }
    }
    for(i = 0; i < 5; i++) [[categorized objectAtIndex:i] sortUsingFunction:sortByTime context:NULL];
    return categorized;
}

/*
 * RETURNS: The timetable singleton created by user
 */
- (Timetable *)timetable {
    if(__timetable != nil) {
        return __timetable;
    }
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Timetable" inManagedObjectContext:self.managedObjectContext];
    [req setEntity:ent];
    NSArray *arr = [self.managedObjectContext executeFetchRequest:req error:nil];
    if([arr count] == 0) return nil;
    Timetable *tt = [arr objectAtIndex:0];
    self.timetable = tt;
    return __timetable;
}

/*
 * PRIVATE
 * Given a string reference, returns a set of normalized words contained in the string.
 * Normalized = lowercase characters, removed punctuation 
 */
- (NSMutableSet *)splitAndNormalized:(NSString *)str {
    NSArray *arr = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableSet *newSet = [[NSMutableSet alloc] init];
    for(NSString *w in arr) {
        NSString *normalized = [[w componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]]componentsJoinedByString:@""];
        if([normalized length] != 0) [newSet addObject:[normalized lowercaseString]];
    }
    return newSet;
}

/*
 * Interface for database query.
 * RETURNS: Module with the specified code. Returns nil if not found.
 */
- (Module *)moduleByCode:(NSString *)code {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Module" inManagedObjectContext:self.managedObjectContext];
    req.entity = ent;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"code CONTAINS[cd] %@",code];
    req.predicate = pre;
    req.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
    NSArray *res = [self.managedObjectContext executeFetchRequest:req error:nil];
    if([res count] == 0) return nil;
    return [res objectAtIndex:0];
}

/*
 * Interface for database query.
 * RETURNS: Modules that contain the specified keyword(s). Returns an empty array if not found.
 */
- (NSArray *)modulesBySearchTerm:(NSString *)keywordsString {
    
    NSMutableSet *splitAndNormalize = [self splitAndNormalized:keywordsString];
    
    NSMutableArray *modules = [[NSMutableArray alloc] init];
    NSMutableArray *sortedModules = [[NSMutableArray alloc] init];
    NSMutableDictionary *counter = [[NSMutableDictionary alloc] init];
    
    for(NSString *str in splitAndNormalize) {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Keyword" inManagedObjectContext:self.managedObjectContext];
        req.entity = ent;
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"normalizedWord CONTAINS[cd] %@",str];
        req.predicate = pre;
        NSArray *res = [self.managedObjectContext executeFetchRequest:req error:nil];
        for(Keyword *k in res) {
            NSString *key = [NSString stringWithFormat:@"%@",k.module.code];
            NSInteger cnt = 1;
            if([counter objectForKey:key]) {
                cnt = [[counter objectForKey:key] intValue];
                cnt++;
            }
            [counter setObject:[NSNumber numberWithInt:cnt] forKey:key];
        }
    }
    for (NSString *key in counter) {
        NSMutableArray *pair = [[NSMutableArray alloc] init];
        NSNumber *tmp = [[NSNumber alloc] initWithInt:[[counter objectForKey:key] intValue]];
        [pair addObject:key];
        [pair addObject:tmp];
        [sortedModules addObject:pair];
    }
    NSArray *sorted = [sortedModules sortedArrayUsingFunction:sortByCounter context:NULL];
    for (NSMutableArray *k in sorted) {
        [modules addObject:[self moduleByCode:[k objectAtIndex:0]]];
    }
    return modules;
}


/*
 * Interface for database query.
 * RETURNS: Modules that contain the specified code. The result is sorted by the number of matches. Returns an empty array if not found.
 */
- (NSArray *)allModulesByCode:(NSString *)code {
    
    NSMutableSet *splitAndNormalize = [self splitAndNormalized:code];
    
    NSMutableArray *modules = [[NSMutableArray alloc] init];
    NSMutableArray *sortedModules = [[NSMutableArray alloc] init];
    NSMutableDictionary *counter = [[NSMutableDictionary alloc] init];
    
    for(NSString *str in splitAndNormalize) {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
//        [req setFetchBatchSize:20];
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"CodeWords" inManagedObjectContext:self.managedObjectContext];
        req.entity = ent;
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"normalizedWord CONTAINS[cd] %@",str];
        req.predicate = pre;
        NSArray *res;

        res = [self.managedObjectContext executeFetchRequest:req error:nil];
        for(CodeWords *k in res) {
            NSString *key = [NSString stringWithFormat:@"%@",k.module.code];
            NSInteger cnt = 1;
            if([counter objectForKey:key]) {
                cnt = [[counter objectForKey:key] intValue];
                cnt++;
            }
            [counter setObject:[NSNumber numberWithInt:cnt] forKey:key];
        }
    }
    for (NSString *key in counter) {
        NSMutableArray *pair = [[NSMutableArray alloc] init];
        NSNumber *tmp = [[NSNumber alloc] initWithInt:[[counter objectForKey:key] intValue]];
        [pair addObject:key];
        [pair addObject:tmp];
        [sortedModules addObject:pair];
    }
    
    NSArray *sorted = [sortedModules sortedArrayUsingFunction:sortByCounter context:NULL];
    for (NSMutableArray *k in sorted) {
        //NSLog(@"%@ = %@",[k objectAtIndex:0],[k objectAtIndex:1]);
        [modules addObject:[self moduleByCode:[k objectAtIndex:0]]];
    }
    
    
    
    return  modules;

}

/*
 * Interface for database query.
 * RETURNS: Modules that contain the specified title. The result is sorted by the number of matches. Returns an empty array if not found.
 */
- (NSArray *)allModulesByTitle:(NSString *)title {
    NSMutableSet *splitAndNormalize = [self splitAndNormalized:title];
    
    NSMutableArray *modules = [[NSMutableArray alloc] init];
    NSMutableArray *sortedModules = [[NSMutableArray alloc] init];
    NSMutableDictionary *counter = [[NSMutableDictionary alloc] init];
    
    for(NSString *str in splitAndNormalize) {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"TitleWords" inManagedObjectContext:self.managedObjectContext];
        req.entity = ent;
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"normalizedWord CONTAINS[cd] %@",str];
        req.predicate = pre;
        NSArray *res = [self.managedObjectContext executeFetchRequest:req error:nil];
        for(TitleWords *k in res) {
            NSString *key = [NSString stringWithFormat:@"%@",k.module.code];
            NSInteger cnt = 1;
            if([counter objectForKey:key]) {
                cnt = [[counter objectForKey:key] intValue];
                cnt++;
            }
            [counter setObject:[NSNumber numberWithInt:cnt] forKey:key];
        }
    }
    for (NSString *key in counter) {
        NSMutableArray *pair = [[NSMutableArray alloc] init];
        NSNumber *tmp = [[NSNumber alloc] initWithInt:[[counter objectForKey:key] intValue]];
        [pair addObject:key];
        [pair addObject:tmp];
        [sortedModules addObject:pair];
    }
    
    NSArray *sorted = [sortedModules sortedArrayUsingFunction:sortByCounter context:NULL];
    for (NSMutableArray *k in sorted) {
        [modules addObject:[self moduleByCode:[k objectAtIndex:0]]];
    }
    return modules;
}

/*
 * Interface for database query.
 * RETURNS: Modules that contain the specified description. The result is sorted by the number of matches. Returns an empty array if not found.
 */
- (NSArray *)allModulesByDescription:(NSString *)description {
    NSMutableSet *splitAndNormalize = [self splitAndNormalized:description];
    
    NSMutableArray *modules = [[NSMutableArray alloc] init];
    NSMutableArray *sortedModules = [[NSMutableArray alloc] init];
    NSMutableDictionary *counter = [[NSMutableDictionary alloc] init];
    
    for(NSString *str in splitAndNormalize) {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"DescriptionWords" inManagedObjectContext:self.managedObjectContext];
        req.entity = ent;
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"normalizedWord CONTAINS[cd] %@",str];
        req.predicate = pre;
        NSArray *res = [self.managedObjectContext executeFetchRequest:req error:nil];
        for(DescriptionWords *k in res) {
            NSString *key = [NSString stringWithFormat:@"%@",k.module.code];
            NSInteger cnt = 1;
            if([counter objectForKey:key]) {
                cnt = [[counter objectForKey:key] intValue];
                cnt++;
            }
            [counter setObject:[NSNumber numberWithInt:cnt] forKey:key];
        }
    }
    for (NSString *key in counter) {
        NSMutableArray *pair = [[NSMutableArray alloc] init];
        NSNumber *tmp = [[NSNumber alloc] initWithInt:[[counter objectForKey:key] intValue]];
        [pair addObject:key];
        [pair addObject:tmp];
        [sortedModules addObject:pair];
    }
    
    NSArray *sorted = [sortedModules sortedArrayUsingFunction:sortByCounter context:NULL];
    for (NSMutableArray *k in sorted) {
        [modules addObject:[self moduleByCode:[k objectAtIndex:0]]];
    }
    return modules;
}

- (ModuleClass *)classByModuleCode:(NSString *)code
                           classNo:(NSString *)no
                              type:(NSString *)type {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"ModuleClass" inManagedObjectContext:self.managedObjectContext];
    req.entity = ent;
    
    NSString *preString = @"module.code LIKE %@ AND classNumber LIKE %@ AND type LIKE %@";
    NSPredicate *pre = [NSPredicate predicateWithFormat:preString,code,no,type];
    req.predicate = pre;
    NSArray *res = [self.managedObjectContext executeFetchRequest:req error:nil];
    if([res count] == 0) return nil;
    return [res objectAtIndex:0];
}

/*
 * EFFECTS: Download module weblinks from CORS and save to links.txt
 */
- (void)grabLink {
    NSLog(@"Downloading links.");
    //NSString *corsUrl = @"https://aces01.nus.edu.sg/cors/jsp/report/ModuleInfoListing.jsp?mod_c=CS#37;";
    NSString *corsUrl = @"https://aces01.nus.edu.sg/cors/jsp/report/ModuleInfoListing.jsp";
    NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:corsUrl] usedEncoding:nil error:nil];
    
    NSString *pattern = @"<a href=\"(ModuleDetailedInfo\\.jsp.+?)\">";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:html options:0 range:NSMakeRange(0,[html length])];
    
    NSURL *urlpath = [self applicationDocumentsDirectory];
    NSString *path = [urlpath path];
    path = [path stringByAppendingString:@"/links.txt"];
    const char *cpath = [path UTF8String];
    FILE *f;
    if((f = fopen(cpath, "w+")) != NULL) {
        int counter = 0;
        for(NSTextCheckingResult *r in results) {
            if(counter++ % 2 != 0) continue;
            NSRange range = [r rangeAtIndex:1];
            NSString *link = [html substringWithRange:range];
            link = [@"https://aces01.nus.edu.sg/cors/jsp/report/" stringByAppendingString:link];
            fprintf(f,"%s\n",[link UTF8String]);
            fflush(f);
            // DEBUG
            //if (counter > 5) break;
        }
    }
    fclose(f);
}

/*
 * EFFECTS: Download module info from CORS and convert to Core Data model objects then save to database
 */
- (void)readModule {
    //NSString *urlString = @"https://aces01.nus.edu.sg/cors/jsp/report/ModuleDetailedInfo.jsp?acad_y=2011/2012&sem_c=1&mod_c=AR4322";
    NSURL *urlpath = [self applicationDocumentsDirectory];
    NSString *path = [urlpath path];
    path = [path stringByAppendingString:@"/links.txt"];
    const char *file = [path UTF8String];
    FILE *pFile;
    if((pFile = fopen ( file , "r+" )) != NULL) {
        NSLog(@"Begin updating data.");
        NSString *urlString;
        char buffer[1025];
        while(fgets(buffer, 1024, pFile)) {
            urlString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
            urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            while(1) {
                htmlContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] usedEncoding:nil error:nil];
                if(htmlContent) break;
                else {
                    NSLog(@"Failed opening URL. Attempt to reconnect.");
                }
            }
            [self readModuleFromHtml];
        }
        NSLog(@"Data updated.");
    }
}

/*
 * EFFECTS: Add the specified module into timetable. Context is saved.
 */
- (void)addModule:(Module *)m {
    UIColor *color = [UIColor randomColor];
    while ([self colorIsUsed: color]) 
        color = [UIColor randomColor];
    m.color = color;
    
    m.enabled = [NSNumber numberWithBool:YES];
    [self.timetable addModulesObject:m];
    [self generateCombinations];
    NSLog(@"%d count",[generatedCombinations count]);
    NSError *err;
    if(![self.managedObjectContext save:&err]) {
        NSLog(@"Saving error: %@",[err userInfo]);
    }
}

/*
 * EFFECTS: Remove the specified module into timetable. Context is saved.
 */
- (void)removeModule:(Module *)m {
    m.color = nil;
    [self.timetable removeModulesObject:m];
    [self generateCombinations];
    NSError *err;
    if(![self.managedObjectContext save:&err]) {
        NSLog(@"Saving error: %@",[err userInfo]);
    }
}

- (void)enableModule:(Module *)m {
    m.enabled = [NSNumber numberWithBool:YES];
    [self generateCombinations];
}

- (void)disableModule:(Module *)m {
    m.enabled = [NSNumber numberWithBool:NO];
    [self generateCombinations];
}

- (void)addConstraint:(NSNumber *)constraint {
    if(!constraints) {
        self.constraints = [[NSMutableSet alloc] init];
    }
    [constraints addObject:constraint];
    [self sortCombinationsFromGenerator:generatedCombinations withConstraint:[constraints allObjects]];
}

- (void)removeConstraint:(NSNumber *)constraint {
    if(constraints) {
        [constraints removeObject:constraint];
        [self sortCombinationsFromGenerator:generatedCombinations withConstraint:[constraints allObjects]];
    }
}

/*
 * REQUIRES: Time slot is available/not occupied
 * EFFECTS: Remove a class slot with the same module code and same class type (Lecture,Tutorial, etc.). Add the new one. Context is saved.
 */
- (void)addClass:(ModuleClass *)c {
    for(ModuleClass *class in self.timetable.selections) {
        if([class.type isEqualToString:c.type] && [class.module.code isEqualToString:c.module.code]) {
            [self.timetable removeSelectionsObject:class];
            break;
        }
    }
    [self.timetable addSelectionsObject:c];
    NSError *err;
    if(![self.managedObjectContext save:&err]) {
        NSLog(@"Saving error: %@",[err userInfo]);
    }
}



#define CODE_PATTERN @"<td width=\"70%\">(.+?)</td>"
#define TITLE_PATTERN  @"<td>Module Title :</td>.+?<td>(.+?)</td>"
#define DESC_PATTERN @"<td valign=top>Module Description :</td>.+?<td valign=top>(.+?)</td>"
//#define DATE_PATTERN @"(\\d\\d\\-\\d\\d\\-\\d\\d\\d\\d)\\s\\w+\\<br\\>"
#define DATE_PATTERN @"<td>Exam Date :</td>.+?<td>(.+?)</td>"
#define MC_PATTERN  @"<td>Modular Credits :</td>.+?<td>(.+?)</td>"
#define PREREQ_PATTERN @"<td>Pre-requisite :</td>.+?<td>(.+?)</td>"
#define PRECL_PATTERN @"<td>Preclusion :</td>.+?<td>(.+?)</td>"
#define WL_PATTERN @"<td>Module Workload.+?:</td>.+?<td>(.+?)</td>"
#define LECT_START_PATTERN @"<td colspan=\"4\"><b>Lecture Time Table</b></td>"
#define LECT_END_PATTERN @"<table width=\"100%\" border=\"1\""
#define TUT_START_PATTERN @"<td><a name=\"TutorialTimeTable\"><b>"
#define TUT_END_PATTERN @"<!-- Check to see if required"

#pragma mark Parsing routines

- (NSString *)extractInfoWithPattern:(NSString *)pattern formatted:(BOOL)shouldFormat {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:htmlContent options:0 range:NSMakeRange(0, htmlContent.length)];
    
    NSString *code = [htmlContent substringWithRange:[result rangeAtIndex:1]];
    code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(shouldFormat) {
        code = [code stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        NSArray *components = [code componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *filtered = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
        
        int i = 0;
        code = @"";
        for(NSString *comp in filtered) {
            if(i++) {
                code = [code stringByAppendingFormat:@" %@",comp];
            } else {
                code = [code stringByAppendingString:comp];
            }
        }
    }
    return code;
}

- (NSSet *)extractSessionInfoWithType:(NSString *)t{
    int iEnd;
    NSString *start, *end;
    if([t isEqual:@"Lecture"]) {
        iEnd = 1;
        start = LECT_START_PATTERN;
        end = LECT_END_PATTERN;
    } else {
        iEnd = 0;
        start = TUT_START_PATTERN;
        end = TUT_END_PATTERN;
    }
    
    NSString *find = [NSString stringWithFormat:@"No %@ Class",t];
    NSRange checkExist = [htmlContent rangeOfString:find];
    if(checkExist.location == NSNotFound) { // if it has the specified class type
        NSMutableSet *classes = [[NSMutableSet alloc] init];
        // find the class block
        NSRange startBlock = [htmlContent rangeOfString:start];
        NSRange startBlockToEnd = NSMakeRange(startBlock.location, [htmlContent length]-startBlock.location);
        NSRange endBlock = [htmlContent rangeOfString:end options:0 range:startBlockToEnd];
        NSRange range = NSMakeRange(startBlock.location, endBlock.location-startBlock.location);
        NSString *block = [htmlContent substringWithRange:range];
        
        NSRange startRange, endRange = NSMakeRange(iEnd, [block length]-1), startRangeToEnd;
        NSString *sessionBlock = @"";
        while(1) { // read each block
            startRange = [block rangeOfString:@"<td colspan=\"4\">" options:0 range:endRange];
            startRangeToEnd = NSMakeRange(startRange.location, [block length]-startRange.location);
            if(startRange.location == NSNotFound) break;
            
            ModuleClass *aClass = [NSEntityDescription insertNewObjectForEntityForName:@"ModuleClass" inManagedObjectContext:[self managedObjectContext]];
            NSMutableSet *details = [[NSMutableSet alloc] init];
            
            endRange = [block rangeOfString:@"</table>" options:0 range:startRangeToEnd];
            endRange.length = [block length]-endRange.location;
            sessionBlock = [block substringWithRange:NSMakeRange(startRange.location+16,endRange.location-startRange.location)];
            
            NSArray *split = [sessionBlock componentsSeparatedByString:@"<br>"];
            split = [split filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
            
            // first line
            NSString *first = [split objectAtIndex:0];
            NSRange rangeOfClass = [first rangeOfString:@"Class"];
            NSRange openBracket = [first rangeOfString:@"["];
            NSRange closeBracket = [first rangeOfString:@"]"];
            NSRange noRange = NSMakeRange(openBracket.location+1, closeBracket.location-openBracket.location-1);
            NSString *type = [first substringToIndex:rangeOfClass.location-1];
            NSString *no = [first substringWithRange:noRange];
            
            int num = [split count]/2-1, i;
            for(i = 0; i < num; i++) {
                NSString *line1 = [split objectAtIndex:i*2+1];
                NSString *line2 = [split objectAtIndex:i*2+2];
                
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\w+) From (\\d+) hrs to (\\d+) hrs in (.+)," options:0 error:nil];
                NSTextCheckingResult *res = [regex firstMatchInString:line1 options:0 range:NSMakeRange(0, [line1 length])];
                NSString *day = [line1 substringWithRange:[res rangeAtIndex:1]];
                NSString *startTime = [line1 substringWithRange:[res rangeAtIndex:2]];
                NSString *endTime = [line1 substringWithRange:[res rangeAtIndex:3]];
                NSString *venue = [line1 substringWithRange:[res rangeAtIndex:4]];
                
                NSRange weekRange = [line2 rangeOfString:@":"];
                NSRange dotRange = [line2 rangeOfString:@"."];
                NSRange selection = NSMakeRange(weekRange.location+2, dotRange.location-weekRange.location-2);
                NSString *weekType = [line2 substringWithRange:selection];
                
                ModuleClassDetail *session = [NSEntityDescription insertNewObjectForEntityForName:@"ModuleClassDetail" inManagedObjectContext:[self managedObjectContext]];
                session.day = day;
                session.startTime = startTime;
                session.endTime = endTime;
                session.weeks = weekType;
                session.venue = venue;
                session.moduleClass = aClass;
                [details addObject:session];
            }
            
            aClass.type = type;
            aClass.classNumber = no;
            aClass.details = details;
            
            if([details count] == 0) {
                [self.managedObjectContext deleteObject:aClass];
            } else {
                [classes addObject:aClass];
            }
        }        
        return classes;
    }
    return nil;
}

- (void)insertNormalizedWordsForModule:(Module *)m {
    NSMutableSet *codeSet = [self splitAndNormalized:m.code];
    NSMutableSet *titleSet = [self splitAndNormalized:m.title];
    NSMutableSet *descSet = [self splitAndNormalized:m.moduleDescription];
    
    for(NSString *str in codeSet) {
        CodeWords *k = [NSEntityDescription insertNewObjectForEntityForName:@"CodeWords" inManagedObjectContext:[self managedObjectContext]];
        [k setModule:m];
        [k setNormalizedWord:str];
        [m addNormalizedCodeWordsObject:k];
    }
    
    for(NSString *str in titleSet) {
        TitleWords *k = [NSEntityDescription insertNewObjectForEntityForName:@"TitleWords" inManagedObjectContext:[self managedObjectContext]];
        [k setModule:m];
        [k setNormalizedWord:str];
        [m addNormalizedTitleWordsObject:k];
    }
    
    for(NSString *str in descSet) {
        DescriptionWords *k = [NSEntityDescription insertNewObjectForEntityForName:@"DescriptionWords" inManagedObjectContext:[self managedObjectContext]];
        [k setModule:m];
        [k setNormalizedWord:str];
        [m addNormalizedDescriptionWordsObject:k];
    }
    
    [codeSet addObjectsFromArray:[titleSet allObjects]];
    [codeSet addObjectsFromArray:[descSet allObjects]];
    
    for(NSString *str in codeSet) {
        Keyword *k = [NSEntityDescription insertNewObjectForEntityForName:@"Keyword" inManagedObjectContext:[self managedObjectContext]];
        [k setModule:m];
        [k setNormalizedWord:str];
        [m addNormalizedWordsObject:k];
    }
}

- (void)readModuleFromHtml {
    NSString *code = [self extractInfoWithPattern:CODE_PATTERN formatted:YES];
    NSString *title = [self extractInfoWithPattern:TITLE_PATTERN formatted:NO];
    NSString *exam = [self extractInfoWithPattern:DATE_PATTERN formatted:YES];
    NSString *desc = [self extractInfoWithPattern:DESC_PATTERN formatted:NO];
    NSString *mc = [self extractInfoWithPattern:MC_PATTERN formatted:NO];
    NSString *prereq = [self extractInfoWithPattern:PREREQ_PATTERN formatted:NO];
    NSString *prec = [self extractInfoWithPattern:PRECL_PATTERN formatted:NO];
    NSString *wl = [self extractInfoWithPattern:WL_PATTERN formatted:NO];
    
    Module *m = [NSEntityDescription insertNewObjectForEntityForName:@"Module" inManagedObjectContext:[self managedObjectContext]];
    
    m.code = code;
    m.title = title;
    m.examDate = exam;
    m.moduleDescription = desc;
    m.modularCredit = mc;
    m.prerequisite = prereq;
    m.preclusion = prec;
    m.workload = wl;
    
    NSSet *lecSet = [self extractSessionInfoWithType:@"Lecture"];
    NSSet *tutSet = [self extractSessionInfoWithType:@"Tutorial"];
    NSMutableSet *s = [[NSMutableSet alloc] init];
    [s addObjectsFromArray:[lecSet allObjects]];
    [s addObjectsFromArray:[tutSet allObjects]];
    m.moduleClasses = s;
    
    [self insertNormalizedWordsForModule:m];
    
    NSError *err = nil;
    if (![self.managedObjectContext save:&err]) {
        NSLog(@"Error saving: %@ ",[err userInfo]);
    } else {
        NSLog(@"Saved: %@",code);
    }
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)colorIsUsed:(UIColor *)color {
    for (Module *aModule in self.timetable.modules) {
        if ([aModule.color colorIsSimilarToColor:color]) return YES;
    }
    return NO;
}

- (BOOL)equal:(NSMutableArray *)t1 with:(NSMutableArray *)t2 {
    NSMutableDictionary *used = [[NSMutableDictionary alloc] init];
    for (ModuleClass *mod in t1) {
        NSString *key = [NSString stringWithFormat:@"%@-%@-%@", mod.module.code, mod.classNumber, mod.type];
        [used setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
    for (ModuleClass *mod in t2) {
        NSString *key = [NSString stringWithFormat:@"%@-%@-%@", mod.module.code, mod.classNumber, mod.type];
        if (![used objectForKey:key]) return NO;
    }
    used = [[NSMutableDictionary alloc] init];
    for (ModuleClass *mod in t2) {
        NSString *key = [NSString stringWithFormat:@"%@-%@-%@", mod.module.code, mod.classNumber, mod.type];
        [used setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
    for (ModuleClass *mod in t1) {
        NSString *key = [NSString stringWithFormat:@"%@-%@-%@", mod.module.code, mod.classNumber, mod.type];
        if (![used objectForKey:key]) return NO;
    }
    return YES;
}

- (void)updateGeneratedCombinations:(NSSet *)selectedSet currentIndex:(NSInteger)index {
    NSMutableArray *selected = [NSMutableArray arrayWithArray:[selectedSet allObjects]];
    bool found = false;
    int idx = 0;
    for (NSMutableArray *timetable in generatedCombinations) {
        if ([self equal:timetable with:selected]) {
            found = true;
            NSMutableArray *temp = [generatedCombinations objectAtIndex:index];
            [generatedCombinations replaceObjectAtIndex:index withObject:timetable];
            [generatedCombinations replaceObjectAtIndex:idx withObject:temp];
            return;
        }
        idx++;
    }
    
    [generatedCombinations insertObject:selected atIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNumberOfPagesDidChangeNotification object:self];
}

- (BOOL)sameTimeModule:(ModuleClass *)cls1 withModule:(ModuleClass *)cls2 {
    for(ModuleClassDetail *d1 in cls1.details) {
        NSString *time1 = [NSString stringWithFormat:@"%@-%@-%@",d1.day,d1.startTime,d1.endTime];
        BOOL found = NO;
        for(ModuleClassDetail *d2 in cls2.details) {
            NSString *time2 = [NSString stringWithFormat:@"%@-%@-%@",d2.day,d2.startTime,d2.endTime];
            if ([time1 isEqualToString:time2]) {
                found = YES;
                break;
            }
        }
        if(!found) return NO;
    }
    return YES;
}

- (NSSet *)findModuleClassWithSameTime:(ModuleClass *)cls {
    NSMutableSet *result = [[NSMutableSet alloc] init];
    NSSet *classes = cls.module.moduleClasses;
    for(ModuleClass *c in classes) {
        if([cls.type isEqualToString:c.type]) {
            if([self sameTimeModule:cls withModule:c]) {
                [result addObject:c];
            }
        }
    }
    return [NSSet setWithSet:result];
}

@end
