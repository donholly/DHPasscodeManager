//
//  DHPasscodeViewController.m
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeViewController.h"

#import "DHPasscodeDotView.h"
#import "DHPasscodeButton.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#define DH_PASSCODE_BUTTON_SIZE 60.0f
#define DH_PASSCODE_BUTTON_SPACING_X 25.0f
#define DH_PASSCODE_BUTTON_SPACING_Y 15.0f

#define DH_PASSCODE_DOT_SIZE 10.0f
#define DH_PASSCODE_DOT_SPACING 15.0f

#define DH_PASSCODE_SPACING 10.0f

// Changing this would break things right now
// TODO: support variable length passcodes one day?
#define DH_PASSCODE_LENGTH 4

@interface DHPasscodeViewController ()
@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UILabel *instructionsLabel;

@property (nonatomic, strong) DHPasscodeDotView *dotView0;
@property (nonatomic, strong) DHPasscodeDotView *dotView1;
@property (nonatomic, strong) DHPasscodeDotView *dotView2;
@property (nonatomic, strong) DHPasscodeDotView *dotView3;

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

@property (nonatomic, strong) NSMutableArray *currentInput;

@end

@implementation DHPasscodeViewController

- (void)dealloc {
    [self removeStyleObservers];
}

- (id)init {
    if (self = [super init]) {
        
        // default to a verify passcode
        self.type = DHPasscodeViewControllerTypeVerify;
        
        self.currentInput = @[].mutableCopy;
    }
    return self;
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
    [self.view addSubview:self.dotView0];
    
    self.dotView1 = [[DHPasscodeDotView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.dotView1];
    
    self.dotView2 = [[DHPasscodeDotView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.dotView2];
    
    self.dotView3 = [[DHPasscodeDotView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.dotView3];
    
    // Buttons
    self.passcodeButton0 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(0)];
    [self.passcodeButton0 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton0];
    
    self.passcodeButton1 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(1)];
    [self.passcodeButton1 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton1];
    
    self.passcodeButton2 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(2)];
    [self.passcodeButton2 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton2];
    
    self.passcodeButton3 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(3)];
    [self.passcodeButton3 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton3];
    
    self.passcodeButton4 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(4)];
    [self.passcodeButton4 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton4];
    
    self.passcodeButton5 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(5)];
    [self.passcodeButton5 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton5];
    
    self.passcodeButton6 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(6)];
    [self.passcodeButton6 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton6];
    
    self.passcodeButton7 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(7)];
    [self.passcodeButton7 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton7];
    
    self.passcodeButton8 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(8)];
    [self.passcodeButton8 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton8];
    
    self.passcodeButton9 = [[DHPasscodeButton alloc] initWithFrame:CGRectZero number:@(9)];
    [self.passcodeButton9 addTarget:self action:@selector(didTapNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.passcodeButton9];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(didTapCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
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

- (void)setStyle:(DHPasscodeManagerStyle *)style {
    [self removeStyleObservers];
    _style = style;
    [self addStyleObservers];
    
    [self loadStyle];
    
    self.dotView0.style = style;
    self.dotView1.style = style;
    self.dotView2.style = style;
    self.dotView3.style = style;
    
    self.passcodeButton0.style = style;
    self.passcodeButton1.style = style;
    self.passcodeButton2.style = style;
    self.passcodeButton3.style = style;
    self.passcodeButton4.style = style;
    self.passcodeButton5.style = style;
    self.passcodeButton6.style = style;
    self.passcodeButton7.style = style;
    self.passcodeButton8.style = style;
    self.passcodeButton9.style = style;
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

- (void)setType:(DHPasscodeViewControllerType)type {
    _type = type;
    
    switch (type) {
        case DHPasscodeViewControllerTypeVerify:
            self.instructionsLabel.text = NSLocalizedString(@"", @"");
            break;
        case DHPasscodeViewControllerTypeCreateNew:
            self.instructionsLabel.text = NSLocalizedString(@"Enter a passcode", @"Enter a passcode");
            break;
        case DHPasscodeViewControllerTypeChangeExisting:
            self.instructionsLabel.text = NSLocalizedString(@"Enter your current passcode", @"Enter your current passcode");
            break;
        case DHPasscodeViewControllerTypeRemove:
            self.instructionsLabel.text = NSLocalizedString(@"Enter your current passcode", @"Enter your current passcode");
            break;
            
        default:
            NSLog(@"Unknown DHPasscodeViewControllerType: %@", @(type));
            break;
    }
}

- (void)didTapNumber:(DHPasscodeButton *)button {
    
    [self.currentInput addObject:@(button.tag)];
    
    [self updateDots];
    
    if (self.currentInput.count == DH_PASSCODE_LENGTH) {
        [self passcodeEntryComplete];
    }
}

- (void)updateDots {
    self.dotView0.filled = self.currentInput.count > 0;
    self.dotView1.filled = self.currentInput.count >= 2;
    self.dotView2.filled = self.currentInput.count >= 3;
    self.dotView3.filled = self.currentInput.count >= 4;
}

- (void)passcodeEntryComplete {
    
}

- (void)didTapCancel:(UIButton *)button {
    
}

@end
