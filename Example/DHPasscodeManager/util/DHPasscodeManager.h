//
//  DHPasscodeManager.h
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeViewController.h"

#import "DHPasscodeManagerStyle.h"

typedef void (^DHPasscodeManagerCompletionBlock)(BOOL success, NSError *error);

@interface DHPasscodeManager : NSObject

@property (nonatomic, readonly) DHPasscodeManagerStyle *style;

+ (instancetype)sharedInstance;

- (void)verifyPasscodeWithPresentingViewController:(UIViewController *)presentingViewController
                                          animated:(BOOL)animated
                                   completionBlock:(DHPasscodeManagerCompletionBlock)completionBlock;

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
