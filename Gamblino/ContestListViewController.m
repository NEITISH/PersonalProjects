//
//  ContestListViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/28/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "ContestListViewController.h"
#import "ContestInfoViewController.h"
#import "InputBetViewController.h"
#import "PointBalance.h"
#import "Contest.h"
#import "ContestCell.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "League.h"
#import "Utils.h"
#import "LocationManager.h"
#import "Sponsor.h"


@interface ContestListViewController ()

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *contests;
@property (nonatomic,strong) NSArray *localContests;
@property (nonatomic,strong) NSArray *filteredContests;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) Line *line;
@property (nonatomic,strong) Event *game;
@property (nonatomic,strong) Answer *answer;
@property (nonatomic,assign) int remainingCallsToProcess;

@end

@implementation ContestListViewController

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
    self.remainingCallsToProcess=2;
    [self loadContests];
    [self loadLocalContests];
}

- (void)loadContests{
    NSString *remotePath=@"v2/contests";
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *contestsDictionary){
        if([contestsDictionary.allKeys containsObject:@"contests"]){
            NSArray *contestsValue=[contestsDictionary valueForKey:@"contests"];
            NSMutableArray *contestsArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in contestsValue){
                Contest *contest=[[Contest alloc] initWithDictionary:dic];
                [contestsArray addObject:contest];
            }
            self.contests=contestsArray;
        }
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [self doneLoadingContests];
        }
    }failureBlock:^(NSError *error){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [self doneLoadingContests];
        }
        NSLog(@"error=%@",error.description);
    }];
}

-(void)loadLocalContests{
    NSString *remotePath=@"v2/contests";
    NSDictionary *parameters=nil;
    if([[LocationManager sharedInstance] currentLocation]){
        NSNumber *lat=[NSNumber numberWithDouble:[LocationManager sharedInstance].currentLocation.coordinate.latitude];
        NSNumber *lon=[NSNumber numberWithDouble:[LocationManager sharedInstance].currentLocation.coordinate.longitude];
        parameters=@{@"lat":lat,@"lon":lon};
    }
    [[NetworkManager sharedInstance] GET:remotePath withParameters:parameters successBlock:^(NSDictionary *contestsDictionary){
        if([contestsDictionary.allKeys containsObject:@"contests"]){
            NSArray *contestsValue=[contestsDictionary valueForKey:@"contests"];
            NSMutableArray *localContestsArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in contestsValue){
                Contest *contest=[[Contest alloc] initWithDictionary:dic];
                if([contest.type isEqualToString:kContestTypeLocal]){
                    [localContestsArray addObject:contest];
                }
            }
            self.localContests=localContestsArray;
        }
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [self doneLoadingContests];
        }
    }failureBlock:^(NSError *error){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [self doneLoadingContests];
        }
        NSLog(@"error=%@",error.description);
    }];
}

- (void)doneLoadingContests{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self filterContestsForCurrentLeague];
}

- (void)filterContestsForCurrentLeague{
    NSMutableArray *filteredContests=[[NSMutableArray alloc] init];
    for(Contest *contest in self.contests){
        BOOL isLeagueInContest=NO;
        for(League *league in contest.leagues){
            if(league.leaguesIdentifier==self.game.leagueId){
                isLeagueInContest=YES;
            }
        }
        if(isLeagueInContest){
            [filteredContests addObject:contest];
        }
    }
    for(Contest *contest in self.localContests){
        BOOL isLeagueInContest=NO;
        for(League *league in contest.leagues){
            if(league.leaguesIdentifier==self.game.leagueId){
                isLeagueInContest=YES;
            }
        }
        if(isLeagueInContest){
            [filteredContests addObject:contest];
        }
    }
    self.filteredContests=filteredContests;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Contest *contest=[self.filteredContests objectAtIndex:indexPath.row];
    ContestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"ContestCell" owner:self options:nil];
        cell = (ContestCell *)[nib objectAtIndex:0];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.contestTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        [cell.pointBalanceTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
        [cell.maxBetTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
        [cell.pointBalanceLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:15.0]];
        [cell.maxBetLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:15.0]];
    }
    NSMutableURLRequest *request;
    if([contest.type isEqualToString:@"national"]){
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:contest.bigPictureUrl]];
    }
    else{
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:contest.sponsor.pictureUrl]];
    }
    __weak UIImageView *weakImageView = cell.contestImageView;
    weakImageView.image = nil;
    [weakImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
        [weakImageView setImage:image];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
    cell.contestTitleLabel.text=contest.title.uppercaseString;
    cell.joinNowButtonImageView.hidden=contest.joined;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.usesGroupingSeparator = YES;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    NSString *maxWagerString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:contest.maxWager]];
    NSString *pointsAvailable = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:contest.me.points.available]];
    cell.maxBetLabel.text=[NSString stringWithFormat:@"%@pts",maxWagerString];
    cell.pointBalanceLabel.text=[NSString stringWithFormat:@"%@pts",pointsAvailable];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Contest *contest=[self.filteredContests objectAtIndex:indexPath.row];
    if(contest.joined){
        InputBetViewController *inputBetViewController;
        if(self.line){
            inputBetViewController=[[InputBetViewController alloc] initWithBackgroundImage:self.blurImage contest:contest pool:nil line:self.line game:self.game answer:nil];
        }
        else if(self.answer){
            inputBetViewController=[[InputBetViewController alloc] initWithBackgroundImage:self.blurImage contest:contest pool:nil line:self.line game:self.game answer:self.answer];
        }
        inputBetViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController presentViewController:inputBetViewController animated:YES completion:^{}];
        });
    }
    else{
        ContestInfoViewController *contestInfoViewController=[[ContestInfoViewController alloc] initWithBackgroundImage:self.blurImage contest:contest game:self.game];
        contestInfoViewController.delegate = self;
        contestInfoViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController presentViewController:contestInfoViewController animated:YES completion:^{}];
        });
    }
}

-(void)contestInfoViewController:(ContestInfoViewController *)contestInfoViewController didJoinContest:(Contest *)contest{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        InputBetViewController *inputBetViewController;
        if(self.line){
            inputBetViewController=[[InputBetViewController alloc] initWithBackgroundImage:self.blurImage contest:contest pool:nil line:self.line game:self.game answer:nil];
        }
        else if(self.answer){
            inputBetViewController=[[InputBetViewController alloc] initWithBackgroundImage:self.blurImage contest:contest pool:nil line:self.line game:self.game answer:self.answer];
        }
        inputBetViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController presentViewController:inputBetViewController animated:YES completion:^{}];
        });
    }];
}

@end
