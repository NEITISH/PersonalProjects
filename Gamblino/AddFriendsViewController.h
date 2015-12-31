//
//  AddFriendsViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 11/26/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddFriendsFacebookViewController.h"
#import "AddFriendsContactsViewController.h"
#import "AddFriendsGamblinoViewController.h"
#import "Pool.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface AddFriendsViewController : UIViewController<AddFriendsContactsViewControllerDelegate,AddFriendsFacebookViewControllerDelegate,AddFriendsGamblinoViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIActionSheetDelegate>

@property (nonatomic,strong) Pool *pool;

@end
