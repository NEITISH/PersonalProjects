//
//  ContestCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/26/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContestCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *contestImageView;
@property (nonatomic,weak) IBOutlet UILabel *contestTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *pointBalanceTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *maxBetTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *pointBalanceLabel;
@property (nonatomic,weak) IBOutlet UILabel *maxBetLabel;
@property (nonatomic,weak) IBOutlet UIImageView *joinNowButtonImageView;

-(IBAction)joinNowAction:(id)sender;

@end
