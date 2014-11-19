//
//  DHPasscodeManagerStyle.h
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHPasscodeManagerStyle : NSObject

// View Controller
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *logoImage;

// Instructions
@property (nonatomic, strong) UIColor *instructionsTextColor;
@property (nonatomic, strong) UIFont *instructionsTextFont;

// Buttons
@property (nonatomic, strong) UIColor *buttonOutlineColor;
@property (nonatomic, strong) UIColor *buttonOutlineColorHighlighted;

@property (nonatomic, strong) UIColor *buttonFillColor;
@property (nonatomic, strong) UIColor *buttonFillColorHighlighted;

@property (nonatomic, strong) UIColor *buttonTextColor;
@property (nonatomic, strong) UIColor *buttonTextColorHighlighted;

@property (nonatomic, strong) UIFont *buttonTextFont;
@property (nonatomic, strong) UIFont *buttonTextFontHighlighted;

@property (nonatomic, strong) UIColor *cancelButtonTextColor;
@property (nonatomic, strong) UIColor *cancelButtonTextColorHighlighted;
@property (nonatomic, strong) UIFont *cancelButtonTextFont;

// Dots
@property (nonatomic, strong) UIColor *dotOutlineColor;
@property (nonatomic, strong) UIColor *dotFillColor;

@end
