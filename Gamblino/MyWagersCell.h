//
//  MyWagersCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/5/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWagersCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *teamsLabel;
@property(nonatomic,weak) IBOutlet UILabel *dateLabel;
@property(nonatomic,weak) IBOutlet UIImageView *awayImageView;
@property(nonatomic,weak) IBOutlet UIImageView *homeImageView;
@property(nonatomic,weak) IBOutlet UILabel *awayScoreLabel;
@property(nonatomic,weak) IBOutlet UILabel *homeScoreLabel;

@end
