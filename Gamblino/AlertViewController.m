//
//  AlertViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/20/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "AlertViewController.h"
#import "NetworkManager.h"
#import "Notification.h"
#import "User.h"
#import "FriendRequestCell.h"
#import "UIImageView+AFNetworking.h"
#import "PrizeCell.h"
#import "Contest.h"
#import "MBProgressHUD.h"
#import "Prize.h"
#import "RedeemedViewController.h"
#import "PoolInviteCell.h"
#import "Pool.h"
#import "PoolType.h"
#import "Utils.h"
#import "AnalyticsManager.h"

@interface AlertViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *blurImageView;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic,weak) IBOutlet UILabel *noNotificationsLabel;
@property (nonatomic,strong) NSArray *notifications;
@property (nonatomic,strong) NSArray *prizes;
@property (nonatomic,strong) NSArray *notificationPrizesArrayForTable;

@property(nonatomic,strong) NSTimer *timer;

@end

@implementation AlertViewController

- (id)initWithBackgroundImage:(UIImage*)image{
    self = [super init];
    if(self){
        self.blurImage=image;
        [self loadNotifications];
        self.timer=[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(loadNotifications) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"Alert Screen Loaded"];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.noNotificationsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0] forKey:UITextAttributeFont];
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.blurImageView setImage:self.blurImage];
}

-(void)dealloc{
    [self.timer invalidate];
    self.timer=nil;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)segmentedControlValueDidChange:(id)sender{
    [self.tableView reloadData];
}

