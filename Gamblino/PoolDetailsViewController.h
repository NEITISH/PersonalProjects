//
//  PoolDetailsViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 3/15/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pool.h"
#import "PoolType.h"

@interface PoolDetailsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>{
    
    NSMutableArray *wagersArray ;
}

- (id)initWithBackgroundImage:(UIImage*)image pool:(Pool*)pool;

@end
