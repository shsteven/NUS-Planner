//
//  DescriptionWords.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/15/11.
//  Copyright (c) 2011 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Module;

@interface DescriptionWords : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * normalizedWord;
@property (nonatomic, retain) Module *module;

@end
