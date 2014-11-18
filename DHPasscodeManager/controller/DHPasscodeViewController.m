//
//  DHPasscodeViewController.m
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeViewController.h"

#import "DHPasscodeManager.h"
#import "DHPasscodeDotView.h"
#import "DHPasscodeButton.h"

#import <AudioToolbox/AudioServices.h>

#define DH_PASSCODE_BUTTON_SIZE 60.0f
#define DH_PASSCODE_BUTTON_SPACING_X 25.0f
#define DH_PASSCODE_BUTTON_SPACING_Y 15.0f

#define DH_PASSCODE_DOT_SIZE 10.0f
#define DH_PASSCODE_DOT_SPACING 15.0f

#define DH_PASSCODE_SPACING 10.0f

#define DH_PASSCODE_DELIMITER @"-"

#define DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] stringByAppendingString:@"_passcode"]

// Changing this would break things right now
// TODO: support variable length passcodes one day?
#define DH_PASSCODE_LENGTH 4

@interface DHPasscodeViewController ()
@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UILabel *instructionsLabel;

@property (nonatomic, strong) NSMutableOrderedSet *dotViews;
@property (nonatomic, strong) DHPasscodeDotView *dotView0;
@property (nonatomic, strong) DHPasscodeDotView *dotView1;
@property (nonatomic, strong) DHPasscodeDotView *dotView2;
@property (nonatomic, strong) DHPasscodeDotView *dotView3;

@property (nonatomic, strong) NSMutableOrderedSet *passcodeButtons;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton0;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton1;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton2;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton3;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton4;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton5;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton6;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton7;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton8;
@property (nonatomic, strong) DHPasscodeButton *passcodeButton9;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSMutableArray *firstInput;
@property (nonatomic, strong) NSMutableArray *secondInput;
@property (nonatomic, strong) NSMutableArray *thirdInput;

@end

@implementation DHPasscodeViewController

