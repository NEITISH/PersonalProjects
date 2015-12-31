//
//  FeedCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/20/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *contestImageView;
@property (nonatomic,weak) IBOutlet UILabel *contestTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *contestDescriptionLabel;
@property (nonatomic,weak) IBOutlet UIImageView *joinNowButtonImageView;
@property (nonatomic,weak) IBOutlet UIImageView *winnerImageView;
@property (nonatomic,weak) IBOutlet UILabel *contestWinnerTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *contestWinnerLabel;
@property (nonatomic,weak) IBOutlet UILabel *pointsLabel;
@property (nonatomic,weak) IBOutlet UILabel *initialsLabel;
@property (nonatomic,weak) IBOutlet UIImageView *poolImageView;

@property (nonatomic,weak) IBOutlet UIImageView *poolTypeImage;
@property (nonatomic,weak) IBOutlet UILabel *PoolCreator;
@property (nonatomic,weak) IBOutlet UILabel *PoolInviteMessage;
@property (nonatomic,weak) IBOutlet UILabel *PoolTitle;
@property (nonatomic,weak) IBOutlet UILabel *PoolSubTitle;
@property (nonatomic,weak) IBOutlet UIImageView *PoolCreatorImageView;











@end
