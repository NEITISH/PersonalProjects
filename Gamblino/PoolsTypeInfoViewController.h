//
//  PoolsInfoViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 3/17/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoolType.h"
#import "Pool.h"

@class PoolsTypeInfoViewController;

@protocol PoolsTypeInfoViewControllerDelegate <NSObject>
@optional
-(void)poolsInfoViewController:(PoolsTypeInfoViewController *)poolsTypeInfoViewController didCreatePool:(Pool *)pool;

@end

@interface PoolsTypeInfoViewController : UIViewController<UITextViewDelegate>

@property (unsafe_unretained) id<PoolsTypeInfoViewControllerDelegate> delegate;

- (id)initWithBackgroundImage:(UIImage*)image pool:(PoolType*)pooltype;

@end
