//
//  AddFriendsGamblinoViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 3/16/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@class  AddFriendsGamblinoViewController;

@protocol AddFriendsGamblinoViewControllerDelegate <NSObject>
@optional
-(void)addFriendsGamblinoViewController:(AddFriendsGamblinoViewController*)addFriendsGamblinoViewController didAddFriend:(Person*)person;
-(void)addFriendsGamblinoViewController:(AddFriendsGamblinoViewController*)addFriendsGamblinoViewController didRemoveFriend:(Person*)person;



@end

@interface AddFriendsGamblinoViewController : UIViewController

@property (unsafe_unretained) id<AddFriendsGamblinoViewControllerDelegate> delegate;

-(void)reloadTableView:(NSMutableArray*)selectedContacts;

@end
