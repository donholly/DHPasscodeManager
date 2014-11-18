//
//  DHPasscodeManager.m
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeManager.h"

#define DH_PASSCODE_ENABLED_DEFAULT @NO
#define DH_PASSCODE_TIME_INTERVAL_DEFAULT @(60)

static DHPasscodeManager *_sharedInstance;

@interface DHPasscodeManager ()
@property (nonatomic, strong) DHPasscodeViewController *passcodeViewController;
@end

static NSDateFormatter *_lastSeenDateFormatter;

@implementation DHPasscodeManager

@dynamic modalTransitionStyle;
@dynamic passcodeEnabled;
@dynamic passcodeTimeInternal;

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

        self.touchIDEnabled = YES;
        
        self.style = [[DHPasscodeManagerStyle alloc] init];
        
        self.passcodeViewController = [[DHPasscodeViewController alloc] init];
        self.passcodeViewController.style = self.style;
        self.passcodeViewController.passcodeManager = self;
        
        _lastSeenDateFormatter = [NSDateFormatter new];
        _lastSeenDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [_lastSeenDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        
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
    
    void (^handleApplicationLock)() = ^() {
        if ([self shouldShowPasscode]) {
            // We do this on the next runloop to avoid:
            // Unbalanced calls to begin/end appearance transitions for <UIViewController>
            dispatch_async(dispatch_get_main_queue(), ^{
                [self verifyPasscodeWithPresentingViewController:[self rootViewController]
                                                        animated:self.animatePresentationAndDismissal
                                                 completionBlock:^(BOOL success, NSError *error) {
                                                     
                                                 }];
            });
        }
    };
    
    // Fresh launch
    if ([notification.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        handleApplicationLock();
    }
    // Back from background
    else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        handleApplicationLock();
    }
    // Application was sent to the background
    else if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self markLastSeenNow];
    }
    // Application was forced closed (by system or user)
    else if ([notification.name isEqualToString:UIApplicationWillTerminateNotification]) {
        [self markLastSeenNow];
    }
}

- (BOOL)shouldShowPasscode {
    
    NSTimeInterval timeInterval = self.passcodeTimeInternal;
    
    NSDate *lastSeen = self.lastSeenDate;
    
    BOOL timeRequirement = ([[NSDate date] timeIntervalSinceDate:lastSeen] > timeInterval);
    
    return self.passcodeEnabled && timeRequirement;
}

- (NSDate *)lastSeenDate {
    NSError *error;
    NSString *value = [SSKeychain passwordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                             account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_LAST_SEEN
                                               error:&error];
    
    if (error && error.code != errSecItemNotFound) {
        NSLog(@"Error determining passcode interval: %@", error);
    }
    
    if (!value) {
        value = [NSString stringWithFormat:@"%@", [_lastSeenDateFormatter stringFromDate:[NSDate date]]];
    }
    
    NSDate *date = [_lastSeenDateFormatter dateFromString:value];
    
    return date;
}

- (void)markLastSeenNow {
    NSError *error;
    NSString *lastSeenDate = [NSString stringWithFormat:@"%@", [_lastSeenDateFormatter stringFromDate:[NSDate date]]];
    BOOL success = [SSKeychain setPassword:lastSeenDate
                                forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                   account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_LAST_SEEN
                                     error:&error];
    
    if (!success || (error && error.code != errSecItemNotFound)) {
        NSLog(@"Error setting last seen date: %@", error);
    }
}

#pragma mark - Setters / Getters -

- (UIViewController *)rootViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    
    return rootViewController;
}

- (void)setStyle:(DHPasscodeManagerStyle *)style {
    _style = style;
    self.passcodeViewController.style = style;
}

- (void)setModalTransitionStyle:(UIModalTransitionStyle)modalTransitionStyle {
    self.passcodeViewController.modalTransitionStyle = modalTransitionStyle;
}

- (UIModalTransitionStyle)modalTransitionStyle {
    return self.passcodeViewController.modalTransitionStyle;
}

- (BOOL)touchIDSupported {
    
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        LAContext *context = [[LAContext alloc] init];
        NSError *error;
        
        return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                    error:&error];
    } else {
        return NO;
    }