- (IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)loadNotifications{
    NSString *remotePath=@"notifications";
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *notificationsDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([notificationsDictionary.allKeys containsObject:@"notifications"]){
            NSArray *notificationsValue=[notificationsDictionary valueForKey:@"notifications"];
            NSMutableArray *notificationsArray=[[NSMutableArray alloc] init];
            NSMutableArray *prizesArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in notificationsValue){
                Notification *notification=[[Notification alloc] initWithDictionary:dic];
                if([notification.context isEqualToString:@"prize"]){
                    [prizesArray addObject:notification];
                }
                else{
                    if([notification.context isEqualToString:@"pool"]){
                        if(!notification.pool.joined){
                            [notificationsArray addObject:notification];
                        }
                    }
                    if([notification.context isEqualToString:@"friend"]){
                        if([notification.friend.friendship isEqualToString:@"requested"]){
                            [notificationsArray addObject:notification];
                        }
                    }
                }
            }
            self.notifications=notificationsArray;
            self.prizes=prizesArray;
            [self.tableView reloadData];
            [self updateNotificationCount];
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

- (void)updateNotificationCount{
    int notificationCount = 0;
    if(self.notifications){
        notificationCount += self.notifications.count;
    }
    for(Notification *notification in self.prizes){
        if(notification.prize.redeemable && !notification.prize.redeemed){
            notificationCount ++;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateNotificationCount" object:[NSNumber numberWithInt:notificationCount]];
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    
    if(self.segmentedControl.selectedSegmentIndex==0){
        self.notificationPrizesArrayForTable=[self.notifications mutableCopy];
        numberOfRows = self.notificationPrizesArrayForTable.count;
        self.noNotificationsLabel.text=@"NO NOTIFICATIONS";
    }
    else{
        self.notificationPrizesArrayForTable=[self.prizes mutableCopy];
        numberOfRows = self.notificationPrizesArrayForTable.count;
        self.noNotificationsLabel.text=@"NO REWARDS";
    }
    if(numberOfRows == 0){
        self.noNotificationsLabel.hidden=NO;
    }
    else{
        self.noNotificationsLabel.hidden=YES;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.segmentedControl.selectedSegmentIndex==0){
        Notification *notification=[self.notificationPrizesArrayForTable objectAtIndex:indexPath.row];
        if([notification.context isEqualToString:@"pool"]){
            return 170.0;
        }
    }
    return 88.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.segmentedControl.selectedSegmentIndex==0){
        Notification *notification=[self.notificationPrizesArrayForTable objectAtIndex:indexPath.row];
        if([notification.context isEqualToString:@"friend"]){
            FriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestCell"];
            if (cell == nil) {
                NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"FriendRequestCell" owner:self options:nil];
                cell = (FriendRequestCell *)[nib objectAtIndex:0];
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell.userImageView.layer setCornerRadius:cell.userImageView.bounds.size.width/2];
                [cell.requestTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
                [cell.nameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                [cell.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                cell.delegate=self;
            }
            if(notification.friend.picture && notification.friend.picture.length>0){
                cell.initialsLabel.hidden=YES;
                cell.userImageView.backgroundColor=[UIColor blackColor];
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:notification.friend.picture]];
                __weak UIImageView *weakImageView = cell.userImageView;
                weakImageView.image = nil;
                [cell.userImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                    [weakImageView setImage:image];
                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    NSLog(@"error=%@",[error description]);
                }];
            }
            else{
                cell.userImageView.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
                cell.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[notification.friend.firstName.uppercaseString substringToIndex:1],[notification.friend.lastName.uppercaseString substringToIndex:1]];
                cell.initialsLabel.hidden=NO;
            }
            cell.nameLabel.text=[NSString stringWithFormat:@"%@ %@",notification.friend.firstName.uppercaseString,notification.friend.lastName.uppercaseString];
            return cell;
        }
        else if([notification.context isEqualToString:@"pool"]){
            PoolInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PoolInviteCell"];
            if (cell == nil) {
                NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"PoolInviteCell" owner:self options:nil];
                cell = (PoolInviteCell *)[nib objectAtIndex:0];
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell.poolCreatorLeaderLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                [cell.poolsNameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                [cell.poolsTypeLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
                [cell.dateLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
                [cell.numberParticipantsLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
                [cell.poolCreatorLeaderImageView.layer setCornerRadius:cell.poolCreatorLeaderImageView.bounds.size.width/2];
                [cell.poolCreatorLeaderInitialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                [cell.poolCreatorLeaderTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
            }
            if(notification.pool.image){
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:notification.pool.image]];
                __weak UIImageView *weakImageView = cell.poolImageView;
                weakImageView.image = nil;
                [cell.poolImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                    [weakImageView setImage:image];
                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    NSLog(@"error=%@",[error description]);
                }];
            }
            if(notification.pool.poolType && notification.pool.poolType.image){
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:notification.pool.poolType.image]];
                __weak UIImageView *weakImageView = cell.poolTypeImageView;
                weakImageView.image = nil;
                [cell.poolTypeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                    [weakImageView setImage:image];
                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    NSLog(@"error=%@",[error description]);
                }];
            }
            cell.poolsNameLabel.text=notification.pool.title.uppercaseString;
            cell.poolsTypeLabel.text=notification.pool.poolType.title.uppercaseString;
            NSDate *poolStartDate = [Utils dateFromGamblinoDateString:notification.pool.poolType.activeAt];
            NSDate *poolEndDate = [Utils dateFromGamblinoDateString:notification.pool.poolType.endsAt];
            NSDate *today= [NSDate date];
            if([today laterDate:poolStartDate]){
                cell.dateLabel.text=[NSString stringWithFormat:@"ENDS %@",[Utils monthDayStringFromDate:poolEndDate].uppercaseString];
            }
            else{
                cell.dateLabel.text=[NSString stringWithFormat:@"STARTS %@",[Utils monthDayStringFromDate:poolStartDate].uppercaseString];
            }
            cell.numberParticipantsLabel.text=[NSString stringWithFormat:@"%d MEMBERS",notification.pool.totalUsers];
            
            cell.poolCreatorLeaderLabel.text=[NSString stringWithFormat:@"%@ %@",notification.pool.creator.firstName?:@"",notification.pool.creator.lastName?:@""].uppercaseString;
            if(notification.pool.creator.picture && notification.pool.creator.picture.length>0){
                cell.poolCreatorLeaderInitialsLabel.hidden = YES;
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:notification.pool.creator.picture]];
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
                cell.poolCreatorLeaderInitialsLabel.text=[NSString stringWithFormat:@"%@%@",[notification.pool.creator.firstName.uppercaseString substringToIndex:1],[notification.pool.creator.lastName.uppercaseString substringToIndex:1]];
            }
            
            return cell;
        }
        return nil;
    }
    else{
        Notification *notification=[self.notificationPrizesArrayForTable objectAtIndex:indexPath.row];
        PrizeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrizeCell"];
        if (cell == nil) {
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"PrizeCell" owner:self options:nil];
            cell = (PrizeCell *)[nib objectAtIndex:0];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.contestImageView.layer setCornerRadius:cell.contestImageView.bounds.size.width/2];
            [cell.redeemableMessageLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
            [cell.contestTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.redeemedLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
            [cell.expiredLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
            cell.delegate=self;
        }
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:notification.contest.pictureUrl]];
        __weak UIImageView *weakImageView = cell.contestImageView;
        weakImageView.image = nil;
        [cell.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
        cell.contestTitleLabel.text=notification.contest.title.uppercaseString;
        cell.redeemableMessageLabel.text=notification.prize.redeemableMessage;
        cell.descriptionLabel.text=notification.prize.prizeDescription;
        if(notification.prize.redeemed){
            cell.redeemedLabel.hidden=NO;
            cell.expiredLabel.hidden=YES;
            cell.redeemButton.hidden=YES;
        }
        else{
            cell.redeemedLabel.hidden=YES;
            if(notification.prize.redeemable){
                cell.redeemButton.hidden=NO;
                cell.expiredLabel.hidden=YES;
            }
            else{
                cell.redeemButton.hidden=YES;
                cell.expiredLabel.hidden=NO;
            }
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.segmentedControl.selectedSegmentIndex==0){
            Notification *notification=[self.notificationPrizesArrayForTable objectAtIndex:indexPath.row];
            if([notification.context isEqualToString:@"pool"]){
                [self dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissModalAndOpenPool" object:nil userInfo:nil];
                }];
            }
        }
    });
}

