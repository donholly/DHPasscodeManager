//
//  DHPasscodeViewController.h
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "DHPasscodeManagerStyle.h"

@class DHPasscodeManager;

typedef NS_ENUM(NSUInteger, DHPasscodeViewControllerType) {
    DHPasscodeViewControllerTypeAuthenticate,
    DHPasscodeViewControllerTypeCreateNew,
    DHPasscodeViewControllerTypeChangeExisting,
    DHPasscodeViewControllerTypeRemove
};

@class DHPasscodeViewController;

typedef void (^DHPasscodeManagerViewControllerCompletionBlock)(DHPasscodeViewController *viewController, BOOL success, NSError *error);

@interface DHPasscodeViewController : UIViewController

@property (nonatomic, weak) DHPasscodeManager *passcodeManager;

@property (nonatomic) DHPasscodeViewControllerType type;

@property (nonatomic, copy) DHPasscodeManagerViewControllerCompletionBlock completionBlock;

@property (nonatomic, weak) DHPasscodeManagerStyle *style;

@end
