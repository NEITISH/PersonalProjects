//
//  LineViewCell.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/22/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "GameLineCell.h"

@implementation GameLineCell

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

-(IBAction)leftButtonAction:(id)sender{
    if(self.delegate){
        [self.delegate gameLineCellDidTapLeftButton:self];
    }
}

-(IBAction)rightButtonAction:(id)sender{
    if(self.delegate){
        [self.delegate gameLineCellDidTapRightButton:self];
    }
}

-(IBAction)customAnswerAction:(id)sender{
    if(self.delegate){
        [self.delegate gameLineCellDidTapAnswer:self];
    }
}

@end
