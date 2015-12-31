//
//  LeaguesViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/12/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "LeaguesViewController.h"
#import "League.h"
#import "LeaguesCell.h"
#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "GameListViewController.h"

@interface LeaguesViewController ()

@property(nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSArray *leagues;

@end

@implementation LeaguesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLeagues) name:@"NotificationDidLoginSucceed" object:nil];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0] forKey:UITextAttributeFont];
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.leagues=[[NSArray alloc] init];
    [self loadLeagues];
}

-(void)loadLeagues{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] GET:@"leagues" withParameters:nil successBlock:^(NSDictionary *leaguesDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([leaguesDictionary.allKeys containsObject:@"leagues"]){
            NSArray *leaguesValue=[leaguesDictionary valueForKey:@"leagues"];
            NSMutableArray *leaguesArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in leaguesValue){
                League *league=[[League alloc] initWithDictionary:dic];
                [leaguesArray addObject:league];
            }
            self.leagues=leaguesArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.leagues count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    League *league=[self.leagues objectAtIndex:indexPath.row];
    LeaguesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"LeaguesCell" owner:self options:nil];
        cell = (LeaguesCell *)[nib objectAtIndex:0];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.nameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    }
    cell.nameLabel.text=league.nickname;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    League *league=[self.leagues objectAtIndex:indexPath.row];
    GameListViewController *gameListViewController=[[GameListViewController alloc] init];
    gameListViewController.league=league;
    gameListViewController.title=league.nickname;
    [self.navigationController pushViewController:gameListViewController animated:YES];
}


@end
