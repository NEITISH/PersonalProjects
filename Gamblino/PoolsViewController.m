//
//  PoolsViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 3/15/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "PoolsViewController.h"
#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "Pool.h"
#import "PoolCell.h"
#import "SelectPoolTypeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PoolType.h"
#import "Utils.h"
#import "PoolDetailsViewController.h"
#import "UIView+Blur.h"
#import "PoolsInfoViewController.h"
#import "UIView+Blur.h"
#import "AnalyticsManager.h"
#define SearchBarHeight 50

@interface PoolsViewController (){
   
}

@property (nonatomic,weak) IBOutlet UILabel *noActivePoolsLabel;
@property (nonatomic,weak) IBOutlet UILabel *tapButtonBelowMessage;

@property (nonatomic,weak) IBOutlet UIView *noActivePoolView;

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *pools;

@property (strong,nonatomic) UISearchBar *searchPoolsByIdBar;
@property(nonatomic,strong) UITapGestureRecognizer *tapRecognizer;


@end

@implementation PoolsViewController

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
    [Flurry logEvent:@"Pools Screen Loaded"];
    [self.noActivePoolsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    
    self.searchPoolsByIdBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0,44,self.view.frame.size.width, 44)];
    [self.searchPoolsByIdBar setBackgroundImage:[UIImage imageNamed:@"searchBarBackground"]];
    self.searchPoolsByIdBar.delegate=self;
    self.searchPoolsByIdBar.placeholder=@"Search Pool ID";
    self.view.userInteractionEnabled = TRUE;
    self.tableView.tableHeaderView=self.searchPoolsByIdBar;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadPools:@""];
}

-(void)loadPools:(NSString *)searchString{
    
    [self.view endEditing:YES];
    
    NSString *remotePath=@"pools";
    if(searchString.length>0 && searchString!=nil){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        remotePath=[NSString stringWithFormat:@"pools/%@",searchString];
    }
    
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *poolsDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if([poolsDictionary.allKeys containsObject:@"pools"]){
            NSArray *poolsValue=[poolsDictionary valueForKey:@"pools"];
            NSMutableArray *poolsArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in poolsValue){
                Pool *pool=[[Pool alloc] initWithDictionary:dic];
                [poolsArray addObject:pool];
            }
            
            self.pools=poolsArray;
            if(poolsArray.count>0){
                self.tableView.hidden=NO;
                [self.tableView reloadData];
                self.noActivePoolView.hidden=YES;
            }
            else{
                [self.tableView reloadData];
                self.tableView.hidden=NO;
                self.noActivePoolView.hidden=NO;
                self.noActivePoolView.frame=CGRectMake(0,self.tableView.frame.origin.y+SearchBarHeight,self.tableView.frame.size.width, self.tableView.frame.size.width);
               
                CGRect frameNAPV=CGRectMake(0,(self.tableView.frame.size.height/2)-SearchBarHeight,self.noActivePoolsLabel.frame.size.width, self.noActivePoolsLabel.frame.size.height);
                self.noActivePoolsLabel.frame=frameNAPV;
                self.tapButtonBelowMessage.frame=CGRectMake(20, self.noActivePoolsLabel.frame.origin.y+20,self.tapButtonBelowMessage.frame.size.width, self.tapButtonBelowMessage.frame.size.height);
            }
        }
        //Search Result
        if([poolsDictionary.allKeys containsObject:@"pool"]){
            NSMutableArray *poolsArray=[[NSMutableArray alloc] init];
            Pool *pool=[[Pool alloc] initWithDictionary:[poolsDictionary objectForKey:@"pool"]];
            [poolsArray addObject:pool];
            self.pools=poolsArray;
            if(poolsArray.count>0){
                self.tableView.hidden=NO;
                [self.tableView reloadData];
                self.noActivePoolView.hidden=YES;
            }
            else{
                self.tableView.hidden=YES;
                self.noActivePoolView.hidden=NO;
            }
        }
        
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString *errorMsg=[NSString stringWithFormat:@"%@",error.description];
        if([errorMsg isEqualToString:@"Pool not found"]){
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gamblino"
                                                            message:@"No matching Pool ID was found. Please note that Pool IDs are CASE SENSITIVE."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        NSLog(@"error=%@",error.description);
    }];
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pools.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Pool *pool=[self.pools objectAtIndex:indexPath.row];
    
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
    
    //NSDate *poolStartDate = [Utils dateFromGamblinoDateString:pool.poolType.startAt];
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
            cell.poolCreatorLeaderImageView.image=nil;
            cell.poolCreatorLeaderImageView.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
            cell.poolCreatorLeaderInitialsLabel.text=[NSString stringWithFormat:@"%@%@",[pool.leader.firstName.uppercaseString substringToIndex:1],[pool.leader.lastName.uppercaseString substringToIndex:1]];
            cell.poolCreatorLeaderInitialsLabel.tag=indexPath.row;
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
    Pool *pool=[self.pools objectAtIndex:indexPath.row];
    if(pool.joined){
        UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
        PoolDetailsViewController *poolDetailsViewController = [[PoolDetailsViewController alloc] initWithBackgroundImage:blurImage pool:pool];
        UINavigationController *poolDetailsNavigationController = [[UINavigationController alloc] initWithRootViewController:poolDetailsViewController];
        [poolDetailsNavigationController setNavigationBarHidden:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController presentViewController:poolDetailsNavigationController animated:YES completion:^{}];
        });
    }
    else{
        UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
        PoolsInfoViewController *poolsInfoViewController=[[PoolsInfoViewController alloc] initWithBackgroundImage:blurImage pool:pool];
        poolsInfoViewController.delegate=self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController presentViewController:poolsInfoViewController animated:YES completion:^{}];
        });
    }
}


