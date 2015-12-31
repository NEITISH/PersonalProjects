//
//  ContestDetailsViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/10/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "ContestDetailsViewController.h"
#import "Utils.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "LeaderboardScrollCell.h"
#import "LeaderboardSubview.h"
#import "LeaderBoardMixedSubview.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "Wager.h"
#import "MyWagersDetailCell.h"
#import "Constants.h"
#import "UIColor+Gamblino.h"
#import "Event.h"
#import "MyProfileViewController.h"
#import "Answer.h"
#import "NoWagerCell.h"
#import "AnalyticsManager.h"
#import "MyWagersDetailViewController.h"
#import "LeaderBoardDetailView.h"

#define kLoadingCellTag 123456

@interface ContestDetailsViewController (){
    int MAX_COUNT;
}
@property (nonatomic,weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic,weak) IBOutlet UILabel *scoreTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *placeTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *inPlayTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *winLossTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic,weak) IBOutlet UILabel *placeLabel;
@property (nonatomic,weak) IBOutlet UILabel *inPlayLabel;
@property (nonatomic,weak) IBOutlet UILabel *winLossLabel;
@property (nonatomic,weak) IBOutlet UILabel *initialsLabel;
@property (nonatomic,strong) Contest *contest;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) NSArray *leaderBoard;
@property (nonatomic,strong) NSArray *wagers;
@property (nonatomic,assign) int remainingCallsToProcess;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong) NSString *nextPageURL;
@property(nonatomic,weak) MyWagersDetailViewController *wagerDetailViewController;
- (IBAction)info:(id)sender;


@end

@implementation ContestDetailsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"Contest Detail Screen Loaded"];
    [self.backgroundImageView setImage:self.blurImage];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.scoreTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.placeTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.inPlayTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.winLossTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.scoreLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.placeLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.inPlayLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.winLossLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.profileImageView.layer setCornerRadius:self.profileImageView.bounds.size.width/2];
    [self.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:48.0]];

    self.remainingCallsToProcess=2;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.currentPage=0;
    MAX_COUNT=0;
    self.nextPageURL=@"";
    [self loadContest];
    [self loadWagers];
}

- (id)initWithBackgroundImage:(UIImage*)image contest:(Contest*)contest{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.contest=contest;
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)loadContest{
    NSString *remotePath=[NSString stringWithFormat:@"v2/contests/%d",self.contest.contestIdentifier];
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *contestDictionary){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        if([contestDictionary.allKeys containsObject:@"contest"]){
            NSDictionary *contestValue=[contestDictionary valueForKey:@"contest"];
            self.contest = [[Contest alloc] initWithDictionary:contestValue];
            [self displayContest];
        }
    }failureBlock:^(NSError *error){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        NSLog(@"error=%@",error.description);
    }];
}

-(void)displayContest {
    self.titleLabel.text=self.contest.title.uppercaseString;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.usesGroupingSeparator = YES;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    self.scoreLabel.text=[numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.contest.me.points.balance]];
    self.inPlayLabel.text=[numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.contest.me.points.balance-self.contest.me.points.available]];
    
    [self calculateLeaderboard];
    
    NSString *placeString = [Utils shortStringForInt:self.contest.me.place];
    NSString *totalString = [Utils shortStringForInt:self.contest.totalUsers];
    self.placeLabel.text=[NSString stringWithFormat:@"%@/%@",placeString,totalString];
        
    User *currentUser = self.contest.me.user;
    if(currentUser.picture && currentUser.picture.length>0){
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:currentUser.picture]];
        __weak UIImageView *weakImageView = self.profileImageView;
        weakImageView.image = nil;
        [self.profileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    else{
        [self.profileImageView setImage:nil];
        [self.profileImageView setBackgroundColor:[UIColor clearColor]];
        self.profileImageView.layer.borderColor=[UIColor whiteColor].CGColor;
        self.profileImageView.layer.borderWidth=4.0f;
        self.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[currentUser.firstName.uppercaseString substringToIndex:1],[currentUser.lastName.uppercaseString substringToIndex:1]];
        self.initialsLabel.hidden=NO;
    }
    
    NSString *winString = [Utils shortStringForInt:self.contest.me.wins];
    NSString *lossString = [Utils shortStringForInt:self.contest.me.loss];
    self.winLossLabel.text=[NSString stringWithFormat:@"%@ - %@",winString,lossString];
    
    [self.tableView reloadData];
}

