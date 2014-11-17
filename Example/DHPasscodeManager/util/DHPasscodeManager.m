//
//  DHPasscodeManager.m
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeManager.h"

static DHPasscodeManager *_sharedInstance;

@interface DHPasscodeManager ()
@property (nonatomic, strong) DHPasscodeViewController *passcodeViewController;
@end

@implementation DHPasscodeManager

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
        self.style = [[DHPasscodeManagerStyle alloc] init];
        
        self.passcodeViewController = [[DHPasscodeViewController alloc] init];
        self.passcodeViewController.style = self.style;
    }
    
    return self;
}

- (void)setStyle:(DHPasscodeManagerStyle *)style {
    _style = style;
    self.passcodeViewController.style = style;
}

- (void)verifyPasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeVerify;
    
    [presentingViewController presentViewController:self.passcodeViewController
                                           animated:animated
                                         completion:^{
                                             
                                         }];
}

- (void)createPasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {

    self.passcodeViewController.type = DHPasscodeViewControllerTypeCreateNew;
    
    [presentingViewController presentViewController:self.passcodeViewController
                                           animated:animated
                                         completion:^{
                                             
                                         }];
}

- (void)changePasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeChangeExisting;
    
    [presentingViewController presentViewController:self.passcodeViewController
                                           animated:animated
                                         completion:^{
                                             
                                         }];
}

- (void)disablePasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                           animated:(BOOL)animated
                                    completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock {
    
    self.passcodeViewController.type = DHPasscodeViewControllerTypeRemove;
    
    [presentingViewController presentViewController:self.passcodeViewController
                                           animated:animated
                                         completion:^{
                                             
                                         }];
}

@end
