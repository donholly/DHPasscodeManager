//
//  DHPasscodeManager.m
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeManager.h"

#define DH_PASSCODE_ENABLED_DEFAULT @NO
#define DH_PASSCODE_TOUCHID_ENABLED_DEFAULT @YES
#define DH_PASSCODE_TIME_INTERVAL_DEFAULT @(60)
#define DH_PASSCODE_ANIMATION_DURATION_DEFAULT 0.5f

static DHPasscodeManager *_sharedInstance;

@interface DHPasscodeManager ()
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) DHPasscodeViewController *passcodeViewController;
@property (nonatomic) BOOL currentlyAuthenticated;
@property (nonatomic) NSString *previousApplicationState;
@property (readonly) NSString *passcode;
@end

static NSDateFormatter *_lastActiveDateFormatter;

@implementation DHPasscodeManager

@dynamic passcodeEnabled;
@dynamic passcodeTimeInterval;
@dynamic touchIDEnabled;

- (void)dealloc {
    [self removeApplicationObservers];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    if (_sharedInstance != nil) {
        return nil;
    }
    
    if ((self = [super init])) {
        
        self.window = [[UIWindow alloc] initWithFrame:CGRectZero];
        self.window.windowLevel = UIWindowLevelStatusBar + 2; // +2 to go above MTStatusBarOverlay (this may not be a good idea)
        
        self.style = [[DHPasscodeManagerStyle alloc] init];
        
        self.passcodeViewController = [[DHPasscodeViewController alloc] initWithManager:self];
        self.passcodeViewController.style = self.style;
        self.passcodeViewController.passcodeManager = self;
        
        _lastActiveDateFormatter = [NSDateFormatter new];
        _lastActiveDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [_lastActiveDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        
        [self addApplicationObservers];
    }
    
    return self;
}

- (void)addApplicationObservers {
    // make sure we only listen for these once
    [self removeApplicationObservers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationNotification:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationNotification:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)removeApplicationObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidFinishLaunchingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
}

- (void)handleApplicationNotification:(NSNotification *)notification {
    
    // Fresh launch
    if ([notification.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        [self handleApplicationLock];
    }
    // Back from background
    else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self handleApplicationLock];
    }
    // Sent to background
    else if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        if (self.currentlyAuthenticated) {
            [self markLastActive:[NSDate date]];
        }
    }
    // Will resign active state
    else if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
        [self handleApplicationActiveStateChange:NO];
    }
    // Did re-gain active state
    else if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self handleApplicationActiveStateChange:YES];
    }
    // About to terminate (forced closed by system or user)
    else if ([notification.name isEqualToString:UIApplicationWillTerminateNotification]) {
        // Mark last active the minimum time ago it would require a passcode for next launch
        [self markLastActive:[[NSDate date] dateByAddingTimeInterval:-self.passcodeTimeInterval]];
    }
    
    self.previousApplicationState = notification.name;
}

- (void)handleApplicationLock {
    
    if ([self shouldRequirePasscode]) {
        self.currentlyAuthenticated = NO;
        [self authenticateUserAnimated:self.animatePresentationAndDismissal
                       completionBlock:^(BOOL success, NSError *error) {
                           
                       }];
    } else {
        if (self.currentlyAuthenticated) {
            [self dismissPasscodeWindowAnimated:self.animatePresentationAndDismissal];
        }
    }
}

- (void)handleApplicationActiveStateChange:(BOOL)currentlyActive {
    
    if (currentlyActive) {
        if ([self.previousApplicationState isEqualToString:UIApplicationWillResignActiveNotification] && self.currentlyAuthenticated) {
            [self dismissPasscodeWindowAnimated:self.animatePresentationAndDismissal];
        }
    } else {
        if (![self.previousApplicationState isEqualToString:UIApplicationDidBecomeActiveNotification] || self.currentlyAuthenticated) {
            [self showApplicationCovers:self.animatePresentationAndDismissal
                        completionBlock:^(BOOL success, NSError *error) {
                            
                        }];
        }
    }
}