-(void)loadWagers{
    NSString *remotePath=@"";
    if(self.currentPage==0){
        remotePath = @"v3/wagers";
    }
    else if(self.currentPage > 0){
        remotePath=self.nextPageURL;
    }
    
    [[NetworkManager sharedInstance] GET:remotePath withParameters:@{@"context":@"contest",@"context_id":[NSNumber numberWithInt:self.contest.contestIdentifier],@"status":@"upcoming|in-progress|scheduled|suspended|delay-rain|delay-other|complete|postponed",@"sort":@"DESC"} successBlock:^(NSDictionary *wagersDictionary){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        if([wagersDictionary.allKeys containsObject:@"pagination"]){
            NSDictionary *paginationValue=[wagersDictionary valueForKey:@"pagination"];
            self.nextPageURL=[paginationValue objectForKey:@"next_page"];
            if(self.nextPageURL==0 || [self.nextPageURL isKindOfClass:[NSNull class]] || [self.nextPageURL isEqualToString:@""]||[self.nextPageURL  isEqualToString:NULL]||[self.nextPageURL isEqualToString:@"(null)"]||self.nextPageURL==nil || [self.nextPageURL isEqualToString:@"<null>"]){
                self.currentPage=0;
            }else{
                self.currentPage++;
            }
        }
        
        if([wagersDictionary.allKeys containsObject:@"wagers"]){
            NSArray *wagersValue=[wagersDictionary valueForKey:@"wagers"];
            NSMutableArray *wagersArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in wagersValue){
                Wager *wager=[[Wager alloc] initWithDictionary:dic];
                if(wager.contest.contestIdentifier==self.contest.contestIdentifier){
                    [wagersArray addObject:wager];
                }
            }
            
            //Logic to check if data alreay exists in global array afer that
            //if new wagers are added in wagersArray
            //Add those to Global Array
            
            if(self.wagers.count>0 && wagersArray.count>0){
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.wagers];
                [tempArray addObjectsFromArray:wagersArray];
                self.wagers=[tempArray mutableCopy];
            }else if(self.currentPage>0 && wagersArray.count==0){
                self.currentPage=0;
            }else{
                if(wagersArray.count>0){
                    self.wagers=wagersArray;
                }
            }
            
            [self.tableView reloadData];
        }
    }failureBlock:^(NSError *error){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        NSLog(@"error=%@",error.description);
    }];
}

