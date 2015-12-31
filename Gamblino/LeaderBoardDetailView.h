//
//  LeaderBoardDetailView.h
//  Gamblino
//
//  Created by Prodio on 31/10/15.
//  Copyright © 2015 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contest.h"
#import "Pool.h"
#import "PoolType.h"

@interface LeaderBoardDetailView : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    NSString *pointslabel;
    NSString *rank;
    
}
- (IBAction)Back:(id)sender;
- (IBAction)Share:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *OverlayView;
@property(nonatomic,strong)IBOutlet UILabel *username;
@property(nonatomic,strong)IBOutlet UILabel *userpoints;
@property(nonatomic,strong)IBOutlet UILabel *userrank;
@property(nonatomic,strong)IBOutlet UILabel *userinitals;
@property(nonatomic,strong)IBOutlet UIImageView *Userimage;
@property(nonatomic,strong)IBOutlet UILabel *usernameheader;
@property(nonatomic,strong)IBOutlet UILabel *Poolname;
@property(nonatomic,strong)IBOutlet UILabel *Playername;
@property(nonatomic,strong)IBOutlet UILabel *Leaderboardtext;
@property (weak, nonatomic) IBOutlet UIImageView *Gamblinoimage;
@property (weak, nonatomic) IBOutlet UIButton *BackAction;
@property (weak, nonatomic) IBOutlet UIButton *shareIcon;


@property(nonatomic,strong)IBOutlet UIImageView *ImageHeader;
@property(nonatomic,strong)IBOutlet UIImageView *userImage;


@property (nonatomic,weak) IBOutlet UITableView *tableView;

@property(nonatomic,strong)NSArray *LeaderBoardArray;
@property(nonatomic,strong)NSString *headerImgSrc;
@property (nonatomic,strong) Contest *contest;
@property (nonatomic,strong) Pool *pool;
@property (nonatomic,strong) PoolType *poolType;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *Creator;






@end
