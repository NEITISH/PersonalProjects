//
//  AlertViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/20/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendRequestCell.h"
#import "PrizeCell.h"

@interface AlertViewController : UIViewController<FriendRequestCellDelegate,PrizeCellDelegate>

@property (nonatomic,strong) UIImage *blurImage;

- (id)initWithBackgroundImage:(UIImage*)image;

@end
