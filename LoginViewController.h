//
//  LoginViewController.h
//  NUS Mod
//
//  Created by Raymond Hendy on 7/15/11.
//  Copyright 2011 NUS. All rights reserved.
//

@protocol LoginViewControllerDelegate;

#import <UIKit/UIKit.h>
#import "AccountManager.h"

@interface LoginViewController : UIViewController<AccountManagerLoginDelegate> {
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    __unsafe_unretained id<LoginViewControllerDelegate> delegate;
}

@property (assign) id<LoginViewControllerDelegate> delegate;

@end

@protocol LoginViewControllerDelegate <NSObject>

- (void)didLogin;

@end