- (void)dealloc {
    [self removeStyleObservers];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        // default to a verify passcode
        self.type = DHPasscodeViewControllerTypeAuthenticate;
        
        self.firstInput = @[].mutableCopy;
        self.secondInput = @[].mutableCopy;
        self.thirdInput = @[].mutableCopy;
        
        self.dotViews = [NSMutableOrderedSet orderedSet];
        self.passcodeButtons = [NSMutableOrderedSet orderedSet];
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)loadView {
    [super loadView];
    
    // Logo
    self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.logoImageView];
    
    // Instructions
    self.instructionsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.instructionsLabel.numberOfLines = 0;
    self.instructionsLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionsLabel.text = @"";
    [self.view addSubview:self.instructionsLabel];
    
    // Dots
    self.dotView0 = [[DHPasscodeDotView alloc] initWithFrame:CGRectZero];
    [self.dotViews addObject:self.dotView0];
    [self.view addSubview:self.dotView0];
    
    self.dotView1 = [[DHPasscodeDotView alloc] initWithFrame:CGRectZero];
    [self.dotViews addObject:self.dotView1];
    [self.view addSubview:self.dotView1];
    
    self.dotView2 = [[DHPasscodeDotView alloc] initWithFrame:CGRectZero];
    [self.dotViews addObject:self.dotView2];
    [self.view addSubview:self.dotView2];
    
    self.dotView3 = [[DHPasscodeDotView alloc] initWithFrame:CGRectZero];
    [self.dotViews addObject:self.dotView3];
    [self.view addSubview:self.dotView3];
    
    // Buttons
    self.passcodeButton0 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(0)];
    [self.passcodeButtons addObject:self.passcodeButton0];
    [self.view addSubview:self.passcodeButton0];
    
    self.passcodeButton1 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(1)];
    [self.passcodeButtons addObject:self.passcodeButton1];
    [self.view addSubview:self.passcodeButton1];
    
    self.passcodeButton2 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(2)];
    [self.passcodeButtons addObject:self.passcodeButton2];
    [self.view addSubview:self.passcodeButton2];
    
    self.passcodeButton3 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(3)];
    [self.passcodeButtons addObject:self.passcodeButton3];
    [self.view addSubview:self.passcodeButton3];
    
    self.passcodeButton4 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(4)];
    [self.passcodeButtons addObject:self.passcodeButton4];
    [self.view addSubview:self.passcodeButton4];
    
    self.passcodeButton5 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(5)];
    [self.passcodeButtons addObject:self.passcodeButton5];
    [self.view addSubview:self.passcodeButton5];
    
    self.passcodeButton6 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(6)];
    [self.passcodeButtons addObject:self.passcodeButton6];
    [self.view addSubview:self.passcodeButton6];
    
    self.passcodeButton7 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(7)];
    [self.passcodeButtons addObject:self.passcodeButton7];
    [self.view addSubview:self.passcodeButton7];
    
    self.passcodeButton8 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(8)];
    [self.passcodeButtons addObject:self.passcodeButton8];
    [self.view addSubview:self.passcodeButton8];
    
    self.passcodeButton9 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(9)];
    [self.passcodeButtons addObject:self.passcodeButton9];
    [self.view addSubview:self.passcodeButton9];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.cancelButton];
    
    [self setupSignals];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self resetInput];
    
    if (self.passcodeManager.touchIDEnabled) {
        [self presentTouchIdWithCompletionBlock:^(BOOL success, NSError *error) {
            
            if (self.completionBlock) {
                self.completionBlock(self, success, error);
            }
            
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat spaceForButtons = (DH_PASSCODE_BUTTON_SIZE * 4) + (DH_PASSCODE_BUTTON_SPACING_Y * 4);
    CGFloat spaceForDots = DH_PASSCODE_DOT_SIZE;
    CGSize instructionsSize = [self.instructionsLabel sizeThatFits:CGSizeMake(self.view.frame.size.width - (2 * DH_PASSCODE_SPACING), 100)];
    CGFloat spacing = DH_PASSCODE_SPACING * 5;
    
    CGSize imageSize = self.logoImageView.image.size;
    
    CGFloat maxLogoHeight = MIN(self.view.frame.size.height - (spaceForButtons + spaceForDots + instructionsSize.height + spacing),
                                imageSize.height);
    
    // Logo
    self.logoImageView.frame = CGRectMake(DH_PASSCODE_SPACING,
                                          DH_PASSCODE_SPACING * 2,
                                          self.view.frame.size.width - (2 * DH_PASSCODE_SPACING),
                                          maxLogoHeight);
    
    // Instructions
    CGFloat instructionsPadding = ((self.view.frame.size.height - CGRectGetMaxY(self.logoImageView.frame) - DH_PASSCODE_SPACING)/2 - spaceForButtons/2 - instructionsSize.height/2) / 2;
    CGFloat instructionsY = CGRectGetMaxY(self.logoImageView.frame) + DH_PASSCODE_SPACING + instructionsPadding;
    self.instructionsLabel.frame = CGRectMake(self.view.frame.size.width/2 - instructionsSize.width/2,
                                              instructionsY,
                                              instructionsSize.width,
                                              instructionsSize.height);
    
    // Dots
    self.dotView0.frame = CGRectMake(self.view.frame.size.width/2 - (2 * DH_PASSCODE_DOT_SIZE) - (1.5 * DH_PASSCODE_DOT_SPACING),
                                     CGRectGetMaxY(self.instructionsLabel.frame) + DH_PASSCODE_SPACING,
                                     DH_PASSCODE_DOT_SIZE,
                                     DH_PASSCODE_DOT_SIZE);

    self.dotView1.frame = CGRectMake(self.view.frame.size.width/2 - DH_PASSCODE_DOT_SIZE - (0.5 * DH_PASSCODE_DOT_SPACING),
                                     CGRectGetMaxY(self.instructionsLabel.frame) + DH_PASSCODE_SPACING,
                                     DH_PASSCODE_DOT_SIZE,
                                     DH_PASSCODE_DOT_SIZE);
    
    self.dotView2.frame = CGRectMake(self.view.frame.size.width/2 + (0.5 * DH_PASSCODE_DOT_SPACING),
                                     CGRectGetMaxY(self.instructionsLabel.frame) + DH_PASSCODE_SPACING,
                                     DH_PASSCODE_DOT_SIZE,
                                     DH_PASSCODE_DOT_SIZE);
    
    self.dotView3.frame = CGRectMake(self.view.frame.size.width/2 + DH_PASSCODE_DOT_SIZE + (1.5 * DH_PASSCODE_DOT_SPACING),
                                     CGRectGetMaxY(self.instructionsLabel.frame) + DH_PASSCODE_SPACING,
                                     DH_PASSCODE_DOT_SIZE,
                                     DH_PASSCODE_DOT_SIZE);
    
    // Layout the buttons

    // Middle column
    self.passcodeButton2.frame = CGRectMake(self.view.center.x - DH_PASSCODE_BUTTON_SIZE/2,
                                            CGRectGetMaxY(self.dotView0.frame) + instructionsPadding,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    self.passcodeButton5.frame = CGRectMake(self.view.center.x - DH_PASSCODE_BUTTON_SIZE/2,
                                            CGRectGetMaxY(self.passcodeButton2.frame) + DH_PASSCODE_BUTTON_SPACING_Y,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    self.passcodeButton8.frame = CGRectMake(self.view.center.x - DH_PASSCODE_BUTTON_SIZE/2,
                                            CGRectGetMaxY(self.passcodeButton5.frame) + DH_PASSCODE_BUTTON_SPACING_Y,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    self.passcodeButton0.frame = CGRectMake(self.view.center.x - DH_PASSCODE_BUTTON_SIZE/2,
                                            CGRectGetMaxY(self.passcodeButton8.frame) + DH_PASSCODE_BUTTON_SPACING_Y,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    
    // Left column
    self.passcodeButton1.frame = CGRectMake(CGRectGetMinX(self.passcodeButton2.frame) - DH_PASSCODE_BUTTON_SIZE - DH_PASSCODE_BUTTON_SPACING_X,
                                            self.passcodeButton2.frame.origin.y,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    self.passcodeButton4.frame = CGRectMake(CGRectGetMinX(self.passcodeButton5.frame) - DH_PASSCODE_BUTTON_SIZE - DH_PASSCODE_BUTTON_SPACING_X,
                                            self.passcodeButton5.frame.origin.y,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    self.passcodeButton7.frame = CGRectMake(CGRectGetMinX(self.passcodeButton8.frame) - DH_PASSCODE_BUTTON_SIZE - DH_PASSCODE_BUTTON_SPACING_X,
                                            self.passcodeButton8.frame.origin.y,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    
    // Right column
    self.passcodeButton3.frame = CGRectMake(CGRectGetMaxX(self.passcodeButton2.frame) + DH_PASSCODE_BUTTON_SPACING_X,
                                            self.passcodeButton2.frame.origin.y,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    self.passcodeButton6.frame = CGRectMake(CGRectGetMaxX(self.passcodeButton5.frame) + DH_PASSCODE_BUTTON_SPACING_X,
                                            self.passcodeButton5.frame.origin.y,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    self.passcodeButton9.frame = CGRectMake(CGRectGetMaxX(self.passcodeButton8.frame) + DH_PASSCODE_BUTTON_SPACING_X,
                                            self.passcodeButton8.frame.origin.y,
                                            DH_PASSCODE_BUTTON_SIZE,
                                            DH_PASSCODE_BUTTON_SIZE);
    
    // Cancel button
    self.cancelButton.frame = CGRectMake(CGRectGetMaxX(self.passcodeButton0.frame) + DH_PASSCODE_BUTTON_SPACING_X,
                                         self.passcodeButton0.frame.origin.y,
                                         DH_PASSCODE_BUTTON_SIZE,
                                         DH_PASSCODE_BUTTON_SIZE);
}

- (void)presentTouchIdWithCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    LAContext *context = [[LAContext alloc] init];
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:NSLocalizedString(@"Unlock Access", @"Unlock Access")
                      reply:^(BOOL success, NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (completionBlock) {
                                  completionBlock(success, error);
                              }
                          });
                      }];
#else
    if (completionBlock) {
        completionBlock(NO);
    }
#endif
}

- (void)setupSignals {

    @weakify(self)
    
    RACSignal *typeSignal = RACObserve(self, type);
    RACSignal *firstInputSignal = RACObserve(self, firstInput);
    RACSignal *secondInputSignal = RACObserve(self, secondInput);
    RACSignal *thirdInputSignal = RACObserve(self, thirdInput);
    
    RAC(self.instructionsLabel, text) =
    [[[RACSignal
       combineLatest:@[typeSignal, firstInputSignal, secondInputSignal, thirdInputSignal]
       reduce:^id (NSNumber *type, NSArray *firstInput, NSArray *secondInput, NSArray *thirdInput) {
           @strongify(self)
           
           if (type.integerValue != DHPasscodeViewControllerTypeCreateNew &&
               firstInput.count == DH_PASSCODE_LENGTH &&
               ![self passcodeEntryIsValid:firstInput]) {
               return NSLocalizedString(@"Invalid passcode", @"Invalid passcode");
           }
           
           switch (type.integerValue) {
               case DHPasscodeViewControllerTypeAuthenticate:
                   return self.instructionsLabel.text = NSLocalizedString(@"Enter your passcode", @"Enter your passcode");
               case DHPasscodeViewControllerTypeCreateNew: {
                   
                   if (firstInput.count == DH_PASSCODE_LENGTH) {
                       return NSLocalizedString(@"Re-enter the same passcode", @"Re-enter the same passcode");
                   } else {
                       return NSLocalizedString(@"Enter a new passcode", @"Enter a new passcode");
                   }
               }
               case DHPasscodeViewControllerTypeChangeExisting: {
                   
                   if (firstInput.count == DH_PASSCODE_LENGTH) {
                       if (secondInput.count == DH_PASSCODE_LENGTH) {
                           return NSLocalizedString(@"Re-enter the same passcode", @"Re-enter the same passcode");
                       } else {
                           return NSLocalizedString(@"Enter a new passcode", @"Enter a new passcode");
                       }
                   } else {
                       return NSLocalizedString(@"Enter your current passcode", @"Enter your current passcode");
                   }
               }
               case DHPasscodeViewControllerTypeRemove:
                   return NSLocalizedString(@"Enter your current passcode to disable", @"Enter your current passcode to disable");
               default:
                   NSLog(@"Unknown DHPasscodeViewControllerType: %@", type);
                   return nil;
           }
           
       }] doNext:^(id x) {
           dispatch_async(dispatch_get_main_queue(), ^{
               [self.view setNeedsLayout];
           });
       }] deliverOn:RACScheduler.mainThreadScheduler];
    
    
    
    [[RACSignal combineLatest:@[typeSignal, firstInputSignal, secondInputSignal, thirdInputSignal]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        
        NSMutableArray *currentInput = [self currentInput];
        
        if (currentInput.count > 0) {
            [self.cancelButton setTitle:NSLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
        } else {
            [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
        }
    }];
    
    [self.passcodeButtons enumerateObjectsUsingBlock:^(DHPasscodeButton *button, NSUInteger idx, BOOL *stop) {
        button.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
            @strongify(self)
            
            if (self.firstInput.count < DH_PASSCODE_LENGTH) {
                [[self mutableArrayValueForKey:@"firstInput"] addObject:@(button.tag)];
            } else if (self.secondInput.count < DH_PASSCODE_LENGTH) {
                [[self mutableArrayValueForKey:@"secondInput"] addObject:@(button.tag)];
            } else if (self.thirdInput.count < DH_PASSCODE_LENGTH) {
                [[self mutableArrayValueForKey:@"thirdInput"] addObject:@(button.tag)];
            }
            
            return [RACSignal empty];
        }];
    }];
    
    RAC(self.cancelButton, hidden) =
    [RACSignal combineLatest:@[typeSignal, firstInputSignal, secondInputSignal, thirdInputSignal] reduce:^id (NSNumber *type, NSArray *firstInput, NSArray *secondInput, NSArray *thirdInput) {
        
        if (type.integerValue == DHPasscodeViewControllerTypeAuthenticate) {
            return @(!(firstInput.count > 0 || secondInput.count > 0));
        }
        
        return @NO;
    }];
    
    self.cancelButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        @strongify(self)
        
        if (self.firstInput.count > 0 || self.secondInput.count > 0) {
            [self resetInput];
        } else {
            
            // can only cancel if not authenticating
            if (self.type != DHPasscodeViewControllerTypeAuthenticate) {
                if (self.completionBlock) {
                    self.completionBlock(self, NO, nil);
                }
            }
        }
        
        return [RACSignal empty];
    }];
    
    [[RACSignal combineLatest:@[typeSignal, firstInputSignal, secondInputSignal, thirdInputSignal]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self)
        
        // Dots
        
        NSMutableArray *lastInput = self.lastInput;
        NSMutableArray *currentInput = self.currentInput;
        
        [self.dotViews enumerateObjectsUsingBlock:^(DHPasscodeDotView *dotView, NSUInteger idx, BOOL *stop) {
            dotView.filled = lastInput.count > idx;
        }];
        
        if (lastInput.count == DH_PASSCODE_LENGTH) {
            [self enablePasscodeButtons:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.dotViews enumerateObjectsUsingBlock:^(DHPasscodeDotView *dotView, NSUInteger idx, BOOL *stop) {
                    dotView.filled = currentInput.count > idx;
                }];
                [self enablePasscodeButtons:YES];
            });
        }
        
        // Input Validation
        NSString *firstInput = [tuple.second componentsJoinedByString:DH_PASSCODE_DELIMITER];
        NSString *secondInput = [tuple.third componentsJoinedByString:DH_PASSCODE_DELIMITER];
        BOOL firstInputIsValid = NO;
        
        if ([tuple.second count] == DH_PASSCODE_LENGTH) {
            firstInputIsValid = [self passcodeEntryIsValid:tuple.second];
            if (!firstInputIsValid) {
                if ([tuple.first integerValue] == DHPasscodeViewControllerTypeAuthenticate ||
                    [tuple.first integerValue] == DHPasscodeViewControllerTypeChangeExisting ||
                    [tuple.first integerValue] == DHPasscodeViewControllerTypeRemove) {
                    
                    // Bad password
                    NSLog(@"Invalid passcode: %@ != %@", firstInput, self.currentPasscodeString);
                    
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    
                    [self enablePasscodeButtons:NO];
                    [self shakeInvalidWithCompletionBlock:^{
                        [self resetInput];
                        [self enablePasscodeButtons:YES];
                    }];
                    
                    return;
                }
                
            } else {
                
                if ([tuple.first integerValue] == DHPasscodeViewControllerTypeAuthenticate ||
                    [tuple.first integerValue] == DHPasscodeViewControllerTypeRemove) {
                    
                    if ([tuple.first integerValue] == DHPasscodeViewControllerTypeAuthenticate) {

                        NSLog(@"Authenticated with passcode");
                        
                        if (self.completionBlock) {
                            self.completionBlock(self, YES, nil);
                        }
                        
                    } else if ([tuple.first integerValue] == DHPasscodeViewControllerTypeRemove) {
                        
                        NSLog(@"Disabling passcode");
                        
                        NSError *removePasscodeError;
                        BOOL removed = [SSKeychain deletePasswordForService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                                                    account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE
                                                                      error:&removePasscodeError];
                        
                        if (removePasscodeError) {
                            NSLog(@"Error removing passcode: %@", removePasscodeError);
                        }
                        
                        if (self.completionBlock) {
                            self.completionBlock(self, removed, removePasscodeError);
                        }
                    }
                    
                    [self resetInput];
                    
                    return;
                }
            }
        }
        
        if ([tuple.first integerValue] == DHPasscodeViewControllerTypeCreateNew) {
            
            if ([tuple.second count] == DH_PASSCODE_LENGTH && [tuple.third count] == DH_PASSCODE_LENGTH) {
                
                __block BOOL passcodesMatch = YES;
                [tuple.second enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if (obj != tuple.third[idx]) {
                        passcodesMatch = NO;
                        *stop = YES;
                    }
                }];
                
                if (passcodesMatch) {
                    NSLog(@"Creating passcode");
                    
                    NSError *createPasscodeError;
                    BOOL created = [SSKeychain setPassword:firstInput
                                                forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                                   account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE
                                                     error:&createPasscodeError];
                    
                    if (createPasscodeError) {
                        NSLog(@"Error creating passcode: %@", createPasscodeError);
                    }
                    
                    if (self.completionBlock) {
                        self.completionBlock(self, created, createPasscodeError);
                    }
                    
                    [self resetInput];
                    
                    return;
                    
                } else {
                    NSLog(@"Passwords don't match - resetting");
                    [self enablePasscodeButtons:NO];
                    [self shakeInvalidWithCompletionBlock:^{
                        [self resetInput];
                        [self enablePasscodeButtons:YES];
                    }];
                }
            }
        }
        
        if (firstInputIsValid && [tuple.first integerValue] == DHPasscodeViewControllerTypeChangeExisting) {
            
            if ([tuple.third count] == DH_PASSCODE_LENGTH && [tuple.fourth count] == DH_PASSCODE_LENGTH) {
                
                __block BOOL passcodesMatch = YES;
                [tuple.third enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if (obj != tuple.fourth[idx]) {
                        passcodesMatch = NO;
                        *stop = YES;
                    }
                }];
                
                if (passcodesMatch) {
                    NSLog(@"Changing passcode");
                    
                    NSError *changePasscodeError;
                    BOOL changed = [SSKeychain setPassword:secondInput
                                                forService:DH_PASSCODE_KEYCHAIN_SERVICE_NAME
                                                   account:DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE
                                                     error:&changePasscodeError];
                    
                    if (changePasscodeError) {
                        NSLog(@"Error changing passcode: %@", changePasscodeError);
                    }
                    
                    if (self.completionBlock) {
                        self.completionBlock(self, changed, changePasscodeError);
                    }
                    
                    [self resetInput];
                    
                    return;
                    
                } else {
                    NSLog(@"Passwords don't match - resetting");
                    [self enablePasscodeButtons:NO];
                    [self shakeInvalidWithCompletionBlock:^{
                        [self resetInput];
                        [self enablePasscodeButtons:YES];
                    }];
                }
            }
        }
    }];
}

