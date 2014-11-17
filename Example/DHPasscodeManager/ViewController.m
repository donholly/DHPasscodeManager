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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [DHPasscodeManager sharedInstance].style.logoImage = [UIImage imageNamed:@"lock"];
    
    [[DHPasscodeManager sharedInstance] createPasscodeWithPresentingViewController:self
                                                                          animated:YES
                                                                   completionBlock:^(BOOL success, NSError *error) {
                                                                       
                                                                   }];
}

@end
