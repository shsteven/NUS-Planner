//
//  main.m
//  NUS Mod
//
//  Created by Raymond Hendy on 7/1/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NUS_ModAppDelegate.h"

int main(int argc, char *argv[])
{
    int retVal = 0;
    @autoreleasepool {
        retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([NUS_ModAppDelegate class]));
    }
    return retVal;
}
