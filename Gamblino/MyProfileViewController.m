//
//  MyProfileViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/17/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "MyProfileViewController.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+AFNetworking.h"
#import "Wager.h"
#import "Event.h"
#import "MyWagersDetailCell.h"
#import "Constants.h"
#import "UIView+Blur.h"
#import "UIColor+Gamblino.h"
#import "Answer.h"
#import "Pool.h"
#import "AnalyticsManager.h"
#import "MyWagersDetailViewController.h"
#define kLoadingCellTag 123456


@interface MyProfileViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *blurImageView;
@property (nonatomic,weak) IBOutlet UIImageView *myProfileImageView;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UILabel *streakTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *streakLabel;
@property (nonatomic,weak) IBOutlet UILabel *friendsTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *friendsLabel;
@property (nonatomic,weak) IBOutlet UILabel *winLossTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *winLossLabel;
@property (nonatomic,weak) IBOutlet UILabel *winPercentageTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *winPercentageLabel;
@property (nonatomic,weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic,weak) IBOutlet UIButton *addFriendButton;
@property (nonatomic,weak) IBOutlet UILabel *friendLabel;
@property (nonatomic,weak) IBOutlet UILabel *initialsLabel;
@property (nonatomic,weak) IBOutlet UIView *noResultsView;
@property (nonatomic,weak) IBOutlet UILabel *noResultsLabel;
@property (nonatomic,strong) User *myUser;
@property (nonatomic,strong) User *user;
@property (nonatomic,strong) NSArray *wagers;
@property (nonatomic,strong) NSDictionary *wagersDictionary;
@property (nonatomic,strong) NSArray *headerTitles;
@property (nonatomic,strong) NSArray *friends;
@property (nonatomic,assign) int remainingCallsToProcess;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong) NSString *nextPageURL;
@property (nonatomic,strong) NSString *context;
@property (nonatomic,assign) int contextTypeId;
@property(nonatomic,weak) MyWagersDetailViewController *wagerDetailViewController;

@end

@implementation MyProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User*)user context:(NSString *)context id:(int)ide;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.user=user;
        self.context=context;
        self.contextTypeId=ide;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"Profile Screen Loaded"];
    [self.myProfileImageView.layer setCornerRadius:self.myProfileImageView.bounds.size.width/2];
    [self.streakTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.friendsTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.winLossTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.winPercentageTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.streakLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.friendsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.winLossLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.winPercentageLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.userNameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.addFriendButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.friendLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:48.0]];
    [self.noResultsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.remainingCallsToProcess=4;
    self.currentPage=0;
    self.wagers = [[NSArray alloc] init];
    self.nextPageURL=@"";
    [self loadProfile];
    [self loadWagers];
    [self loadStats];
    [self loadMyFriends];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(BOOL)isUserMyFriend{
    BOOL returnValue=NO;
    if(self.user && self.friends){
        for(User *friend in self.friends){
            if(friend.usersIdentifier==self.user.usersIdentifier){
                returnValue=YES;
            }
        }
    }
    return returnValue;
}

-(BOOL)didRequestUserAsFriend{
    NSArray *currentRequests=[[NSUserDefaults standardUserDefaults] valueForKey:@"friendsRequest"];
    BOOL returnValue=NO;
    if(self.user){
        for(NSNumber *userIdNumber in currentRequests){
            if(userIdNumber.intValue==self.user.usersIdentifier){
                returnValue=YES;
            }
        }
    }
    return returnValue;
}

- (void)loadProfile{
    if(self.user){
        [self displayProfile];
        self.userNameLabel.text=[NSString stringWithFormat:@"%@ %@",self.user.firstName.uppercaseString,self.user.lastName.uppercaseString];
        self.remainingCallsToProcess--;
    }
    else{
        NSString *remotePath=@"me";
        [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *usersDictionary){
            self.remainingCallsToProcess--;
            if(self.remainingCallsToProcess==0){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            if([usersDictionary.allKeys containsObject:@"users"]){
                NSDictionary *myUserDictionary=[usersDictionary valueForKey:@"users"];
                self.myUser=[[User alloc] initWithDictionary:myUserDictionary];
                [self displayProfile];
            }
        }failureBlock:^(NSError *error){
            self.remainingCallsToProcess--;
            if(self.remainingCallsToProcess==0){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            NSLog(@"error=%@",error.description);
        }];
    }
}

- (void)displayProfile{
    User *user;
    if(self.user){
        user=self.user;
    }
    else{
        user=self.myUser;
    }
    if(user.picture && user.picture.length>0){
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:user.picture]];
    __weak UIImageView *weakImageView = self.blurImageView;
    __weak UIImageView *weakProfileImageView = self.myProfileImageView;
        weakProfileImageView.image = nil;
    [self.blurImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            UIImage *bluredImage=[image applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:0 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
            [weakImageView setImage:bluredImage];
            [weakProfileImageView setImage:image];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        
    }];
    }
    else{
        [self.blurImageView setImage:[UIImage imageNamed:@"defaultBlur"]];
        [self.myProfileImageView setImage:nil];
        [self.myProfileImageView setBackgroundColor:[UIColor clearColor]];
        self.myProfileImageView.layer.borderColor=[UIColor whiteColor].CGColor;
        self.myProfileImageView.layer.borderWidth=4.0f;
        self.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[user.firstName.uppercaseString substringToIndex:1],[user.lastName.uppercaseString substringToIndex:1]];
    }
}

