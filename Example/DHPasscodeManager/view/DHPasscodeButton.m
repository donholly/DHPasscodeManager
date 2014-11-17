//
//  DHPasscodeButton.m
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeButton.h"

@interface DHPasscodeButton ()
@property (nonatomic, strong) CAShapeLayer *circleShape;
@end

@implementation DHPasscodeButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.circleShape = [CAShapeLayer layer];
        [self.layer addSublayer:self.circleShape];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame number:(NSNumber *)number {
    
    self = [[DHPasscodeButton alloc] initWithFrame:frame];
    
    if (self) {
        [self setTag:[number integerValue]];
        [self setTitle:[NSString stringWithFormat:@"%@", number] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.circleShape.bounds = self.bounds;
    self.circleShape.position = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,
                                                                           0,
                                                                           CGRectGetWidth(self.frame),
                                                                           CGRectGetHeight(self.frame))];
    [self.circleShape setPath:path.CGPath];
}

- (void)setStyle:(DHPasscodeManagerStyle *)style {
    [self removeStyleObservers];
    _style = style;
    [self addStyleObservers];
    
    [self loadStyle];
}

- (void)loadStyle {

    self.circleShape.strokeColor = self.style.buttonOutlineColor.CGColor;
    self.circleShape.fillColor = self.style.buttonFillColor.CGColor;
    
    [self setTitleColor:self.style.buttonTextColor forState:UIControlStateNormal];
    [self setTitleColor:self.style.buttonTextColorHighlighted forState:UIControlStateHighlighted];
    
    self.titleLabel.font = self.style.buttonTextFont;
}

- (void)addStyleObservers {
    [self.style addObserver:self forKeyPath:@"buttonOutlineColor" options:NSKeyValueObservingOptionNew context:nil];
    [self.style addObserver:self forKeyPath:@"buttonFillColor" options:NSKeyValueObservingOptionNew context:nil];
    [self.style addObserver:self forKeyPath:@"buttonTextFont" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeStyleObservers {
    [self.style removeObserver:self forKeyPath:@"buttonOutlineColor"];
    [self.style removeObserver:self forKeyPath:@"buttonFillColor"];
    [self.style removeObserver:self forKeyPath:@"buttonTextFont"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"buttonOutlineColor"]) {
        [self loadStyle];
    } else if ([keyPath isEqualToString:@"buttonFillColor"]) {
        [self loadStyle];
    } else if ([keyPath isEqualToString:@"buttonTextFont"]) {
        [self loadStyle];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        [self.circleShape setStrokeColor:self.style.buttonOutlineColorHighlighted.CGColor];
        [self.circleShape setFillColor:self.style.buttonFillColorHighlighted.CGColor];
        self.titleLabel.font = self.style.buttonTextFontHighlighted;
    } else {
        [self.circleShape setStrokeColor:self.style.buttonOutlineColor.CGColor];
        [self.circleShape setFillColor:self.style.buttonFillColor.CGColor];
        self.titleLabel.font = self.style.buttonTextFont;
    }
}

@end
