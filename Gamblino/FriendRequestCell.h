//
//  FriendRequestCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/21/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendRequestCell;

@protocol FriendRequestCellDelegate <NSObject>
@optional
-(void)friendRequestCellDidAccept:(FriendRequestCell*)friendRequestCell;
-(void)friendRequestCellDidDecline:(FriendRequestCell*)friendRequestCell;
@end

@interface FriendRequestCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *userImageView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *requestTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *initialsLabel;
@property (nonatomic,weak) id<FriendRequestCellDelegate> delegate;

-(IBAction)acceptAction:(id)sender;
-(IBAction)declineAction:(id)sender;

@end
