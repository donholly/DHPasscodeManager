//
//  DHPasscodeManagerStyle.m
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeManagerStyle.h"

@implementation DHPasscodeManagerStyle

- (id)init {
    
    if (self = [super init]) {
        
        // Default styling
        
        // View Controller
        self.backgroundColor = [UIColor whiteColor];
        self.logoImage = nil;
        
        // Buttons
        self.buttonOutlineColor = [UIColor blackColor];
        self.buttonOutlineColorHighlighted = [UIColor whiteColor];
        
        self.buttonFillColor = [UIColor whiteColor];
        self.buttonFillColorHighlighted = [UIColor blackColor];
        
        self.buttonTextColor = [UIColor blackColor];
        self.buttonTextColorHighlighted = [UIColor whiteColor];
        
        self.buttonTextFont = [UIFont fontWithName:@"AvenirNext-Regular" size:22.0];
        self.buttonTextFontHighlighted = [UIFont fontWithName:@"AvenirNext-Bold" size:22.0];

        self.cancelButtonTextColor = [UIColor blackColor];
        self.cancelButtonTextColorHighlighted = [UIColor whiteColor];
        
        self.cancelButtonTextFont = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
        
        self.instructionsTextColor = [UIColor blackColor];
        self.instructionsTextFont = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
        
        // Dots
        self.dotOutlineColor = [UIColor blackColor];
        self.dotFillColor = [UIColor blackColor];
        
    }
    return self;
}

@end
