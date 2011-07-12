//
//  ModuleClassDetail.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/12/11.
//  Copyright (c) 2011 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ModuleClass;

@interface ModuleClassDetail : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSString * endTime;
@property (nonatomic, retain) NSString * startTime;
@property (nonatomic, retain) NSString * venue;
@property (nonatomic, retain) NSString * weeks;
@property (nonatomic, retain) ModuleClass *moduleClass;

@end