#endif
    
    return NO;
}

- (BOOL)touchIDEnabled {
    return _touchIDEnabled && self.touchIDSupported;
}

- (BOOL)passcodeEnabled {
    NSError *error;
    NSString *value = [SSKeychain passwordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                             account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_ENABLED
                                               error:&error];
    
    if (error) {
        NSLog(@"Error determining if passcode is enabled: %@", error);
    }
    
    if (!value) {
        value = [NSString stringWithFormat:@"%@", DH_PASSCODE_ENABLED_DEFAULT];
    }
    
    return [value boolValue];
}

- (void)setPasscodeEnabled:(BOOL)passcodeEnabled {
    NSError *error;
    BOOL success = [SSKeychain setPassword:[NSString stringWithFormat:@"%@", @(passcodeEnabled)]
                                forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                   account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_ENABLED
                                     error:&error];
    
    if (!success || error) {
        NSLog(@"Error setting passcode enabled/disabled: %@", error);
    }
}

- (NSTimeInterval)passcodeTimeInternal {
    NSError *error;
    NSString *value = [SSKeychain passwordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
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

- (void)setPasscodeTimeInternal:(NSTimeInterval)passcodeTimeinternal {
    NSError *error;
    BOOL success = [SSKeychain setPassword:[NSString stringWithFormat:@"%@", @(passcodeTimeinternal)]
                                forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                   account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_TIME_INTERVAL
                                     error:&error];
    
    if (!success || error) {
        NSLog(@"Error setting passcode time interval: %@", error);
    }
}

#pragma mark - Passcode Manipulation -

- (void)verifyPasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeAuthenticate;
    
    @weakify(self)
    self.passcodeViewController.completionBlock = ^(DHPasscodeViewController *viewController, BOOL success, NSError *error) {
        @strongify(self)
        
        if (success || (!success && !error)) {
            [self.passcodeViewController dismissViewControllerAnimated:animated completion:^{
                
            }];
        }
        
        if (completionBlock) {
            completionBlock(success, error);
        }
    };
    
    [presentingViewController presentViewController:self.passcodeViewController
                                           animated:animated
                                         completion:^{
                                             
                                         }];
}

- (void)createPasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {

    self.passcodeViewController.type = DHPasscodeViewControllerTypeCreateNew;
    
    @weakify(self)
    self.passcodeViewController.completionBlock = ^(DHPasscodeViewController *viewController, BOOL success, NSError *error) {
        @strongify(self)
        
        if (success || (!success && !error)) {
            [self.passcodeViewController dismissViewControllerAnimated:animated completion:^{
                
            }];
        }
        
        if (completionBlock) {
            completionBlock(success, error);
        }
    };
    
    [presentingViewController presentViewController:self.passcodeViewController
                                           animated:animated
                                         completion:^{
                                             
                                         }];
}

- (void)changePasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeChangeExisting;
    
    @weakify(self)
    self.passcodeViewController.completionBlock = ^(DHPasscodeViewController *viewController, BOOL success, NSError *error) {
        @strongify(self)
        
        if (success || (!success && !error)) {
            [self.passcodeViewController dismissViewControllerAnimated:animated completion:^{
                
            }];
        }
        
        if (completionBlock) {
            completionBlock(success, error);
        }
    };
    
    [presentingViewController presentViewController:self.passcodeViewController
                                           animated:animated
                                         completion:^{
                                             
                                         }];
}

- (void)disablePasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                           animated:(BOOL)animated
                                    completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeRemove;
    
    @weakify(self)
    self.passcodeViewController.completionBlock = ^(DHPasscodeViewController *viewController, BOOL success, NSError *error) {
        @strongify(self)
        
        if (success || (!success && !error)) {
            [self.passcodeViewController dismissViewControllerAnimated:animated completion:^{
                
            }];
        }
        
        if (completionBlock) {
            completionBlock(success, error);
        }
    };
    
    [presentingViewController presentViewController:self.passcodeViewController
                                           animated:animated
                                         completion:^{
                                             
                                         }];
}

@end
