//
//  AddCategoryViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/13/11.
//  Copyright 2011 NUS. All rights reserved.
//

@protocol AddCategoryDelegate;

#import <UIKit/UIKit.h>

@interface AddCategoryViewController : UIViewController {
    IBOutlet UITextField *nameTextField;
    __unsafe_unretained id <AddCategoryDelegate> delegate;
}

@property (assign) id <AddCategoryDelegate> delegate;

@end

@protocol AddCategoryDelegate <NSObject>

- (void)didAddNewCategory;

@end