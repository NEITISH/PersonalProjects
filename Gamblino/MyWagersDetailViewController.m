//
//  MyWagersDetailViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/5/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "MyWagersDetailViewController.h"
#import "Team.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+Gamblino.h"
#import "Utils.h"
#import "MyWagersDetailCell.h"
#import "Wager.h"
#import "Constants.h"
#import "Contest.h"
#import "Answer.h"
#import "Pool.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "User.h"


@interface MyWagersDetailViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,weak) IBOutlet UILabel *teamsLabel;
@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UIImageView *awayImageView;
@property (nonatomic,weak) IBOutlet UIImageView *homeImageView;
@property (nonatomic,weak) IBOutlet UIImageView *customEventImageView;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UILabel *awayScoreLabel;
@property (nonatomic,weak) IBOutlet UILabel *homeScoreLabel;
@property (nonatomic,weak) IBOutlet UILabel *customEventTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *customEventSubtitleLabel;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) NSArray *wagers;
@property (nonatomic,strong) NSMutableArray *wager_ids;
@property (nonatomic,strong) NSString *nextUpcomingPageURL;
@property (nonatomic,assign) int currentPage;
@property(nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSString *context;
@property (nonatomic,assign) int context_id;
@property (nonatomic,assign) int currentUserId;


@end

@implementation MyWagersDetailViewController

- (id)initWithBackgroundImage:(UIImage*)image game:(Event*)game wagers:(NSArray*)wagers context:(NSString *)context context_id:(int)context_id nibName:(NSString*)nibName bundle:(NSBundle*)bundle{
    self = [super initWithNibName:nibName bundle:bundle];
    if(self){
        self.blurImage=image;
        self.game=game;
        self.wagers=wagers;
        self.context=context;
        self.context_id=context_id;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUserId=[[[NSUserDefaults standardUserDefaults] valueForKey:kUserId] intValue];
    [self.backgroundImageView setImage:self.blurImage];
    NSDate *date= [Utils dateFromGamblinoDateString:self.game.startTime];
    NSString *dateString= [Utils stringFromDate:date];
    self.wager_ids=[[NSMutableArray alloc] init];
    if([self.game.contextType isEqualToString:@"CustomEvent"]){
        [self.customEventTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        [self.customEventSubtitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
        if(self.game.picture){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.game.picture]];
            __weak UIImageView *weakImageView = self.customEventImageView;
            weakImageView.image = nil;
            [self.customEventImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            self.awayImageView.image=nil;
        }
        self.customEventTitleLabel.text=self.game.title;
        
        if([self.game.status rangeOfString:@"progress"].location!=NSNotFound){
            self.customEventSubtitleLabel.text= [NSString stringWithFormat:@"%@",self.game.progress.uppercaseString];
        }
        else if([self.game.status rangeOfString:@"finished"].location!=NSNotFound){
            self.customEventSubtitleLabel.text= [NSString stringWithFormat:@"%@",self.game.progress.uppercaseString];
        }
        else{
            self.customEventSubtitleLabel.text= [NSString stringWithFormat:@"%@",dateString];
        }
        [self loadWagers];
    }
    else{
        [self.dateLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
        [self.awayScoreLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:55.0]];
        [self.homeScoreLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:55.0]];
        if(self.game.awayTeam.image){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.game.awayTeam.image]];
            __weak UIImageView *weakImageView = self.awayImageView;
            weakImageView.image = nil;
            [self.awayImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            self.awayImageView.image=nil;
        }
        if(self.game.homeTeam.image){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.game.homeTeam.image]];
            __weak UIImageView *weakImageView = self.homeImageView;
            weakImageView.image = nil;
            [self.homeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            self.homeImageView.image=nil;
        }
        self.homeImageView.backgroundColor=[UIColor colorWithHexString:self.game.homeTeam.color];
        self.awayImageView.backgroundColor=[UIColor colorWithHexString:self.game.awayTeam.color];
        self.teamsLabel.attributedText=[Utils gameAttributedStringWithHometeam:self.game.homeTeam awayTeam:self.game.awayTeam];
        
        [self refreshScreen];
    }
 
    self.timer=[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(refreshWagers) userInfo:nil repeats:YES];

 
}