- (BOOL)passcodeEntryIsValid:(NSArray *)passcodeEntry {
    
    if (passcodeEntry.count != DH_PASSCODE_LENGTH) {
        return NO;
    }
    
    NSString *inputPasscode = [passcodeEntry componentsJoinedByString:DH_PASSCODE_DELIMITER];
    NSString *currentPasscode = self.currentPasscodeString;
    
    return (currentPasscode && [inputPasscode isEqualToString:currentPasscode]);
}

- (void)setStyle:(DHPasscodeManagerStyle *)style {
    [self removeStyleObservers];
    _style = style;
    [self addStyleObservers];
    
    [self loadStyle];
    
    [self.dotViews enumerateObjectsUsingBlock:^(DHPasscodeDotView *dotView, NSUInteger idx, BOOL *stop) {
        dotView.style = style;
    }];
    
    [self.passcodeButtons enumerateObjectsUsingBlock:^(DHPasscodeButton *passcodeButton, NSUInteger idx, BOOL *stop) {
        passcodeButton.style = style;
    }];
}

- (void)loadStyle {
    self.view.backgroundColor = self.style.backgroundColor;
    
    self.logoImageView.image = self.style.logoImage;
    
    self.cancelButton.titleLabel.font = self.style.cancelButtonTextFont;
    [self.cancelButton setTitleColor:self.style.cancelButtonTextColor forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:self.style.cancelButtonTextColorHighlighted forState:UIControlStateHighlighted];
    
    self.instructionsLabel.textColor = self.style.instructionsTextColor;
    self.instructionsLabel.font = self.style.instructionsTextFont;
}

