//
//  InputBetViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/30/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contest.h"
#import "Line.h"
#import "Event.h"
#import "Answer.h"
#import "Pool.h"

@interface InputBetViewController : UIViewController<UITextFieldDelegate>

- (id)initWithBackgroundImage:(UIImage*)image contest:(Contest*)contest pool:(Pool*)pool line:(Line*)line game:(Event*)game answer:(Answer*)answer;

@end
