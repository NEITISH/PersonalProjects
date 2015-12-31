//
//  ContestDetailsViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/10/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contest.h"
#import "ContestInfoViewController.h"

@interface ContestDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ContestInfoViewControllerDelegate>
{
    
    NSMutableArray *wagersArray ;
}
- (id)initWithBackgroundImage:(UIImage*)image contest:(Contest*)contest;

@end
