//
//  PoolsListViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/28/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "PoolsListViewController.h"
#import "Line.h"
#import "Event.h"
#import "InputBetViewController.h"
#import "PointBalance.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "Pool.h"
#import "League.h"
#import "PoolType.h"
#import "PoolCell.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"
#import "PoolsInfoViewController.h"

@interface PoolsListViewController ()

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *pools;
@property (nonatomic,strong) NSArray *filteredPools;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) Line *line;
@property (nonatomic,strong) Event *game;
@property (nonatomic,strong) Answer *answer;

@end

@implementation PoolsListViewController

- (id)initWithBackgroundImage:(UIImage*)image line:(Line*)line game:(Event*)game answer:(Answer *)answer{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.line=line;
        self.game=game;
        self.answer=answer;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadPools];
}

- (void)loadPools{
    NSString *remotePath=@"pools";
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *poolsDictionary){
        if([poolsDictionary.allKeys containsObject:@"pools"]){
            NSArray *poolsValue=[poolsDictionary valueForKey:@"pools"];
            NSMutableArray *poolsArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in poolsValue){
                Pool *pool=[[Pool alloc] initWithDictionary:dic];
                [poolsArray addObject:pool];
            }
            self.pools=poolsArray;
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self filterPoolsForCurrentLeague];
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self filterPoolsForCurrentLeague];
        NSLog(@"error=%@",error.description);
    }];
}