- (void)loadMyFriends{
    if(self.user){
        NSString *remotePath=@"friends";
        [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *usersDictionary){
            self.remainingCallsToProcess--;
            if(self.remainingCallsToProcess==0){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            if([usersDictionary.allKeys containsObject:@"users"]){
                NSArray *friendsValue=[usersDictionary valueForKey:@"users"];
                NSMutableArray *friendsArray=[[NSMutableArray alloc] init];
                for(NSDictionary *dic in friendsValue){
                    User *user=[[User alloc] initWithDictionary:dic];
                    [friendsArray addObject:user];
                }
                self.friends=friendsArray;
                int currentUserId=[[[NSUserDefaults standardUserDefaults] valueForKey:kUserId] intValue];
                if(self.user.usersIdentifier!=currentUserId){
                    if([self isUserMyFriend]){
                        self.addFriendButton.hidden=YES;
                        self.friendLabel.hidden=NO;
                    }
                    else{
                        self.addFriendButton.hidden=[self didRequestUserAsFriend];
                        self.friendLabel.hidden=YES;
                    }
                }
                else{
                    self.addFriendButton.hidden=YES;
                    self.friendLabel.hidden=YES;
                }
            }
        }failureBlock:^(NSError *error){
            self.remainingCallsToProcess--;
            if(self.remainingCallsToProcess==0){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            NSLog(@"error=%@",error.description);
        }];
    }
    else{
        self.remainingCallsToProcess--;
    }
}

- (void)loadStats{
    NSString *remotePath;
    if(self.user){
        remotePath=[NSString stringWithFormat:@"users/%d/stats",self.user.usersIdentifier];
    }
    else{
        remotePath=@"me/stats";
    }
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *dic){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        if([dic.allKeys containsObject:@"stats"]){
            NSDictionary *statsDictionary=[dic valueForKey:@"stats"];
            self.friendsLabel.text=[NSString stringWithFormat:@"%d",[[statsDictionary valueForKey:@"friends"] intValue]];
            self.winPercentageLabel.text=[NSString stringWithFormat:@"%d %%",[[statsDictionary valueForKey:@"percentage"] intValue]];
            
            NSString *winString = [Utils shortStringForInt:[[statsDictionary valueForKey:@"wins"] intValue]];
            NSString *lossString = [Utils shortStringForInt:[[statsDictionary valueForKey:@"loss"] intValue]];
            self.winLossLabel.text=[NSString stringWithFormat:@"%@ - %@",winString,lossString];
            
            NSDictionary *streakDictionary=[statsDictionary valueForKey:@"streak"];
            if([[streakDictionary valueForKey:@"result"] isEqualToString:@"loss"]){
                self.streakLabel.text=[NSString stringWithFormat:@"L-%d",[[streakDictionary valueForKey:@"count"] intValue]];
            }
            else{
                self.streakLabel.text=[NSString stringWithFormat:@"W-%d",[[streakDictionary valueForKey:@"count"] intValue]];
            }
        }
    }failureBlock:^(NSError *error){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        NSLog(@"error=%@",error.description);
    }];
}