-(void)refreshWagers{
    if(self.nextUpcomingPageURL.length==0){
        [self loadWagersAtIndex:0];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)refreshScreen {
    
    NSDate *date= [Utils dateFromGamblinoDateString:self.game.startTime];
    NSString *dateString= [Utils stringFromDate:date];
    if([self.game.status rangeOfString:@"progress"].location!=NSNotFound){
        self.awayScoreLabel.text=[NSString stringWithFormat:@"%d",self.game.awayScore];
        self.homeScoreLabel.text=[NSString stringWithFormat:@"%d",self.game.homeScore];
        self.awayScoreLabel.hidden=NO;
        self.homeScoreLabel.hidden=NO;
        self.dateLabel.textColor=[UIColor colorWithRed:126.0/255.0 green:120.0/255.0 blue:105.0/255.0 alpha:1.0];
        self.dateLabel.text= [self.game.progress uppercaseString];
    }
    else if([self.game.status rangeOfString:@"finished"].location!=NSNotFound){
        self.awayScoreLabel.text=[NSString stringWithFormat:@"%d",self.game.awayScore];
        self.homeScoreLabel.text=[NSString stringWithFormat:@"%d",self.game.homeScore];
        self.awayScoreLabel.hidden=NO;
        self.homeScoreLabel.hidden=NO;
        int totalPoints=0;
        NSString *currentUser;
        NSMutableArray *tmpWagerIds=[[NSMutableArray alloc]init];
        for(Wager *wager in self.wagers){
            if(wager.event.eventIdentifier==self.game.eventIdentifier){
                if (![tmpWagerIds containsObject:[NSNumber numberWithInteger:wager.wagerIdentifier]]) {
                    NSNumber* WagerId = [NSNumber numberWithInteger:wager.wagerIdentifier];
                    [tmpWagerIds addObject:WagerId];
                    if(self.currentUserId == wager.user.usersIdentifier){currentUser =@"YOU";}
                    else{ currentUser = wager.user.firstName;}
                    totalPoints+=wager.points;
                }
            }
        }
       
        if(totalPoints<0){
            self.dateLabel.textColor=[UIColor colorWithRed:230.0/255.0 green:66.0/255.0 blue:40.0/255.0 alpha:1.0];
            self.dateLabel.text=[[NSString stringWithFormat:@"%@ LOST %dPTS",currentUser,abs(totalPoints)] uppercaseString];
           
        }
        else{
            self.dateLabel.textColor=[UIColor colorWithRed:86.0/255.0 green:185.0/255.0 blue:27.0/255.0 alpha:1.0];
            self.dateLabel.text=[[NSString stringWithFormat:@"%@ WON %dPTS",currentUser,abs(totalPoints)] uppercaseString] ;
        }
    }
    else{
        self.awayScoreLabel.hidden=YES;
        self.homeScoreLabel.hidden=YES;
        self.dateLabel.textColor=[UIColor colorWithRed:126.0/255.0 green:120.0/255.0 blue:105.0/255.0 alpha:1.0];
        self.dateLabel.text= [[NSString stringWithFormat:@"%@ @ %@",dateString,self.game.homeTeam.displayName] uppercaseString];
    }
    [self loadWagers];
}

-(void)loadWagers{
    
    NSMutableArray *wagers=[[NSMutableArray alloc] init];
    for(Wager *wager in self.wagers){
        if([self.game.contextType isEqualToString:@"CustomEvent"]){
            if(wager.customEvent.eventIdentifier==self.game.eventIdentifier){
                [wagers addObject:wager];
            }
        }
        else{
            if(wager.event.eventIdentifier==self.game.eventIdentifier){
                if (![self.wager_ids containsObject:[NSNumber numberWithInteger:wager.wagerIdentifier]]) {
                    NSNumber* WagerId = [NSNumber numberWithInteger:wager.wagerIdentifier];
                    [self.wager_ids addObject:WagerId];
                    [wagers addObject:wager];
                    NSLog(@"Number of wagers count%lu",(unsigned long)[wagers count]);
                 }
            }
        }
    }
    if([wagers count]>0){
        self.wagers=wagers;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.wagers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Wager *wager=[self.wagers objectAtIndex:indexPath.row];
    User *currentUser = wager.user ;
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
        [self configureSplitImagesWithLeftImageView:cell.leftImageView rightImageView:cell.rightImageView];
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
    }
    else{
        cell.contestTitleLabel.text=@"";
    }
    
    if([self.game.status rangeOfString:@"upcoming"].location!=NSNotFound || [self.game.status rangeOfString:@"progress"].location!=NSNotFound){
        double pointsToWin=[Utils pointsToWinForWager:wager.amount lineType:wager.type lineAmount:wager.line];
        cell.toWinLabel.attributedText=[Utils wagerAttributedStringWithAmountPlayed:wager.amount toWin:pointsToWin];
    }
    else if([self.game.status rangeOfString:@"finished"].location!=NSNotFound){
        NSString *strCurrentUser=currentUser.firstName;
        if(self.currentUserId == currentUser.usersIdentifier){strCurrentUser =@"You";}
        cell.toWinLabel.attributedText=[Utils wagerAttributedStringWithResult:wager.result points:wager.points name:strCurrentUser];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)configureSplitImagesWithLeftImageView:(UIImageView*)leftImageView rightImageView:(UIImageView*)rightImageView{
    CAShapeLayer *leftShapeLayer = [[CAShapeLayer alloc] init];
    leftShapeLayer.frame = leftImageView.layer.bounds;
//    leftShapeLayer.fillColor = [[UIColor blackColor] CGColor];
    leftShapeLayer.path = [self pathForLeftImage:leftImageView.bounds];
    leftImageView.layer.mask = leftShapeLayer;
    
    leftImageView.backgroundColor=[UIColor colorWithHexString:self.game.awayTeam.color];
    NSMutableURLRequest *leftRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.game.awayTeam.image]];
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
    
    rightImageView.backgroundColor=[UIColor colorWithHexString:self.game.homeTeam.color];
    NSMutableURLRequest *rightRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.game.homeTeam.image]];
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


