//
//  DHPasscodeManager.h
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeViewController.h"

#import "DHPasscodeManagerStyle.h"

#import <SAMKeychain/SAMKeychain.h>

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#import <LocalAuthentication/LocalAuthentication.h>
#endif

#define DH_PASSCODE_KEYCHAIN_SERVICE_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey]

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_ENABLED                                 @"DHPasscodeManager_passcode_enabled"

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_INTERVAL                           @"DHPasscodeManager_passcode_time_interval"

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_LAST_SEEN                          @"DHPasscodeManager_passcode_time_last_seen"

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE                                @"DHPasscodeManager_passcode"

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TOUCHID_ENABLED                         @"DHPasscodeManager_touchid_enabled"

// Changing this would break things right now
// TODO: support variable length passcodes one day?
#define DH_PASSCODE_LENGTH           4
#define DH_PASSCODE_DELIMITER        @"-"

typedef void (^DHPasscodeManagerCompletionBlock)(BOOL success, NSError *error);
typedef NSArray<NSNumber*> Passcode;

@interface DHPasscodeManager : NSObject

// Style
@property (nonatomic, readonly) DHPasscodeManagerStyle *style;
@property (nonatomic) BOOL animatePresentationAndDismissal;

// TouchID

@property (nonatomic, readonly) BOOL touchIDSupported;

/**
 * Enable/Disable TouchID support (is dependent on touchIDSupported)
 *
 * Defaults to YES
 */

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
@property (nonatomic) NSTimeInterval passcodeTimeInterval;

+ (instancetype)sharedInstance;

// Convenience method - could be used for securing sections of an application (versus the whole app)
// This method will be used internally by DHPasscodeManager for bringing up the passcode when appropriate, based on behavior settings

- (void)authenticateUserAnimated:(BOOL)animated
                 completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock;

// Passcode management
@property (readonly) BOOL passcodeExists;
- (BOOL)validatePasscode:(Passcode*)passcode;
- (BOOL)setPasscode:(Passcode*)passcode error:(NSError**)error;
- (BOOL)deletePasscode:(NSError**)error;


// Display UI for passcode management

- (void)createPasscodeAnimated:(BOOL)animated
               completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock;

- (void)changePasscodeAnimated:(BOOL)animated
               completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock;

- (void)disablePasscodeAnimated:(BOOL)animated
                completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock;

@end
