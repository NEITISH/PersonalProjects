//
//  IndividualGameViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/22/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "GameLineCell.h"

@interface IndividualGameViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,GameLineCellDelegate>

@property (nonatomic,strong) Event *game;

- (id)initWithBackgroundImage:(UIImage*)image game:(Event*)game;
- (void)refreshScreen;

@end