#pragma mark - API Calls

- (void)loadWagersAtIndex:(int)index {
    NSString *remotePath=@"";
    if(index == 0) {
        remotePath = @"v3/wagers";
    }
    else if(self.nextUpcomingPageURL) {
        remotePath = self.nextUpcomingPageURL;
    }
    else {
        return;
    }
    self.wager_ids=[[NSMutableArray alloc] init];
    
    NSMutableDictionary *QueryParam=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"DESC",@"sort", nil];
    if(self.context.length>0 && self.context_id>0){
        [QueryParam setObject:[NSNumber numberWithInt:self.context_id] forKey:@"context_id"];
        [QueryParam setObject:self.context forKey:@"context"];
    }
    
    remotePath = [NSString stringWithFormat:@"v3/wagers?event_id=%d",self.game.eventIdentifier];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] GET:remotePath withParameters:QueryParam successBlock:^(NSDictionary *wagersDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.currentPage = index;
        if([wagersDictionary.allKeys containsObject:@"pagination"]){
            NSDictionary *paginationValue = [wagersDictionary valueForKey:@"pagination"];
            self.nextUpcomingPageURL = [[paginationValue objectForKey:@"next_page"] isEqual:[NSNull null]] ? nil : [paginationValue objectForKey:@"next_page"];
        }
        if([wagersDictionary.allKeys containsObject:@"wagers"]) {
            NSArray *wagersValue = [wagersDictionary valueForKey:@"wagers"];
            NSMutableArray *wagersArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dic in wagersValue){
                Wager *wager = [[Wager alloc] initWithDictionary:dic];
                [wagersArray addObject:wager];
            }
                if(wagersArray.count>0){
                    Wager *tmpObject = [wagersArray objectAtIndex:0];
                    if(tmpObject.event!=NULL){
                        self.game =tmpObject.event;
                    }else if(tmpObject.customEvent!=NULL){
                        self.game =tmpObject.customEvent;
                    }
                self.wagers = wagersArray;
            }
            [self refreshScreen];
            
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

@end
