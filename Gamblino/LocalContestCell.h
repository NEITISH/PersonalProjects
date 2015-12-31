//
//  LocalContestCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/9/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalContestCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *contestImageView;
@property (nonatomic,weak) IBOutlet UILabel *contestTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *contestDescriptionLabel;

@end