-(IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return 1;
    }
    else if(section==1){
        int count=0;
        if(self.currentPage>0){
            count=(int)(self.wagers.count+1);
        }else if(self.currentPage==0 && self.wagers.count>0) {
            count=(int)self.wagers.count;
        }else{
            count=1;
        }
        return count;
        //return self.wagers.count>0?self.wagers.count+1:1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return 152.0;
    }
    else{
        if(indexPath.row==[self.wagers count] && self.currentPage>0){
            return 44;
        }
        else if(self.wagers.count>0){
            return 96.0;
        }
        else{
            return 185.0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return 0.0f;
    } else {
        return 40.0f;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 40.0)];
    headerView.backgroundColor=[UIColor clearColor];
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 30.0)];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, 300.0, 30.0)];
    [view setBackgroundColor:[UIColor colorWithRed:201.0/255.0 green:194.0/255.0 blue:178.0/255.0 alpha:1.0]];
    [label setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:15.0]];
    [label setTextColor:[UIColor colorWithRed:247.0/255.0 green:244.0/255.0 blue:238.0/255.0 alpha:1.0]];
    label.text=@"MY WAGERS";
    [view addSubview:label];
    [headerView addSubview:view];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0){
        LeaderboardScrollCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeaderboardScrollCell"];
        if (cell == nil) {
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"LeaderboardScrollCell" owner:self options:nil];
            cell = (LeaderboardScrollCell *)[nib objectAtIndex:0];
            cell.scrollView.delegate=self;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapAction:)];
            [recognizer setNumberOfTapsRequired:1];
            cell.scrollView.userInteractionEnabled = YES;
            [cell.scrollView addGestureRecognizer:recognizer];
            [cell.leaderboardLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]];
        }
        for(UIView *subview in cell.scrollView.subviews){
            [subview removeFromSuperview];
        }
        cell.scrollView.contentSize=CGSizeMake(0, cell.scrollView.bounds.size.height);
        
        int loopcount = 0;
        
        if([self.leaderBoard count]>10){
            MAX_COUNT=10;
        }
        else if([self.leaderBoard count]<10){
            MAX_COUNT=(int)[self.leaderBoard count];
        }
        for(User *user in self.leaderBoard){
            
            loopcount++;
            
            if(loopcount<=MAX_COUNT){
            
            NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"LeaderboardSubview" owner:self options:nil];
            LeaderboardSubview *leaderboardSubview = [subviewArray objectAtIndex:0];
            cell.scrollView.contentSize=CGSizeMake(cell.scrollView.contentSize.width+leaderboardSubview.bounds.size.width, cell.scrollView.bounds.size.height);
            [leaderboardSubview.nameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [leaderboardSubview.pointsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:12.0]];
            [leaderboardSubview.positionLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
            [leaderboardSubview.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [leaderboardSubview.imageView.layer setCornerRadius:leaderboardSubview.imageView.bounds.size.width/2];
            
            if(user.picture && user.picture.length>0){
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:user.picture]];
                __weak UIImageView *weakImageView = leaderboardSubview.imageView;
                weakImageView.image = nil;
                [leaderboardSubview.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                    [weakImageView setImage:image];
                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    NSLog(@"error=%@",[error description]);
                }];
            }
            else{
                leaderboardSubview.imageView.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
                leaderboardSubview.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[user.firstName.uppercaseString substringToIndex:1],[user.lastName.uppercaseString substringToIndex:1]];
                leaderboardSubview.initialsLabel.hidden=NO;
            }
            
            leaderboardSubview.nameLabel.text=user.firstName.uppercaseString;
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            numberFormatter.usesGroupingSeparator = YES;
            numberFormatter.groupingSeparator = @",";
            numberFormatter.groupingSize = 3;
            leaderboardSubview.pointsLabel.text=[NSString stringWithFormat:@"%@PTS",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:user.points.balance]]];
            int position=(int)[self.leaderBoard indexOfObject:user];
            leaderboardSubview.positionLabel.text=[Utils addSuffixToNumber:position+1].uppercaseString;
            leaderboardSubview.frame=CGRectMake(leaderboardSubview.bounds.size.width*position, 0, leaderboardSubview.bounds.size.width, cell.scrollView.bounds.size.height);
            [cell.scrollView addSubview:leaderboardSubview];
            }
            
            if(loopcount==MAX_COUNT){
                NSArray *subviewAr = [[NSBundle mainBundle] loadNibNamed:@"LeaderBoardMixedSubview" owner:self options:nil];
                LeaderBoardMixedSubview *leaderboardmixedSubview = [subviewAr objectAtIndex:0];
                cell.scrollView.contentSize=CGSizeMake(cell.scrollView.contentSize.width+leaderboardmixedSubview.bounds.size.width, cell.scrollView.bounds.size.height);
                leaderboardmixedSubview.frame=CGRectMake(118*loopcount+1,0,leaderboardmixedSubview.bounds.size.width,cell.scrollView.bounds.size.height);
                
                
                leaderboardmixedSubview.image0.layer.cornerRadius = 24.0f;
                leaderboardmixedSubview.image1.layer.cornerRadius = 19.0f;
                leaderboardmixedSubview.image2.layer.cornerRadius = 19.0f;
                
                leaderboardmixedSubview.image0.layer.masksToBounds = YES;
                leaderboardmixedSubview.image1.layer.masksToBounds = YES;
                leaderboardmixedSubview.image2.layer.masksToBounds = YES;
                
                leaderboardmixedSubview.Label0.layer.cornerRadius = 24.0f;
                leaderboardmixedSubview.Label0.layer.masksToBounds = YES;
                
                
                leaderboardmixedSubview.Label1.layer.cornerRadius = 19.0f;
                leaderboardmixedSubview.Label1.layer.masksToBounds = YES;
                
                leaderboardmixedSubview.Label2.layer.cornerRadius = 19.0f;
                leaderboardmixedSubview.Label2.layer.masksToBounds = YES;
                
                [leaderboardmixedSubview.Leaderboard setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                [leaderboardmixedSubview.Viewfull setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];

                
                User *UsersRankedOne=[self.leaderBoard objectAtIndex:0];
                User *UsersRankedTwo=nil;
                User *UsersRankedThree=nil;
                
                
                if(UsersRankedOne.picture && UsersRankedOne.picture.length>0){
                    
                    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:UsersRankedOne.picture]];
                    
                    __weak UIImageView *weakImageView = leaderboardmixedSubview.image0;
                    weakImageView.image = nil;
                    
                    [leaderboardmixedSubview.image0 setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                        [weakImageView setImage:image];
                    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                        NSLog(@"error=%@",[error description]);
                    }];
                }
                
                else{
                    leaderboardmixedSubview.image0.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
                    [leaderboardmixedSubview.Label0 setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];

                    leaderboardmixedSubview.Label0.text=[NSString stringWithFormat:@"%@%@",[UsersRankedOne.firstName.uppercaseString substringToIndex:1],[UsersRankedOne.lastName.uppercaseString substringToIndex:1]];
                    leaderboardmixedSubview.Label0.hidden=NO;
                }
                
                //forImage1
                if(self.leaderBoard.count>=2){
                    UsersRankedTwo=[self.leaderBoard objectAtIndex:1];
                }

                
                if (UsersRankedTwo!=nil) {
                    if(UsersRankedTwo.picture && UsersRankedTwo.picture.length>0){
                        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:UsersRankedTwo.picture]];
                        
                        __weak UIImageView *weakImageView = leaderboardmixedSubview.image1;
                        weakImageView.image = nil;
                        
                        [leaderboardmixedSubview.image1 setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                            [weakImageView setImage:image];
                        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                            NSLog(@"error=%@",[error description]);
                        }];
                    }
                
                    else if(UsersRankedTwo.picture==nil || UsersRankedTwo.picture.length == 0){
                        leaderboardmixedSubview.image1.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
                        [leaderboardmixedSubview.Label1 setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                        leaderboardmixedSubview.Label1.text=[NSString stringWithFormat:@"%@%@",[UsersRankedTwo.firstName.uppercaseString substringToIndex:1],[UsersRankedTwo.lastName.uppercaseString substringToIndex:1]];
                        leaderboardmixedSubview.Label1.hidden=NO;
                    }
                }else{
                    leaderboardmixedSubview.image1.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
                    
                    [leaderboardmixedSubview.Label1 setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                    leaderboardmixedSubview.Label1.text=@"2nd";
                    leaderboardmixedSubview.Label1.hidden=NO;
                    
                }
                //forImage2
                
                if(self.leaderBoard.count>=3){
                    UsersRankedThree=[self.leaderBoard objectAtIndex:2];
                }
                
                if (UsersRankedThree!=nil) {
                    if(UsersRankedThree.picture && UsersRankedThree.picture.length>0){
                        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:UsersRankedThree.picture]];
                        
                        __weak UIImageView *weakImageView = leaderboardmixedSubview.image2;
                        weakImageView.image = nil;
                        
                        [leaderboardmixedSubview.image2 setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                            [weakImageView setImage:image];
                        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                            NSLog(@"error=%@",[error description]);
                        }];
                    }
                    
                    else if(UsersRankedThree.picture==nil || UsersRankedThree.picture.length == 0){
                        leaderboardmixedSubview.image2.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
                        [leaderboardmixedSubview.Label2 setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                        leaderboardmixedSubview.Label2.text=[NSString stringWithFormat:@"%@%@",[UsersRankedThree.firstName.uppercaseString substringToIndex:1],[UsersRankedThree.lastName.uppercaseString substringToIndex:1]];
                        leaderboardmixedSubview.Label2.hidden=NO;
                    }
                }else{
                    leaderboardmixedSubview.image2.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
                    
                    [leaderboardmixedSubview.Label2 setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                    leaderboardmixedSubview.Label2.text=@"3rd";
                    leaderboardmixedSubview.Label2.hidden=NO;                }
                
                
                [cell.scrollView addSubview:leaderboardmixedSubview];
                break;
            }
        }
        return cell;
    }
    else if(indexPath.section==1){
        if(self.wagers.count>0 && self.wagers.count>indexPath.row){
            Wager *wager=[self.wagers objectAtIndex:indexPath.row];
            Event *game;
            MyWagersDetailCell *cell;
            if([wager.type isEqualToString:@"custom"]){
                [tableView dequeueReusableCellWithIdentifier:@"Custom"];
                game=wager.customEvent;
            }
            else{
                [tableView dequeueReusableCellWithIdentifier:@"Cell"];
                game=wager.event;
            }
            if (cell == nil) {
                NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"MyWagersDetailCell" owner:self options:nil];
                if([wager.type isEqualToString:@"custom"]){
                    cell = (MyWagersDetailCell *)[nib objectAtIndex:1];
                }
                else{
                    cell = (MyWagersDetailCell *)[nib objectAtIndex:0];
                }
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell.wagerTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                [cell.contestImageView.layer setCornerRadius:cell.contestImageView.bounds.size.width/2];
                [cell.contestImageView.layer setMasksToBounds:YES];
                [cell.contestTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:12.0]];
            }
            if([wager.type isEqualToString:@"custom"]){
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:wager.answer.picture]];
                __weak UIImageView *weakImageView = cell.leftImageView;
                weakImageView.image = nil;
                [cell.leftImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                    [weakImageView setImage:image];
                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    NSLog(@"error=%@",[error description]);
                }];
                cell.wagerTitleLabel.text=[NSString stringWithFormat:@"%@  %+g",wager.answer.title.uppercaseString,wager.answer.value];
            }
            else if([wager.type isEqualToString:kMoneyType]||[wager.type isEqualToString:kSpreadType]){
                cell.leftImageView.backgroundColor=[UIColor colorWithHexString:wager.team.color];
                cell.rightImageView.backgroundColor=[UIColor colorWithHexString:wager.team.color];
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:wager.team.image]];
                __weak UIImageView *weakImageView = cell.rightImageView;
                weakImageView.image = nil;
                [cell.rightImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                    [weakImageView setImage:image];
                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    NSLog(@"error=%@",[error description]);
                }];
                cell.wagerTitleLabel.text=[NSString stringWithFormat:@"%@  %+g",wager.team.displayName.uppercaseString,wager.line];
            }
            else{
                cell.wagerTitleLabel.text=@"";
                [self configureSplitImagesWithLeftImageView:cell.leftImageView rightImageView:cell.rightImageView game:game];
                if([wager.type isEqualToString:kUnderType]){
                    cell.wagerTitleLabel.text=[NSString stringWithFormat:@"UNDER %g",wager.line];
                }
                else if([wager.type isEqualToString:kOverType]){
                    cell.wagerTitleLabel.text=[NSString stringWithFormat:@"OVER %g",wager.line];
                }
            }
            
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:wager.contest.pictureUrl]];
            __weak UIImageView *weakImageView = cell.contestImageView;
            weakImageView.image = nil;
            [cell.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
            cell.contestTitleLabel.text=wager.contest.title.uppercaseString;
            if([game.status rangeOfString:@"upcoming"].location!=NSNotFound || [game.status rangeOfString:@"progress"].location!=NSNotFound){
                double pointsToWin=[Utils pointsToWinForWager:wager.amount lineType:wager.type lineAmount:wager.line];
                cell.toWinLabel.attributedText=[Utils wagerAttributedStringWithAmountPlayed:wager.amount toWin:pointsToWin];
            }
            else if([game.status rangeOfString:@"finished"].location!=NSNotFound){
                cell.toWinLabel.attributedText=[Utils wagerAttributedStringWithResult:wager.result points:wager.points name:@"You"];
            }
            
            return cell;
        }
        else if (self.wagers.count==indexPath.row && self.wagers.count>0 && self.currentPage>0){
            return [self loadingCell];
        }else{
            NoWagerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            if (cell == nil) {
                NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"NoWagerCell" owner:self options:nil];
                cell = (NoWagerCell *)[nib objectAtIndex:0];
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell.noWagersLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            }
            return cell;
        }
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    wagersArray = [[NSMutableArray alloc] init];
    Wager *wager_obj=[self.wagers objectAtIndex:indexPath.row];
    [wagersArray addObject:wager_obj];
    
    Wager *wager=[self.wagers objectAtIndex:indexPath.row];
    Event *game;
    if([wager.type isEqualToString:@"custom"]){
        [tableView dequeueReusableCellWithIdentifier:@"Custom"];
        game=wager_obj.customEvent;
    }
    else{
        [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        game=wager_obj.event;
    }
    
    MyWagersDetailViewController *myWagersDetailViewController;
    
    if([game.contextType isEqualToString:@"CustomEvent"]){
        myWagersDetailViewController=[[MyWagersDetailViewController alloc] initWithBackgroundImage:self.blurImage game:game wagers:self.wagers context:@"contest" context_id:self.contest.contestIdentifier nibName:@"MyWagersCustomEventDetailViewController" bundle:nil];
    }
    else{
        myWagersDetailViewController=[[MyWagersDetailViewController alloc] initWithBackgroundImage:self.blurImage game:game wagers:self.wagers context:@"contest" context_id:self.contest.contestIdentifier nibName:nil bundle:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:myWagersDetailViewController animated:YES completion:^{}];
        self.wagerDetailViewController = myWagersDetailViewController;
    });

    
}

