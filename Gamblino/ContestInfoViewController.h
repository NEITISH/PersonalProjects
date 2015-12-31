//
//  ContestInfoViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/27/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contest.h"
#import "Line.h"
#import "Event.h"

@class ContestInfoViewController;

@protocol ContestInfoViewControllerDelegate <NSObject>
@optional
-(void)contestInfoViewController:(ContestInfoViewController*)contestInfoViewController didJoinContest:(Contest*)contest;
@end

@interface ContestInfoViewController : UIViewController

@property (unsafe_unretained) id<ContestInfoViewControllerDelegate> delegate;

- (id)initWithBackgroundImage:(UIImage*)image contest:(Contest*)contest game:(Event*)game;

@end
