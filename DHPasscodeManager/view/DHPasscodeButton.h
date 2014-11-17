//
//  DHPasscodeButton.h
//  DHPasscodeManager
//
//  Created by Don Holly on 11/16/14.
//  Copyright (c) 2014 Don Holly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DHPasscodeManagerStyle.h"

@interface DHPasscodeButton : UIButton

@property (nonatomic, weak) DHPasscodeManagerStyle *style;

- (id)initWithFrame:(CGRect)frame number:(NSNumber *)number;

@end
