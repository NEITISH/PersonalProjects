//
//  FriendCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/2/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell

@property(nonatomic,strong) IBOutlet UILabel *nameLabel;
@property(nonatomic,strong) IBOutlet UILabel *locationLabel;
@property(nonatomic,strong) IBOutlet UILabel *emailLabel;
@property(nonatomic,strong) IBOutlet UIImageView *avatarImageView;
@property(nonatomic,strong) IBOutlet UIImageView *selectedImageView;
@property(nonatomic,strong) IBOutlet UILabel *initialsLabel;

@end
