//
//  PoolInviteCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 3/17/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoolInviteCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView *poolTypeImageView;
@property (nonatomic,strong) IBOutlet UIImageView *poolImageView;
@property (nonatomic,strong) IBOutlet UILabel *poolCreatorLeaderTitleLabel;
@property (nonatomic,strong) IBOutlet UILabel *poolCreatorLeaderLabel;
@property (nonatomic,strong) IBOutlet UIImageView *poolCreatorLeaderImageView;
@property (nonatomic,strong) IBOutlet UILabel *poolCreatorLeaderInitialsLabel;
@property (nonatomic,strong) IBOutlet UILabel *poolsNameLabel;
@property (nonatomic,strong) IBOutlet UILabel *poolsTypeLabel;
@property (nonatomic,strong) IBOutlet UILabel *dateLabel;
@property (nonatomic,strong) IBOutlet UILabel *numberParticipantsLabel;

@end