- (BOOL)shouldRequirePasscode {
    
    NSDate *lastActive = self.lastActiveDate;
    
    BOOL passcodeEnabled = self.passcodeEnabled;
    
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSinceDate:lastActive];
    BOOL timeRequirement = (currentInterval >= self.passcodeTimeInterval);
    
    return passcodeEnabled && timeRequirement;
}

- (NSDate *)lastActiveDate {
    NSError *error;
    NSString *value = [SAMKeychain passwordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                              account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_LAST_SEEN
                                                error:&error];
    
    if (error && error.code != errSecItemNotFound) {
        NSLog(@"Error determining passcode interval: %@", error);
    }
    
    if (!value) {
        value = [NSString stringWithFormat:@"%@", [_lastActiveDateFormatter stringFromDate:[NSDate date]]];
    }
    
    NSDate *date = [_lastActiveDateFormatter dateFromString:value];
    
    return date;
}

- (void)markLastActive:(NSDate *)date {
    NSError *error;
    NSString *lastSeenDate = [NSString stringWithFormat:@"%@", [_lastActiveDateFormatter stringFromDate:date]];
    BOOL success = [SAMKeychain setPassword:lastSeenDate
                                 forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                    account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_LAST_SEEN
                                      error:&error];
    
    if (!success || (error && error.code != errSecItemNotFound)) {
        NSLog(@"Error setting last seen date: %@", error);
    }
}

#pragma mark - Setters / Getters -

- (void)setCurrentlyAuthenticated:(BOOL)currentlyAuthenticated {
    _currentlyAuthenticated = currentlyAuthenticated;
    
    if (currentlyAuthenticated) {
        [self markLastActive:[NSDate date]];
    }
}

- (void)setStyle:(DHPasscodeManagerStyle *)style {
    _style = style;
    self.passcodeViewController.style = style;
}

- (BOOL)touchIDSupported {
    
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        NSError *error;
        LAContext *context = [[LAContext alloc] init];
        
        BOOL canEvaluate = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                                error:&error];
        return canEvaluate;
    } else {
        return NO;
    }
#endif
    
    return NO;
}

- (BOOL)touchIDEnabled {
    NSError *error;
    NSString *value = [SAMKeychain passwordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                              account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TOUCHID_ENABLED
                                                error:&error];
    
    if (error && [error code] != errSecItemNotFound) {
        NSLog(@"Error determining if TouchID is enabled: %@", error);
    }
    
    if (!value) {
        value = [NSString stringWithFormat:@"%@", DH_PASSCODE_TOUCHID_ENABLED_DEFAULT];
    }
    
    BOOL enabled = [value boolValue] && [self touchIDSupported];
    
    return enabled;
}

- (void)setTouchIDEnabled:(BOOL)touchIDEnabled {
    NSError *error;
    BOOL success = [SAMKeychain setPassword:[NSString stringWithFormat:@"%@", @(touchIDEnabled)]
                                 forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                    account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TOUCHID_ENABLED
                                      error:&error];
    
    if (!success || error) {
        NSLog(@"Error setting TouchID to enabled/disabled: %@", error);
    }
}

- (BOOL)passcodeEnabled {
    NSError *error;
    NSString *value = [SAMKeychain passwordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                              account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_ENABLED
                                                error:&error];
    
    if (error && [error code] != errSecItemNotFound) {
        NSLog(@"Error determining if passcode is enabled: %@", error);
    }
    
    if (!value) {
        value = [NSString stringWithFormat:@"%@", DH_PASSCODE_ENABLED_DEFAULT];
    }
    
    BOOL enabled = [value boolValue] && [self passcodeExists];
    
    return enabled;
}

- (void)setPasscodeEnabled:(BOOL)passcodeEnabled {
    NSError *error;
    BOOL success = [SAMKeychain setPassword:[NSString stringWithFormat:@"%@", @(passcodeEnabled)]
                                 forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                    account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_ENABLED
                                      error:&error];
    
    if (success && !passcodeEnabled) {
        success = [self deletePasscode:&error];
    }
    
    if (!success || error) {
        NSLog(@"Error setting passcode enabled/disabled: %@", error);
    }
}

