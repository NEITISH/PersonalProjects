//
//  LeaderboardScrollCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/11/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardScrollCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UILabel *leaderboardLabel;

@end
