//
//  AddFriendsContactsViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 11/29/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@class AddFriendsContactsViewController;

@protocol AddFriendsContactsViewControllerDelegate <NSObject>
@optional
-(void)addFriendsContactsViewController:(AddFriendsContactsViewController*)addFriendsContactsViewController didAddFriend:(Person*)person;
-(void)addFriendsContactsViewController:(AddFriendsContactsViewController*)addFriendsContactsViewController didRemoveFriend:(Person*)person;
@end


@interface AddFriendsContactsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (unsafe_unretained) id<AddFriendsContactsViewControllerDelegate> delegate;
@property(nonatomic,strong) NSMutableArray *selectedContacts;

@end