- (NSTimeInterval)passcodeTimeInterval {
    NSError *error;
    NSString *value = [SAMKeychain passwordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                              account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_INTERVAL
                                                error:&error];
    
    if (error && error.code != errSecItemNotFound) {
        NSLog(@"Error determining passcode interval: %@", error);
    }
    
    if (!value) {
        value = [NSString stringWithFormat:@"%@", DH_PASSCODE_TIME_INTERVAL_DEFAULT];
    }
    
    return [value doubleValue];
}

- (void)setPasscodeTimeInterval:(NSTimeInterval)passcodeTimeinterval {
    NSError *error;
    BOOL success = [SAMKeychain setPassword:[NSString stringWithFormat:@"%@", @(passcodeTimeinterval)]
                                 forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                    account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_INTERVAL
                                      error:&error];
    
    if (!success || error) {
        NSLog(@"Error setting passcode time interval: %@", error);
    }
}

#pragma mark - Passcode Management -

// For internal use only!
- (NSString*)passcode {
    NSError *error = nil;
    NSString *storedPasscode = [SAMKeychain passwordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                                       account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE
                                                         error:&error];
    
    if (error && [error code] != errSecItemNotFound) {
        NSLog(@"Error fetching passcode: %@", [error localizedDescription]);
    }
    
    return storedPasscode;
}

- (NSString*)stringifyPasscode:(Passcode*)passcode {
    return [passcode componentsJoinedByString:DH_PASSCODE_DELIMITER];
}

- (BOOL)passcodeExists {
    NSString* passcode = self.passcode;
    return passcode != nil && passcode.length > 0;
}

- (BOOL)validatePasscode:(Passcode *)passcode {
    return [[self stringifyPasscode: passcode] isEqualToString:self.passcode];
}

- (BOOL)setPasscode:(Passcode *)passcode error:(NSError *__autoreleasing *)errorRef {
    NSLog(@"Setting passcode");
    
    BOOL created = [SAMKeychain setPassword:[self stringifyPasscode: passcode]
                                 forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                    account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE
                                      error:errorRef];
    
    if (*errorRef) {
        NSLog(@"Error setting passcode: %@", *errorRef);
    }
    
    return created;
}

- (BOOL)deletePasscode:(NSError**)errorRef {
    NSLog(@"Disabling passcode");
    
    BOOL removed = [SAMKeychain deletePasswordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                                 account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE
                                                   error:errorRef];
    
    if (*errorRef) {
        NSLog(@"Error removing passcode: %@", *errorRef);
    }
    
    return removed;
}

#pragma mark - Passcode UI Presentation -

- (void)showApplicationCovers:(BOOL)animated
              completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    if (!self.passcodeEnabled) {
        if (completionBlock) {
            completionBlock(NO, [NSError errorWithDomain:@"DHPasscodeErrorDomain"
                                                    code:0
                                                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"A passcode is not currently set", @"A passcode is not currently set")}]);
        }
        return;
    }
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeApplicationCovers;
    
    [self presentPasscodeWindowAnimated:animated];
    
    if (completionBlock) {
        completionBlock(YES, nil);
    }
}

- (void)authenticateUserAnimated:(BOOL)animated
                 completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    if (!self.passcodeEnabled) {
        if (completionBlock) {
            completionBlock(NO, [NSError errorWithDomain:@"DHPasscodeErrorDomain"
                                                    code:0
                                                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"A passcode is not currently set", @"A passcode is not currently set")}]);
        }
        return;
    }
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeAuthenticate;
    
    @weakify(self)
    self.passcodeViewController.completionBlock = ^(DHPasscodeViewController *viewController, BOOL success, NSError *error) {
        @strongify(self)
        
        self.currentlyAuthenticated = success;
        
        if (success || (!success && !error)) {
            [self dismissPasscodeWindowAnimated:animated];
        }
        
        if (completionBlock) {
            completionBlock(success, error);
        }
    };
    
    [self presentPasscodeWindowAnimated:animated];
}

