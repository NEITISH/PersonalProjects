//
//  PoolsInfoViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 3/17/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pool.h"

@class PoolsInfoViewController;

@protocol PoolsInfoViewControllerDelegate <NSObject>
@optional
-(void)poolsInfoViewController:(PoolsInfoViewController*)poolsInfoViewController didJoinPool:(Pool*)pool;
@end

@interface PoolsInfoViewController : UIViewController

@property (unsafe_unretained) id<PoolsInfoViewControllerDelegate> delegate;

- (id)initWithBackgroundImage:(UIImage*)image pool:(Pool*)pool;

@end