- (void)friendRequestCellDidAccept:(FriendRequestCell *)friendRequestCell{
    NSInteger index=[self.tableView indexPathForCell:friendRequestCell].row;
    Notification *notification = [self.notificationPrizesArrayForTable objectAtIndex:index];
    NSString *remotePath=[NSString stringWithFormat:@"friends/%d",notification.friend.usersIdentifier];
    NSDictionary *parameters=@{@"status":@"approved"};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] PUT:remotePath withParameters:parameters successBlock:^(NSDictionary *notificationsDictionary){
        [self loadNotifications];
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

- (void)friendRequestCellDidDecline:(FriendRequestCell *)friendRequestCell{
    NSInteger index=[self.tableView indexPathForCell:friendRequestCell].row;
    Notification *notification = [self.notificationPrizesArrayForTable objectAtIndex:index];
    NSString *remotePath=[NSString stringWithFormat:@"friends/%d",notification.friend.usersIdentifier];
    NSDictionary *parameters=@{@"status":@"denied"};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] PUT:remotePath withParameters:parameters successBlock:^(NSDictionary *notificationsDictionary){
        [self loadNotifications];
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

- (void)prizeCellDidRedeem:(PrizeCell *)prizeCell{
    NSInteger index=[self.tableView indexPathForCell:prizeCell].row;
    Notification *notification = [self.notificationPrizesArrayForTable objectAtIndex:index];
    NSString *remotePath=[NSString stringWithFormat:@"prizes/%d/redeem",notification.prize.prizeIdentifier];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] PUT:remotePath withParameters:nil successBlock:^(NSDictionary *notificationsDictionary){
        [self loadNotifications];
        RedeemedViewController *redeemedViewController=[[RedeemedViewController alloc] initWithBackgroundImage:self.blurImage notification:notification];
        [self presentViewController:redeemedViewController animated:YES completion:^{}];
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

@end
