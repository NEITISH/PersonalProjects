//
//  GameListCell.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/12/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "GameListCell.h"

@implementation GameListCell

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

- (void)showNextLine{
    if(self.delegate){
        [self.delegate gameListCellShowNextLine:self];
    }
}

@end