-(void)loadWagers{
    NSString *remotePath;
    NSMutableDictionary *QueryParam=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"in-progress|suspended|delay-rain|delay-other|complete|postponed",@"status",@"DESC",@"sort", nil];
    
    if(self.user && self.context && self.contextTypeId){
        remotePath = [NSString stringWithFormat:@"v3/wagers?user_id=%d",self.user.usersIdentifier];
        [QueryParam setObject:self.context forKey:@"context"];
        [QueryParam setObject:[NSNumber numberWithInt:self.contextTypeId] forKey:@"context_id"];
    }
    else if(self.currentPage==0){
        remotePath = @"v3/wagers";
    }
    else if(self.currentPage > 0){
        remotePath=self.nextPageURL;
    }

    
    
    [[NetworkManager sharedInstance] GET:remotePath withParameters:QueryParam successBlock:^(NSDictionary *wagersDictionary){
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
            wagersArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in wagersValue){
                Wager *wager=[[Wager alloc] initWithDictionary:dic];
                if([wager.type isEqualToString:@"custom"]){
                    if([wager.customEvent.status rangeOfString:@"finished"].location!=NSNotFound){
                        [wagersArray addObject:wager];
                    }else if([wager.customEvent.status rangeOfString:@"progress"].location!=NSNotFound){
                        [wagersArray addObject:wager];
                    }
                }
                else{
                    if([wager.event.status rangeOfString:@"finished"].location!=NSNotFound){
                        [wagersArray addObject:wager];
                    }else if([wager.event.status rangeOfString:@"progress"].location!=NSNotFound){
                        [wagersArray addObject:wager];
                    }
                }
            }
            
            if(self.wagers.count>0 && wagersArray.count>0){
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.wagers];
                [tempArray addObjectsFromArray:wagersArray];
                self.wagers=[tempArray mutableCopy];
            }else if(self.currentPage>0 && wagersArray.count==0){
                self.currentPage=0;
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.wagers];
                [tempArray addObjectsFromArray:wagersArray];
                self.wagers=[tempArray mutableCopy];
            }else{
                if(wagersArray.count>0){
                    self.wagers=wagersArray;
                }
            }
            
            if(wagersArray.count>0){
                [self sortWagers];
                [self.tableView reloadData];
            }
            else{
                self.noResultsView.hidden=NO;
            }
        }
    }failureBlock:^(NSError *error){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        NSLog(@"error=%@",error.description);
    }];
}

