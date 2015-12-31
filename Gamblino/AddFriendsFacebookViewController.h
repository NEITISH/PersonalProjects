//
//  AddFriendsFacebookViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 11/29/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@class AddFriendsFacebookViewController;

@protocol AddFriendsFacebookViewControllerDelegate <NSObject>
@optional
-(void)addFriendsFacebookViewController:(AddFriendsFacebookViewController*)addFriendsFacebookViewController didAddFriend:(Person*)person;
-(void)addFriendsFacebookViewController:(AddFriendsFacebookViewController*)addFriendsFacebookViewController didRemoveFriend:(Person*)person;
@end


@interface AddFriendsFacebookViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (unsafe_unretained) id<AddFriendsFacebookViewControllerDelegate> delegate;
@property(nonatomic,strong) NSMutableArray *selectedContacts;

@end
