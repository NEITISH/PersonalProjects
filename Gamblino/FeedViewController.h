//
//  FeedViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 11/4/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "ContestInfoViewController.h"
#import "PoolsInfoViewController.h"


@interface FeedViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ContestInfoViewControllerDelegate,PoolsInfoViewControllerDelegate>

@end
