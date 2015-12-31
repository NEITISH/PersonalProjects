//
//  PlaceWagerViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/26/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"
#import "Event.h"
#import "Answer.h"

@interface PlaceWagerViewController : UIViewController

- (id)initWithBackgroundImage:(UIImage*)image line:(Line*)line game:(Event*)game answer:(Answer*)answer;

@end
