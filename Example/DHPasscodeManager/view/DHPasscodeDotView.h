//
//  DHPasscodeDotView.h
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DHPasscodeManagerStyle.h"

@interface DHPasscodeDotView : UIView

@property (nonatomic) BOOL filled;
@property (nonatomic, weak) DHPasscodeManagerStyle *style;

- (id)initWithFrame:(CGRect)frame;

@end
