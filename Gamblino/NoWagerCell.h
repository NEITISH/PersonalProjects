//
//  NoWagerCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/23/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoWagerCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *noWagersLabel;

-(IBAction)findAvailableGamesAction:(id)sender;

@end
