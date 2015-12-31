//
//  PrizeCell.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/21/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "PrizeCell.h"

@implementation PrizeCell

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

-(IBAction)redeemAction:(id)sender{
    if(self.delegate){
        [self.delegate prizeCellDidRedeem:self];
    }
}

@end