- (void)addStyleObservers {
    [self.style addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew context:nil];
    [self.style addObserver:self forKeyPath:@"logoImage" options:NSKeyValueObservingOptionNew context:nil];
    [self.style addObserver:self forKeyPath:@"buttonTextFont" options:NSKeyValueObservingOptionNew context:nil];
    [self.style addObserver:self forKeyPath:@"cancelButtonTextColor" options:NSKeyValueObservingOptionNew context:nil];
    [self.style addObserver:self forKeyPath:@"cancelButtonTextColorHighlighted" options:NSKeyValueObservingOptionNew context:nil];
    [self.style addObserver:self forKeyPath:@"instructionsTextColor" options:NSKeyValueObservingOptionNew context:nil];
    [self.style addObserver:self forKeyPath:@"instructionsTextFont" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeStyleObservers {
    [self.style removeObserver:self forKeyPath:@"backgroundColor"];
    [self.style removeObserver:self forKeyPath:@"logoImage"];
    [self.style removeObserver:self forKeyPath:@"buttonTextFont"];
    [self.style removeObserver:self forKeyPath:@"cancelButtonTextColor"];
    [self.style removeObserver:self forKeyPath:@"cancelButtonTextColorHighlighted"];
    [self.style removeObserver:self forKeyPath:@"instructionsTextColor"];
    [self.style removeObserver:self forKeyPath:@"instructionsTextFont"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self loadStyle];
}

- (void)resetInput {
    self.firstInput = @[].mutableCopy;
    self.secondInput = @[].mutableCopy;
    self.thirdInput = @[].mutableCopy;
}

- (void)enablePasscodeButtons:(BOOL)enable {
    [self.passcodeButtons enumerateObjectsUsingBlock:^(DHPasscodeButton *button, NSUInteger idx, BOOL *stop) {
        button.enabled = enable;
    }];
}

- (NSString *)currentPasscodeString {

    NSError *error = nil;
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = DH_PASSCODE_KEYCHAIN_SERVICE_NAME;
    query.account = DH_PASSCODE_KEYCHAIN_ACCOUNT_NAME_PASSCODE;
    [query fetch:&error];
    
    if ([error code] == errSecItemNotFound) {
        NSLog(@"Password not found");
    } else if (error != nil) {
        NSLog(@"Some other error occurred: %@", [error localizedDescription]);
    }
    
    return query.password;
}

- (NSArray *)currentPasscodeArray {
    return [self.currentPasscodeString componentsSeparatedByString:DH_PASSCODE_DELIMITER];
}

- (void)setType:(DHPasscodeViewControllerType)type {
    
    NSString *currentPasscode = self.currentPasscodeString;
    if (!currentPasscode) {
        if (type != DHPasscodeViewControllerTypeCreateNew) {
            if (self.type != DHPasscodeViewControllerTypeCreateNew) {
                NSLog(@"No password is currently set! Changing mode to: DHPasscodeViewControllerTypeCreateNew");
            }
            
            type = DHPasscodeViewControllerTypeCreateNew;
        }
    }
    
    if (type == _type) return;
    
    [self resetInput];
    
    _type = type;
}

- (NSMutableArray *)currentInput {

    NSMutableArray *currentInput = self.firstInput;
    
    if (self.firstInput.count == DH_PASSCODE_LENGTH) {
        if (self.secondInput.count == DH_PASSCODE_LENGTH) {
            currentInput = self.thirdInput;
        } else {
            currentInput = self.secondInput;
        }
    }
    
    return currentInput;
}

- (NSMutableArray *)lastInput {
    
    NSMutableArray *lastInput = self.firstInput;
    
    if (self.firstInput.count == DH_PASSCODE_LENGTH) {
        if (self.secondInput.count == DH_PASSCODE_LENGTH) {
            if (self.thirdInput.count > 0) {
                lastInput = self.thirdInput;
            }
        } else {
            if (self.secondInput.count > 0) {
                lastInput = self.secondInput;
            }
        }
    }

    return lastInput;
}

- (void)shakeInvalidWithCompletionBlock:(void (^)())completionBlock {
    [self shakeInvalidWithDirection:-1 times:5 current:0 delta:10 interval:0.05 completionBlock:completionBlock];
}

- (void)shakeInvalidWithDirection:(NSInteger)direction
                            times:(NSInteger)times
                          current:(NSInteger)current
                            delta:(CGFloat)delta
                         interval:(CGFloat)interval
                  completionBlock:(void (^)())completionBlock {
    
    [UIView animateWithDuration:interval
                     animations:^{
                         
                         for (DHPasscodeDotView *dot in self.dotViews) {
                             dot.layer.affineTransform = CGAffineTransformMakeTranslation(delta * direction, 0);
                         }
                         
                     } completion:^(BOOL finished) {
                         
                         if (current >= times) {
                             [UIView animateWithDuration:interval animations:^{
                                 for (DHPasscodeDotView *dot in self.dotViews) {
                                     dot.layer.affineTransform = CGAffineTransformIdentity;
                                 }
                             } completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
                             return;
                         }
                         
                         [self shakeInvalidWithDirection:direction * -1
                                                   times:(times - 1)
                                                 current:(current + 1)
                                                   delta:delta
                                                interval:interval
                                         completionBlock:completionBlock];
                     }];
}

@end