-(void)configureSplitImagesWithLeftImageView:(UIImageView*)leftImageView rightImageView:(UIImageView*)rightImageView game:(Event*)game{
    CAShapeLayer *leftShapeLayer = [[CAShapeLayer alloc] init];
    leftShapeLayer.frame = leftImageView.layer.bounds;
    //    leftShapeLayer.fillColor = [[UIColor blackColor] CGColor];
    leftShapeLayer.path = [self pathForLeftImage:leftImageView.bounds];
    leftImageView.layer.mask = leftShapeLayer;
    
    leftImageView.backgroundColor=[UIColor colorWithHexString:game.awayTeam.color];
    NSMutableURLRequest *leftRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:game.awayTeam.image]];
    __weak UIImageView *weakLeftImageView = leftImageView;
    weakLeftImageView.image = nil;
    [weakLeftImageView setImageWithURLRequest:leftRequest placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
        [weakLeftImageView setImage:image];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
    
    CAShapeLayer *rightShapeLayer = [[CAShapeLayer alloc] init];
    rightShapeLayer.frame = rightImageView.layer.bounds;
    //    rightShapeLayer.fillColor = [[UIColor blackColor] CGColor];
    rightShapeLayer.path = [self pathForRightImage:rightImageView.bounds];
    rightImageView.layer.mask = rightShapeLayer;
    
    rightImageView.backgroundColor=[UIColor colorWithHexString:game.homeTeam.color];
    NSMutableURLRequest *rightRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:game.homeTeam.image]];
    __weak UIImageView *weakRightImageView = rightImageView;
    weakRightImageView.image = nil;
    [weakRightImageView setImageWithURLRequest:rightRequest placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *rightImage ){
        [weakRightImageView setImage:rightImage];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kLoadingCellTag) {
        
        if(self.nextPageURL.length>0){
            [self loadWagers];
        }
    }
}

