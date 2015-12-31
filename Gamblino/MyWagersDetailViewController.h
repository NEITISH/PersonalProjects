//
//  MyWagersDetailViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/5/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface MyWagersDetailViewController : UIViewController

@property (nonatomic,strong) Event *game;

- (id)initWithBackgroundImage:(UIImage*)image game:(Event*)game wagers:(NSArray*)wagers context:(NSString *)context context_id:(int)context_id nibName:(NSString*)nibName bundle:(NSString*)bundle;
-(void)refreshScreen;

@end
