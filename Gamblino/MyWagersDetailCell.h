//
//  MyWagersDetailCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/6/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWagersDetailCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UIImageView *leftImageView;
@property(nonatomic,weak) IBOutlet UIImageView *rightImageView;
@property(nonatomic,weak) IBOutlet UILabel *wagerTitleLabel;
@property(nonatomic,weak) IBOutlet UIImageView *contestImageView;
@property(nonatomic,weak) IBOutlet UILabel *contestTitleLabel;
@property(nonatomic,weak) IBOutlet UILabel *toWinLabel;

@end
