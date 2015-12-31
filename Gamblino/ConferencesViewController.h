//
//  ConferencesViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/14/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "League.h"
#import "Conference.h"

@class ConferencesViewController;

@protocol ConferencesViewControllerDelegate <NSObject>
@optional
-(void)conferencesViewController:(ConferencesViewController*)conferencesViewController didSelectConference:(Conference*)conference;
@end

@interface ConferencesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) id<ConferencesViewControllerDelegate> delegate;

- (id)initWithBackgroundImage:(UIImage*)image league:(League*)league selectedConference:(Conference*)conference delegate:(id)delegate;

@end