- (void)filterPoolsForCurrentLeague{
    NSMutableArray *filteredPools=[[NSMutableArray alloc] init];
    for(Pool *pool in self.pools){
        BOOL isLeagueInPool=NO;
        for(League *league in pool.poolType.leagues){
            if(league.leaguesIdentifier==self.game.leagueId){
                isLeagueInPool=YES;
            }
        }
        if(isLeagueInPool){
            [filteredPools addObject:pool];
        }
    }
    self.filteredPools=filteredPools;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredPools.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Pool *pool=[self.filteredPools objectAtIndex:indexPath.row];
    PoolCell *cell;
    if(pool.joined){
        cell=[tableView dequeueReusableCellWithIdentifier:@"PoolCellLeader"];
    }
    else{
        cell=[tableView dequeueReusableCellWithIdentifier:@"PoolCellCreator"];
    }
    if(cell == nil){
        if(pool.joined){
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"PoolCell" owner:self options:nil];
            cell = (PoolCell *)[nib objectAtIndex:1];
        }
        else{
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"PoolCell" owner:self options:nil];
            cell = (PoolCell *)[nib objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor clearColor];
        [cell.poolCreatorLeaderLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        [cell.poolRankLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        [cell.poolsNameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        [cell.poolsTypeLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
        [cell.dateLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
        [cell.numberParticipantsLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
        [cell.poolCreatorLeaderImageView.layer setCornerRadius:cell.poolCreatorLeaderImageView.bounds.size.width/2];
        [cell.poolCreatorLeaderInitialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        [cell.poolCreatorLeaderTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
        [cell.poolRankTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
        [cell.leaderPointsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:12.0]];
        [cell.userPointsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:12.0]];
    }
    if(pool.image){
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:pool.image]];
        __weak UIImageView *weakImageView = cell.poolImageView;
        weakImageView.image = nil;
        [cell.poolImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    if(pool.poolType && pool.poolType.image){
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:pool.poolType.image]];
        __weak UIImageView *weakImageView = cell.poolTypeImageView;
        weakImageView.image = nil;
        [cell.poolTypeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    cell.poolsNameLabel.text=pool.poolType.title.uppercaseString;
    NSString *strpoolsTypeLabel=[NSString stringWithFormat:@"Created by %@ %@",pool.creator.firstName,pool.creator.lastName];
    cell.poolsTypeLabel.text=strpoolsTypeLabel.uppercaseString;
    NSDate *poolActiveDate = [Utils dateFromGamblinoDateString:pool.poolType.activeAt];
    NSDate *poolEndDate = [Utils dateFromGamblinoDateString:pool.poolType.endsAt];
    
    NSDate *today= [NSDate date];
    if ([poolActiveDate laterDate:today] == poolActiveDate) {
        cell.dateLabel.text=[NSString stringWithFormat:@"STARTS %@",[Utils monthDayStringFromDate:poolActiveDate].uppercaseString];
    } else {
        cell.dateLabel.text=[NSString stringWithFormat:@"ENDS %@",[Utils monthDayStringFromDate:poolEndDate].uppercaseString];
    }
    
    cell.numberParticipantsLabel.text=[NSString stringWithFormat:@"%d MEMBERS",pool.totalUsers];
    
    if(pool.joined){
        cell.poolCreatorLeaderLabel.text=[NSString stringWithFormat:@"%@ %@",pool.leader.firstName?:@"",pool.leader.lastName?:@""].uppercaseString;
        if(pool.leader.picture && pool.leader.picture.length>0){
            cell.poolCreatorLeaderInitialsLabel.hidden = YES;
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:pool.leader.picture]];
            __weak UIImageView *weakImageView = cell.poolCreatorLeaderImageView;
            weakImageView.image = nil;
            [cell.poolCreatorLeaderImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            cell.poolCreatorLeaderInitialsLabel.hidden = NO;
            cell.poolCreatorLeaderImageView.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
            cell.poolCreatorLeaderInitialsLabel.text=[NSString stringWithFormat:@"%@%@",[pool.leader.firstName.uppercaseString substringToIndex:1],[pool.leader.lastName.uppercaseString substringToIndex:1]];
        }
        cell.poolRankLabel.text = [NSString stringWithFormat:@"%d / %d",pool.me.place,pool.totalUsers];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.usesGroupingSeparator = YES;
        numberFormatter.groupingSeparator = @",";
        numberFormatter.groupingSize = 3;
        cell.leaderPointsLabel.text = [NSString stringWithFormat:@"%@PTS",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:pool.leader.points.balance]]];
        cell.userPointsLabel.text = [NSString stringWithFormat:@"%@PTS",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:pool.me.points.balance]]];
    }
    else{
        cell.poolCreatorLeaderLabel.text=[NSString stringWithFormat:@"%@ %@",pool.creator.firstName?:@"",pool.creator.lastName?:@""].uppercaseString;
        if(pool.creator.picture && pool.creator.picture.length>0){
            cell.poolCreatorLeaderInitialsLabel.hidden = YES;
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:pool.creator.picture]];
            __weak UIImageView *weakImageView = cell.poolCreatorLeaderImageView;
            weakImageView.image = nil;
            [cell.poolCreatorLeaderImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            cell.poolCreatorLeaderInitialsLabel.hidden = NO;
            cell.poolCreatorLeaderImageView.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
            cell.poolCreatorLeaderInitialsLabel.text=[NSString stringWithFormat:@"%@%@",[pool.creator.firstName.uppercaseString substringToIndex:1],[pool.creator.lastName.uppercaseString substringToIndex:1]];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Pool *pool=[self.filteredPools objectAtIndex:indexPath.row];
    if(pool.joined){
        InputBetViewController *inputBetViewController;
        if(self.line){
            inputBetViewController=[[InputBetViewController alloc] initWithBackgroundImage:self.blurImage contest:nil pool:pool line:self.line game:self.game answer:nil];
        }
        else if(self.answer){
            inputBetViewController=[[InputBetViewController alloc] initWithBackgroundImage:self.blurImage contest:nil pool:pool line:self.line game:self.game answer:self.answer];
        }
        inputBetViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController presentViewController:inputBetViewController animated:YES completion:^{}];
        });
    }
    else{
        PoolsInfoViewController *poolsInfoViewController=[[PoolsInfoViewController alloc] initWithBackgroundImage:self.blurImage pool:pool];
        poolsInfoViewController.delegate=self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController presentViewController:poolsInfoViewController animated:YES completion:^{}];
        });

    }
}

-(void)poolsInfoViewController:(PoolsInfoViewController *)poolsInfoViewController didJoinPool:(Pool *)pool{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        InputBetViewController *inputBetViewController;
        if(self.line){
            inputBetViewController=[[InputBetViewController alloc] initWithBackgroundImage:self.blurImage contest:nil pool:pool line:self.line game:self.game answer:nil];
        }
        else if(self.answer){
            inputBetViewController=[[InputBetViewController alloc] initWithBackgroundImage:self.blurImage contest:nil pool:pool line:self.line game:self.game answer:self.answer];
        }
        inputBetViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController presentViewController:inputBetViewController animated:YES completion:^{}];
        });
    }];
}


@end
