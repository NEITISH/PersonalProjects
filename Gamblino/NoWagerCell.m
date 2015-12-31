//
//  NoWagerCell.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/23/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "NoWagerCell.h"

@implementation NoWagerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)findAvailableGamesAction:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissModalAndStartBetting" object:nil];
}

@end