- (UITableViewCell *)loadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    
    UIActivityIndicatorView *activityIndicator =
    [[UIActivityIndicatorView alloc]
     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.center;
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:activityIndicator];
    [activityIndicator startAnimating];
    cell.tag = kLoadingCellTag;
    
    return cell;
}

- (CGPathRef) pathForLeftImage:(CGRect)rect{
	CGMutablePathRef path = CGPathCreateMutable();
    
	CGPathMoveToPoint(path, NULL, rect.origin.x+rect.size.width, rect.origin.y);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+rect.size.width-40.0, rect.origin.y+rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y+rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y);
	CGPathCloseSubpath(path);
    
	return path;
}

- (CGPathRef) pathForRightImage:(CGRect)rect{
	CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, rect.origin.x+rect.size.width, rect.origin.y);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y+rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+40.0, rect.origin.y);
	CGPathCloseSubpath(path);
    
	return path;
}


-(void)calculateLeaderboard{
    self.leaderBoard = [self.contest.leaderboard sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [NSNumber numberWithDouble:[[(User*)a points] balance]];
        NSNumber *second = [NSNumber numberWithDouble:[[(User*)b points] balance]];
        return [second compare:first];
    }];
}

- (void)scrollViewTapAction:(id)sender{
    CGPoint touchLocation = [sender locationOfTouch:0 inView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    if(indexPath.section==0){
        LeaderboardScrollCell *cell=(LeaderboardScrollCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        CGPoint point = [sender locationInView:cell.scrollView];
        int index = (int)point.x/118.0;
        NSLog(@"%d",index);
        //Check if index is available in the leaderBoard Array
        if([self.leaderBoard count] >= index && index<=10){
            if(index==MAX_COUNT){
                LeaderBoardDetailView *detailView =[[LeaderBoardDetailView alloc]initWithNibName:@"LeaderBoardDetailView" bundle:nil];
                detailView.LeaderBoardArray = self.leaderBoard;
                detailView.headerImgSrc = self.contest.bigPictureUrl;
                detailView.contest =self.contest;
                detailView.type = @"contest";
                [self.navigationController pushViewController:detailView animated:YES];
            }else{
                User *user=[self.leaderBoard objectAtIndex:index];
                MyProfileViewController *profileViewController = [[MyProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil user:user context:@"contest" id:self.contest.contestIdentifier];
            [self.navigationController pushViewController:profileViewController animated:YES];
            }
        }
    }
}

- (IBAction)info:(id)sender {
    
    ContestInfoViewController *contestInfoViewController=[[ContestInfoViewController alloc] initWithBackgroundImage:self.blurImage contest:self.contest game:nil];
    contestInfoViewController.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:contestInfoViewController animated:YES completion:^{}];
    });
    

}
@end
