//
//  PoolTypeCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 3/15/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoolTypeCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UIImageView *typeImageView;
@property(nonatomic,weak) IBOutlet UILabel *typeLabel;
@property(nonatomic,weak) IBOutlet UILabel *typeDescription;

@end
