//
//  ViewController.m
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "ViewController.h"

#import "DHPasscodeManager.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *verifyPasscodeButton;
@property (nonatomic, strong) UIButton *createPasscodeButton;
@property (nonatomic, strong) UIButton *changePasscodeButton;
@property (nonatomic, strong) UIButton *disablePasscodeButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.verifyPasscodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.verifyPasscodeButton setTitle:@"Verify Passcode" forState:UIControlStateNormal];
    [self.verifyPasscodeButton addTarget:self action:@selector(didTapVerify:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.verifyPasscodeButton];
    
    self.createPasscodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.createPasscodeButton setTitle:@"Create Passcode" forState:UIControlStateNormal];
    [self.createPasscodeButton addTarget:self action:@selector(didTapCreate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createPasscodeButton];
    
    self.changePasscodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.changePasscodeButton setTitle:@"Change Passcode" forState:UIControlStateNormal];
    [self.changePasscodeButton addTarget:self action:@selector(didTapChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changePasscodeButton];
    
    self.disablePasscodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.disablePasscodeButton setTitle:@"Disable Passcode" forState:UIControlStateNormal];
    [self.disablePasscodeButton addTarget:self action:@selector(didTapDisable:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.disablePasscodeButton];
    
    // Style the passcode manager
    [DHPasscodeManager sharedInstance].passcodeEnabled = YES;
    
    [DHPasscodeManager sharedInstance].style.logoImage = [UIImage imageNamed:@"lock"];
    
    [DHPasscodeManager sharedInstance].modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize buttonSize = CGSizeMake(200, 44);
    CGFloat buttonPadding = 20;
    
    self.verifyPasscodeButton.frame = CGRectMake(self.view.frame.size.width/2 - buttonSize.width/2,
                                                 100,
                                                 buttonSize.width,
                                                 buttonSize.height);
    
    self.createPasscodeButton.frame = CGRectMake(self.view.frame.size.width/2 - buttonSize.width/2,
                                                 CGRectGetMaxY(self.verifyPasscodeButton.frame) + buttonPadding,
                                                 buttonSize.width,
                                                 buttonSize.height);
    
    self.changePasscodeButton.frame = CGRectMake(self.view.frame.size.width/2 - buttonSize.width/2,
                                                 CGRectGetMaxY(self.createPasscodeButton.frame) + buttonPadding,
                                                 buttonSize.width,
                                                 buttonSize.height);
    
    self.disablePasscodeButton.frame = CGRectMake(self.view.frame.size.width/2 - buttonSize.width/2,
                                                  CGRectGetMaxY(self.changePasscodeButton.frame) + buttonPadding,
                                                  buttonSize.width,
                                                  buttonSize.height);
}

- (void)didTapVerify:(UIButton *)button {
    [[DHPasscodeManager sharedInstance] verifyPasscodeWithPresentingViewController:self
                                                                          animated:YES
                                                                   completionBlock:^(BOOL success, NSError *error) {
                                                                       if (error) {
                                                                           [self handleError:error];
                                                                       }
                                                                   }];
}

- (void)didTapCreate:(UIButton *)button {
    [[DHPasscodeManager sharedInstance] createPasscodeWithPresentingViewController:self
                                                                          animated:YES
                                                                   completionBlock:^(BOOL success, NSError *error) {
                                                                       if (error) {
                                                                           [self handleError:error];
                                                                       }
                                                                   }];
}

- (void)didTapChange:(UIButton *)button {
    [[DHPasscodeManager sharedInstance] changePasscodeWithPresentingViewController:self
                                                                          animated:YES
                                                                   completionBlock:^(BOOL success, NSError *error) {
                                                                       if (error) {
                                                                           [self handleError:error];
                                                                       }
                                                                   }];
}

- (void)didTapDisable:(UIButton *)button {
    [[DHPasscodeManager sharedInstance] disablePasscodeWithPresentingViewController:self
                                                                           animated:YES
                                                                    completionBlock:^(BOOL success, NSError *error) {
                                                                        if (error) {
                                                                            [self handleError:error];
                                                                        }
                                                                    }];
}

- (void)handleError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:@"Okay"
                      otherButtonTitles:nil] show];
}

@end