- (void)createPasscodeAnimated:(BOOL)animated
               completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeCreateNew;
    
    @weakify(self)
    self.passcodeViewController.completionBlock = ^(DHPasscodeViewController *viewController, BOOL success, NSError *error) {
        @strongify(self)
        
        self.currentlyAuthenticated = success;
        
        if (success || (!success && !error)) {
            [self dismissPasscodeWindowAnimated:animated];
        }
        
        if (completionBlock) {
            completionBlock(success, error);
        }
    };
    
    [self presentPasscodeWindowAnimated:animated];
}

- (void)changePasscodeAnimated:(BOOL)animated
               completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    // Make sure we have a password set before we attempt to change it
    if (!self.passcodeEnabled) {
        if (completionBlock) {
            completionBlock(NO, [NSError errorWithDomain:@"DHPasscodeErrorDomain"
                                                    code:0
                                                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"A passcode is not currently set", @"A passcode is not currently set")}]);
        }
        return;
    }
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeChangeExisting;
    
    @weakify(self)
    self.passcodeViewController.completionBlock = ^(DHPasscodeViewController *viewController, BOOL success, NSError *error) {
        @strongify(self)
        
        self.currentlyAuthenticated = success;
        
        if (success || (!success && !error)) {
            [self dismissPasscodeWindowAnimated:animated];
        }
        
        if (completionBlock) {
            completionBlock(success, error);
        }
    };
    
    [self presentPasscodeWindowAnimated:animated];
}

- (void)disablePasscodeAnimated:(BOOL)animated
                completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    // Make sure we have a passcode set before we attempt to disable it
    if (!self.passcodeEnabled) {
        if (completionBlock) {
            completionBlock(NO, [NSError errorWithDomain:@"DHPasscodeErrorDomain"
                                                    code:0
                                                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"A passcode is not currently set", @"A passcode is not currently set")}]);
        }
        return;
    }
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeRemove;
    
    @weakify(self)
    self.passcodeViewController.completionBlock = ^(DHPasscodeViewController *viewController, BOOL success, NSError *error) {
        @strongify(self)
        
        self.currentlyAuthenticated = success;
        
        if (success || (!success && !error)) {
            [self dismissPasscodeWindowAnimated:animated];
        }
        
        if (completionBlock) {
            completionBlock(success, error);
        }
    };
    
    [self presentPasscodeWindowAnimated:animated];
}

#pragma mark - Present / Dismiss Passcode Window -

- (void)presentPasscodeWindowAnimated:(BOOL)animated {
    
    CGFloat animationDuration = animated ? DH_PASSCODE_ANIMATION_DURATION_DEFAULT : 0;
    
    self.window.frame = [[UIScreen mainScreen] bounds];
    [self.window setRootViewController:self.passcodeViewController];
    self.window.alpha = self.window.hidden ? 0.0f : self.window.alpha;
    self.window.hidden = NO;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.window.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.passcodeViewController viewControllerWasDisplayed];
                     }];
}

- (void)dismissPasscodeWindowAnimated:(BOOL)animated {
    
    CGFloat animationDuration = animated ? DH_PASSCODE_ANIMATION_DURATION_DEFAULT : 0;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.window.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         self.window.hidden = YES;
                     }];
}

#pragma mark - Present Touch ID Challenge -

- (void)presentTouchIDChallengeWithReason:(NSString*)reason completionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    LAContext *context = [[LAContext alloc] init];
    
    NSError *authError = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:reason
                          reply:^(BOOL success, NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (completionBlock) {
                                      completionBlock(success, error);
                                  }
                              });
                          }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(NO, authError);
            }
        });
    }
    
#else
    if (completionBlock) {
        completionBlock(NO);
    }
#endif
}

@end
