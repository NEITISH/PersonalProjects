//
//  LeaderBoardDetailCell.h
//  Gamblino
//
//  Created by Prodio on 31/10/15.
//  Copyright © 2015 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderBoardDetailCell : UITableViewCell

@property(nonatomic,strong)IBOutlet UILabel *ranks;
@property(nonatomic,strong)IBOutlet UILabel *points;
@property(nonatomic,strong)IBOutlet UILabel *names;
@property(nonatomic,strong)IBOutlet UIImageView *players;
@property(nonatomic,strong)IBOutlet UILabel *nameinitials;

@end
