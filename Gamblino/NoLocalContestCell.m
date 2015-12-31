//
//  NoLocalContestCell.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/22/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "NoLocalContestCell.h"

@implementation NoLocalContestCell

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

-(IBAction)requestGamblinoAction:(id)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Thanks!" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