-(void)sortWagers{
    NSArray *sortedWagers = self.wagers;
    /*[self.wagers sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(Wager *wager1, Wager* wager2) {
        NSDate *date1;
        NSDate *date2;
        if([wager1.type isEqualToString:@"custom"]){
            date1=[Utils dateFromGamblinoDateString:wager1.customEvent.startTime];
        }
        else{
            date1=[Utils dateFromGamblinoDateString:wager1.event.startTime];
        }
        if([wager2.type isEqualToString:@"custom"]){
            date2=[Utils dateFromGamblinoDateString:wager2.customEvent.startTime];
        }
        else{
            date2=[Utils dateFromGamblinoDateString:wager2.event.startTime];
        }
        return [date2 compare:date1];
    }];*/
    
    NSMutableDictionary *wagerDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *currentWagerAwway = [[NSMutableArray alloc] init];
    NSMutableArray *headerArray = [[NSMutableArray alloc] init];
    NSString *currentKey = nil;
    for(Wager *wager in sortedWagers) {
        NSDate *wagerDate;
        if([wager.type isEqualToString:@"custom"]){
            wagerDate=[Utils dateFromGamblinoDateString:wager.customEvent.startTime];
        }
        else{
            wagerDate=[Utils dateFromGamblinoDateString:wager.event.startTime];
        }
        NSString *dateString=[Utils shortStringFromDate:wagerDate];
        NSLog(@"datestring=%@",dateString);
        if(currentKey && [dateString hasPrefix:currentKey]) {
            [currentWagerAwway addObject:wager];
        }
        else {
            if(currentKey && currentWagerAwway.count > 0) {
                [wagerDictionary setValue:currentWagerAwway forKey:currentKey];
                [headerArray addObject:currentKey];
            }
            currentKey = dateString;
            currentWagerAwway = [[NSMutableArray alloc] initWithObjects:wager, nil];
        }
    }
    
    if(currentWagerAwway.count > 0) {
        [wagerDictionary setValue:currentWagerAwway forKey:currentKey];
        [headerArray addObject:currentKey];
    }

    self.wagersDictionary=wagerDictionary;
    self.headerTitles=headerArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headerTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *headerKey=[self.headerTitles objectAtIndex:section];
    NSArray *wagers=[self.wagersDictionary valueForKey:headerKey];
    if (_currentPage>0 && section == (self.headerTitles.count-1)){
        return wagers.count + 1;
    }else{
        return wagers.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *headerKey=[self.headerTitles objectAtIndex:indexPath.section];
    NSArray *wagers=[self.wagersDictionary valueForKey:headerKey];
    
    if(indexPath.row==[wagers count] && self.currentPage>0){
        return 44;
    }else{
        return 96.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *headerKey=[self.headerTitles objectAtIndex:section];

    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 40.0)];
    headerView.backgroundColor=[UIColor clearColor];
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 30.0)];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, 300.0, 30.0)];
    [view setBackgroundColor:[UIColor colorWithRed:201.0/255.0 green:194.0/255.0 blue:178.0/255.0 alpha:1.0]];
    [label setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:15.0]];
    [label setTextColor:[UIColor colorWithRed:247.0/255.0 green:244.0/255.0 blue:238.0/255.0 alpha:1.0]];
    label.textAlignment=UITextAlignmentRight;
    label.text=headerKey;
    [view addSubview:label];
    [headerView addSubview:view];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *headerKey=[self.headerTitles objectAtIndex:indexPath.section];
    NSArray *wagers=[self.wagersDictionary valueForKey:headerKey];
    
    if(indexPath.row==[wagers count] && self.currentPage>0){
        
        return [self loadingCell];
        
    }else{
        
        Wager *wager=[wagers objectAtIndex:indexPath.row];
        
        Event *game;
        if([wager.type isEqualToString:@"custom"]){
            game=wager.customEvent;
        }
        else{
            game=wager.event;
        }
        MyWagersDetailCell *cell;
        if([wager.type isEqualToString:@"custom"]){
            [tableView dequeueReusableCellWithIdentifier:@"Custom"];
        }
        else{
            [tableView dequeueReusableCellWithIdentifier:@"Cell"];
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
        NSMutableURLRequest *request;
        if(wager.contest&&wager.contest.pictureUrl&&wager.contest.pictureUrl.length>0){
            request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:wager.contest.pictureUrl]];
        }
        else if(wager.pool&&wager.pool.image&&wager.pool.image.length>0){
            request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:wager.pool.image]];
        }
        
        __weak UIImageView *weakImageView = cell.contestImageView;
        weakImageView.image = nil;
        if(request!=nil){
            [cell.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        
        if(wager.contest&&wager.contest.title.length>0){
            cell.contestTitleLabel.text=wager.contest.title.uppercaseString;
        }
        else if(wager.pool&&wager.pool.title.length>0){
            cell.contestTitleLabel.text=wager.pool.title.uppercaseString;
        }else{
            cell.contestTitleLabel.text=@"";
        }
        
        NSString *displayName;
        NSInteger useridentifier =[[NSUserDefaults standardUserDefaults] integerForKey:@"User_id"] ;

        if ([game.status rangeOfString:@"finished"].location!=NSNotFound) {
            if(self.user.usersIdentifier == useridentifier || self.user.usersIdentifier == 0){
                displayName=@"You";
            }
            else{
                displayName=self.user.firstName;
            }
            cell.toWinLabel.attributedText=[Utils wagerAttributedStringWithResult:wager.result
                                                                           points:wager.points
                                                                             name:displayName];
        
        }else if ([game.status rangeOfString:@"upcoming"].location!=NSNotFound || [game.status rangeOfString:@"progress"].location!=NSNotFound){
                double pointsToWin=[Utils pointsToWinForWager:wager.amount lineType:wager.type lineAmount:wager.line];
            
                cell.toWinLabel.attributedText=[Utils wagerAttributedStringWithAmountPlayed:wager.amount toWin:pointsToWin];
            }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *headerKey=[self.headerTitles objectAtIndex:indexPath.section];
    NSArray *wagers=[self.wagersDictionary valueForKey:headerKey];
    wagersArray = [[NSMutableArray alloc] init];
    Wager *wager_obj=[wagers objectAtIndex:indexPath.row];
    [wagersArray addObject:wager_obj];
    Event *game;
    if([wager_obj.type isEqualToString:@"custom"]){
        game=wager_obj.customEvent;
    }
    else{
        game=wager_obj.event;
    }
    
    UIImage *blurImage=[UIImage imageNamed:@"defaultBlur"];

    MyWagersDetailViewController *myWagersDetailViewController;
    
    if([game.contextType isEqualToString:@"CustomEvent"]){
        myWagersDetailViewController=[[MyWagersDetailViewController alloc] initWithBackgroundImage:blurImage game:game wagers:wagers context:@"" context_id:0 nibName:@"MyWagersCustomEventDetailViewController" bundle:nil];
    }
    else{
        myWagersDetailViewController=[[MyWagersDetailViewController alloc] initWithBackgroundImage:blurImage game:game wagers:wagers context:@"" context_id:0
          nibName:nil bundle:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:myWagersDetailViewController animated:YES completion:^{}];
        self.wagerDetailViewController = myWagersDetailViewController;
    });

    
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


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kLoadingCellTag) {
        
        if(self.nextPageURL.length>0){
            [self loadWagers];
        }
    }
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

- (IBAction)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addFriendAction:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *friendDictionary=@{@"friend_id":[NSNumber numberWithInt:self.user.usersIdentifier]};
    [[NetworkManager sharedInstance] POST:@"friends" withParameters:friendDictionary successBlock:^(NSDictionary *rootDictionary) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        remainingCallsToProcess=1;
//        [self loadMyFriends];
        NSArray *currentRequests=[[NSUserDefaults standardUserDefaults] valueForKey:@"friendsRequest"];
        NSMutableArray *requests=[[NSMutableArray alloc] initWithArray:currentRequests];
        [requests addObject:[NSNumber numberWithInt:self.user.usersIdentifier]];
        [[NSUserDefaults standardUserDefaults] setValue:requests forKey:@"friendsRequest"];
        self.addFriendButton.hidden=YES;
    } failureBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(IBAction)findGamesAction:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartBetting" object:nil];
}

@end