-(void)keyboardWillShow:(NSNotification*)notification{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.parentViewController.view addGestureRecognizer:self.tapRecognizer];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    if(self.tapRecognizer){
        [self.parentViewController.view removeGestureRecognizer:self.tapRecognizer];
    }
}

- (void)dismissKeyboard{
    [self.searchPoolsByIdBar resignFirstResponder];
    if(self.searchPoolsByIdBar.text.length==0){
        [self loadPools:@""];
    }else if(self.searchPoolsByIdBar.text.length>0){
        [self.searchPoolsByIdBar resignFirstResponder];
        [self loadPools:self.searchPoolsByIdBar.text];
    }
}



-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
   
    if ([searchText length]>0) {
        //[self searchGamblinoUsers];
    } else {
        [self.searchPoolsByIdBar resignFirstResponder];
        [self.view endEditing:YES];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadPools:@""];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //[self loadPools:nil];
    [searchBar resignFirstResponder];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self loadPools:searchBar.text];
}


#pragma mark - Custom Actions

-(IBAction)createPoolAction:(id)sender{
    SelectPoolTypeViewController *selectPoolTypeViewController=[[SelectPoolTypeViewController alloc] init];
    UINavigationController *selectPoolNavigationController=[[UINavigationController alloc] initWithRootViewController:selectPoolTypeViewController];
    selectPoolNavigationController.navigationBarHidden=YES;
    [self presentViewController:selectPoolNavigationController animated:YES completion:^{}];
}

-(void)poolsInfoViewController:(PoolsInfoViewController *)poolsInfoViewController didJoinPool:(Pool *)pool{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
        PoolDetailsViewController *poolDetailsViewController=[[PoolDetailsViewController alloc] initWithBackgroundImage:blurImage pool:pool];
        UINavigationController *poolDetailsNavigationViewController=[[UINavigationController alloc] initWithRootViewController:poolDetailsViewController];
        poolDetailsNavigationViewController.navigationBarHidden=YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:poolDetailsNavigationViewController animated:YES completion:^{}];
        });
    }];
}

@end
