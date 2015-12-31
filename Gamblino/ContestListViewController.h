//
//  ContestListViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/28/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Line.h"
#import "Answer.h"
#import "ContestInfoViewController.h"

@interface ContestListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ContestInfoViewControllerDelegate>

- (id)initWithBackgroundImage:(UIImage*)image line:(Line*)line game:(Event*)game answer:(Answer*)answer;

@end
