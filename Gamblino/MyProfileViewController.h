//
//  MyProfileViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/17/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface MyProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    NSMutableArray *wagersArray ;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User*)user context:(NSString *)context id:(int)ide;
@end
