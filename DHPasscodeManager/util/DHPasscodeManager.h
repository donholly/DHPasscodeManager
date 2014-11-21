//
//  DHPasscodeManager.h
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeViewController.h"

#import "DHPasscodeManagerStyle.h"

#import <SSKeychain/SSKeychain.h>

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#import <LocalAuthentication/LocalAuthentication.h>
#endif

#define DH_PASSCODE_KEYCHAIN_SERVICE_NAME @"DHPasscodeManager"

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_ENABLED [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] \
                                                                                stringByAppendingString:@"_passcode_enabled"]

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_INTERVAL [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] \
                                                                                      stringByAppendingString:@"_passcode_time_interval"]

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_LAST_SEEN [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] \
                                                                                       stringByAppendingString:@"_passcode_time_last_seen"]

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] \
                                                                                 stringByAppendingString:@"_passcode"]

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TOUCHID_ENABLED [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] \
                                                                                        stringByAppendingString:@"_touchid_enabled"]

#define DH_PASSCODE_DELIMITER @"-"

typedef void (^DHPasscodeManagerCompletionBlock)(BOOL success, NSError *error);

@interface DHPasscodeManager : NSObject

// Style
@property (nonatomic, readonly) DHPasscodeManagerStyle *style;
@property (nonatomic) UIModalTransitionStyle modalTransitionStyle;
@property (nonatomic) BOOL animatePresentationAndDismissal;

// TouchID
@property (nonatomic, readonly) BOOL touchIDSupported;
@property (nonatomic) BOOL touchIDEnabled;

// Behavior

/**
 * Enable/Disable automatic passcode protection when the app meets the behavior requirements dictated below
 *
 * Defaults to NO
 */
@property (nonatomic) BOOL passcodeEnabled;

/**
 *  Time (in seconds) an app is allowed to be inactive before requiring a passcode
 *
 *  Defaults to 60 seconds
 */
@property (nonatomic) NSTimeInterval passcodeTimeInternal;

+ (instancetype)sharedInstance;

// Convenience method - could be used for securing sections of an application (versus the whole app)
// This method will be used internally by DHPasscodeManager for bringing up the passcode when appropriate, based on behavior settings

- (void)verifyPasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock;

// Passcode management methods (Add / Change / Remove)

- (void)createPasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock;

- (void)changePasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock;

- (void)disablePasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                           animated:(BOOL)animated
                                    completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock;

@end
