//
//  DHPasscodeDotView.m
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import "DHPasscodeDotView.h"

@interface DHPasscodeDotView ()
@property (nonatomic, strong) CAShapeLayer *circleShape;
@property (nonatomic, strong) UIColor *outlineColor;
@property (nonatomic, strong) UIColor *fillColor;
@end

@implementation DHPasscodeDotView

@dynamic filled;

- (void)dealloc {
    [self removeStyleObservers];
}

- (id)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        self.circleShape = [CAShapeLayer layer];
        [self.circleShape setLineWidth:1.0f];
        [self.circleShape setFillColor:[UIColor clearColor].CGColor];
        
        [[self layer] addSublayer:self.circleShape];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.circleShape.bounds = self.bounds;
    self.circleShape.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.circleShape.path = path.CGPath;
}

- (void)setFilled:(BOOL)filled {
    if (filled) {
        self.circleShape.fillColor = self.fillColor.CGColor;
    } else {
        self.circleShape.fillColor = [UIColor clearColor].CGColor;
    }
}

- (BOOL)filled {
    return !(self.circleShape.fillColor == [UIColor clearColor].CGColor);
}

- (void)setOutlineColor:(UIColor *)outlineColor {
    _outlineColor = outlineColor;
    self.circleShape.strokeColor = outlineColor.CGColor;
}

- (void)setStyle:(DHPasscodeManagerStyle *)style {
    [self removeStyleObservers];
    _style = style;
    [self addStyleObservers];
    
    [self loadStyle];
}

- (void)loadStyle {
    self.outlineColor = self.style.dotOutlineColor;
    self.fillColor = self.style.dotFillColor;
}

- (void)addStyleObservers {
    [self.style addObserver:self forKeyPath:@"dotOutlineColor" options:NSKeyValueObservingOptionNew context:nil];
    [self.style addObserver:self forKeyPath:@"dotFillColor" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeStyleObservers {
    [self.style removeObserver:self forKeyPath:@"dotOutlineColor"];
    [self.style removeObserver:self forKeyPath:@"dotFillColor"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self loadStyle];
}

@end
