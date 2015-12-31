//
//  MyWagersViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/5/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "MyWagersViewController.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "Wager.h"
#import "Event.h"
#import "MyWagersCell.h"
#import "Team.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+Gamblino.h"
#import "Utils.h"
#import "MyWagersDetailViewController.h"
#import "UIView+Blur.h"
#import "GameListCell.h"
#import "AnalyticsManager.h"
#import "Utils.h"
#define kLoadingCellTag 123456

@interface MyWagersViewController ()

@property(nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIView *noWagersView;
@property(nonatomic,weak) IBOutlet UILabel *noWagersLabel;
@property(nonatomic,weak) IBOutlet UILabel *noWagersDescriptionLabel;
@property(nonatomic,weak) IBOutlet UIButton *findGamesButton;
@property(nonatomic,weak) IBOutlet UIButton *viewProfileButton;
@property(nonatomic,strong) NSArray *upcomingGamesWithWagers;
@property(nonatomic,strong) NSArray *inProgressGamesWithWagers;
@property(nonatomic,strong) NSArray *finalResultsGamesWithWagers;
@property(nonatomic,strong) NSArray *finalWagersArray;
@property(nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) int currentPage;

@property(nonatomic,strong) NSArray *upcomingWagers;
@property(nonatomic,strong) NSArray *inProgressWagers;
@property(nonatomic,strong) NSArray *resultsWagers;
@property (nonatomic,assign) int currentUpcomingPage;
@property (nonatomic,assign) int currentInProgressPage;
@property (nonatomic,assign) int currentResultsPage;
@property (nonatomic,strong) NSString *nextUpcomingPageURL;
@property (nonatomic,strong) NSString *nextInProgressPageURL;
@property (nonatomic,strong) NSString *nextResultsPageURL;



@property(nonatomic,weak) MyWagersDetailViewController *wagerDetailViewController;

@end

@implementation MyWagersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logEvent:@"My Wagers Loaded"];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0] forKey:UITextAttributeFont];
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.currentUpcomingPage = 0;
    self.currentInProgressPage = 0;
    self.currentResultsPage = 0;
    [self loadUpcomingWagersAtIndex:0];
    [self loadInProgressWagersAtIndex:0];
    [self loadFinalResultsWagersAtIndex:0];
    self.timer=[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(loadWagersForTimer) userInfo:nil repeats:YES];
    [self.noWagersLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController isMovingFromParentViewController]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)loadWagersForTimer {
    if(self.currentUpcomingPage == 0) {
        [self loadUpcomingWagersAtIndex:0];
    }
    if(self.currentInProgressPage == 0) {
        [self loadInProgressWagersAtIndex:0];
    }
    if(self.currentResultsPage == 0) {
        [self loadFinalResultsWagersAtIndex:0];
    }
}

//******************

- (void)loadUpcomingWagersAtIndex:(int)index {
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] GET:remotePath withParameters:@{@"status":@"upcoming|scheduled",@"sort":@"ASC"} successBlock:^(NSDictionary *wagersDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.currentUpcomingPage = index;
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
            
            //If Wagers Array have Data and wagersArray also have data then add to Wagers Array
            if(index > 0 && self.upcomingWagers.count>0 && wagersArray.count>0){
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.upcomingWagers];
                [tempArray addObjectsFromArray:wagersArray];
                self.upcomingWagers = [tempArray mutableCopy];
            }
            else if(wagersArray.count>0){
                self.upcomingWagers = wagersArray;
            }
            
            [self loadGamesWithWagers:self.upcomingWagers];
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

- (void)loadInProgressWagersAtIndex:(int)index {
    NSString *remotePath=@"";
    if(index == 0) {
        remotePath = @"v3/wagers";
    }
    else if(self.nextInProgressPageURL) {
        remotePath = self.nextInProgressPageURL;
    }
    else {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] GET:remotePath withParameters:@{@"status":@"in-progress|suspended|delay-rain|delay-other",@"sort":@"ASC"} successBlock:^(NSDictionary *wagersDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.currentInProgressPage = index;
        if([wagersDictionary.allKeys containsObject:@"pagination"]){
            NSDictionary *paginationValue = [wagersDictionary valueForKey:@"pagination"];
            self.nextInProgressPageURL = [[paginationValue objectForKey:@"next_page"] isEqual:[NSNull null]] ? nil : [paginationValue objectForKey:@"next_page"];
        }
        if([wagersDictionary.allKeys containsObject:@"wagers"]) {
            NSArray *wagersValue = [wagersDictionary valueForKey:@"wagers"];
            NSMutableArray *wagersArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dic in wagersValue){
                Wager *wager = [[Wager alloc] initWithDictionary:dic];
                [wagersArray addObject:wager];
            }
            
            //If Wagers Array have Data and wagersArray also have data then add to Wagers Array
            if(index > 0 && self.inProgressWagers.count>0 && wagersArray.count>0){
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.inProgressWagers];
                [tempArray addObjectsFromArray:wagersArray];
                self.inProgressWagers = [tempArray mutableCopy];
            }
            else if(wagersArray.count>0){
                self.inProgressWagers = wagersArray;
            }
            
            [self loadGamesWithWagers:self.inProgressWagers];
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

- (void)loadFinalResultsWagersAtIndex:(int)index {
    NSString *remotePath=@"";
    if(index == 0) {
        remotePath = @"v3/wagers";
    }
    else if(self.nextResultsPageURL) {
        remotePath = self.nextResultsPageURL;
    }
    else {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDate *fortyEightHoursAgoDate = [[NSDate date] dateByAddingTimeInterval:-3600*48];
    NSString *dateString = [Utils apiStringFromDate:fortyEightHoursAgoDate];
    [[NetworkManager sharedInstance] GET:remotePath withParameters:@{@"status":@"complete|postponed",@"sort":@"DESC",@"updated_since":dateString} successBlock:^(NSDictionary *wagersDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.currentResultsPage = index;
        if([wagersDictionary.allKeys containsObject:@"pagination"]){
            NSDictionary *paginationValue = [wagersDictionary valueForKey:@"pagination"];
            self.nextResultsPageURL = [[paginationValue objectForKey:@"next_page"] isEqual:[NSNull null]] ? nil : [paginationValue objectForKey:@"next_page"];
        }
        if([wagersDictionary.allKeys containsObject:@"wagers"]) {
            NSArray *wagersValue = [wagersDictionary valueForKey:@"wagers"];
            NSMutableArray *wagersArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dic in wagersValue){
                Wager *wager = [[Wager alloc] initWithDictionary:dic];
                [wagersArray addObject:wager];
            }
            
            //If Wagers Array have Data and wagersArray also have data then add to Wagers Array
            if(index > 0 && self.resultsWagers.count>0 && wagersArray.count>0){
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.resultsWagers];
                [tempArray addObjectsFromArray:wagersArray];
                self.resultsWagers = [tempArray mutableCopy];
            }
            else if(wagersArray.count>0){
                self.resultsWagers = wagersArray;
            }
            
            [self loadGamesWithWagers:self.resultsWagers];
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}



//******************

- (void)loadGamesWithWagers:(NSArray*) wagers{
    NSMutableArray *games = [[NSMutableArray alloc] init];
    for(Wager *wager in wagers){
        if([wager.type isEqualToString:@"custom"]){
            BOOL isGameAlreadyInArray = NO;
            int atIndex=0; int GameAtIndex=0;
            for(Event *game in games){
                if(wager.customEvent.eventIdentifier == game.eventIdentifier){
                    GameAtIndex = atIndex;
                    isGameAlreadyInArray=YES;
                }
                atIndex++;
            }
            if(!isGameAlreadyInArray){
                [games addObject:wager.customEvent];
            }else{
                [games replaceObjectAtIndex:GameAtIndex withObject:wager.customEvent];
            }
        }
        else{
            int atIndex=0; int GameAtIndex=0;
            BOOL isGameAlreadyInArray=NO;
            for(Event *game in games){
                if(wager.event.eventIdentifier==game.eventIdentifier){
                    GameAtIndex=atIndex;
                    isGameAlreadyInArray=YES;
                }
                atIndex++;
            }
            if(!isGameAlreadyInArray){
                [games addObject:wager.event];
            }else{
                [games replaceObjectAtIndex:GameAtIndex withObject:wager.event];
            }
        }
    }
    if(wagers == self.upcomingWagers) {
        self.upcomingGamesWithWagers = games;
    }
    else if(wagers == self.inProgressWagers) {
        self.inProgressGamesWithWagers = games;
    }
    else if(wagers == self.resultsWagers) {
        self.finalResultsGamesWithWagers = games;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

-(NSArray*)dataSourceArray{
    if(self.segmentedControl.selectedSegmentIndex==0){
        return self.upcomingGamesWithWagers;
    }
    else if(self.segmentedControl.selectedSegmentIndex==1){
        return self.inProgressGamesWithWagers;
    }
    else if(self.segmentedControl.selectedSegmentIndex==2){
        return self.finalResultsGamesWithWagers;
    }
    return nil;
}

- (IBAction)segmentedControlValueChangeAction:(id)sender{
    [self reloadData];
}

- (void)reloadData{
    if(self.segmentedControl.selectedSegmentIndex == 0){
        if(self.upcomingGamesWithWagers.count == 0){
            self.noWagersLabel.text=@"NO UPCOMING WAGERS";
            self.noWagersDescriptionLabel.text=@"You don’t have any upcoming wagers. Check out available games and let it ride!";
            self.noWagersView.hidden=NO;
            self.tableView.hidden=YES;
            self.findGamesButton.hidden=NO;
            self.viewProfileButton.hidden=YES;
        }
        else{
            self.noWagersView.hidden=YES;
            self.tableView.hidden=NO;
            [self.tableView reloadData];
        }
    }
    else if(self.segmentedControl.selectedSegmentIndex == 1){
        if(self.inProgressGamesWithWagers.count == 0){
            self.noWagersLabel.text=@"NO LIVE WAGERS";
            self.noWagersDescriptionLabel.text=@"You don’t have any live wagers. Check out available games and let it ride!";
            self.noWagersView.hidden=NO;
            self.tableView.hidden=YES;
            self.findGamesButton.hidden=NO;
            self.viewProfileButton.hidden=YES;
        }
        else{
            self.noWagersView.hidden=YES;
            self.tableView.hidden=NO;
            [self.tableView reloadData];
        }
    }
    else if(self.segmentedControl.selectedSegmentIndex == 2){
        if(self.finalResultsGamesWithWagers.count == 0){
            self.noWagersLabel.text=@"NO RECENT RESULTS";
            self.noWagersDescriptionLabel.text=@"Results from the last 48 hours are displayed here. Check out your profile to see your full wager history.";
            self.noWagersView.hidden=NO;
            self.tableView.hidden=YES;
            self.findGamesButton.hidden=YES;
            self.viewProfileButton.hidden=NO;
        }
        else{
            self.noWagersView.hidden=YES;
            self.tableView.hidden=NO;
            [self.tableView reloadData];
        }
    }
}
#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //Copy the DataSourceArray to finalWagersArray and is used by Tableview Delegate Methods
    
    self.finalWagersArray=[[NSMutableArray alloc]init];
    self.finalWagersArray =[[self dataSourceArray] mutableCopy];
    
    int countofRows=(int)self.finalWagersArray.count;
    
    NSString *nextPageURL;
    if(self.segmentedControl.selectedSegmentIndex==0) {
        nextPageURL = self.nextUpcomingPageURL;
    }
    else if(self.segmentedControl.selectedSegmentIndex==1) {
        nextPageURL = self.nextInProgressPageURL;
    }
    else if(self.segmentedControl.selectedSegmentIndex==2) {
        nextPageURL = self.nextResultsPageURL;
    }
    
    if(nextPageURL && self.finalWagersArray.count>0){
        countofRows = countofRows+1;
    }
    return countofRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *game=nil;
    
    if(self.finalWagersArray.count>indexPath.row){
        game=[self.finalWagersArray objectAtIndex:indexPath.row];
    }
    //Event *game=[[self dataSourceArray] objectAtIndex:indexPath.row];
    if(self.finalWagersArray.count>0 && self.finalWagersArray.count>indexPath.row){
        if([game.contextType isEqualToString:@"CustomEvent"]){
            return 175.0;
        }
        else{
            return 134.0;
        }
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event *game=nil;
    if(self.finalWagersArray.count>indexPath.row){
        game=[self.finalWagersArray objectAtIndex:indexPath.row];
    }
    
    //Event *game=[[self dataSourceArray] objectAtIndex:indexPath.row];
    if (self.finalWagersArray.count==indexPath.row && self.finalWagersArray.count>0){
        return [self loadingCell];
    }
    else if([game.contextType isEqualToString:@"CustomEvent"] && self.finalWagersArray.count>indexPath.row){
        GameListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomEventCell"];
        if (cell == nil) {
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"GameListCell" owner:self options:nil];
            cell = (GameListCell *)[nib objectAtIndex:1];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.customEventTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.customEventSubtitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
        }
        if(game.picture){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:game.picture]];
            __weak UIImageView *weakImageView = cell.customEventImageView;
            weakImageView.image = nil;
            [cell.customEventImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            cell.customEventImageView.image=nil;
        }
        cell.customEventTitleLabel.text=game.title.uppercaseString;
        if([game.status rangeOfString:@"finished"].location!=NSNotFound){
            int totalPoints=0;
            for(Wager *wager in [self wagersForSelectedSegment]){
                if(wager.customEvent.eventIdentifier==game.eventIdentifier){
                    totalPoints+=wager.points;
                }
            }
            if(totalPoints<0){
                cell.customEventSubtitleLabel.textColor=[UIColor colorWithRed:230.0/255.0 green:66.0/255.0 blue:40.0/255.0 alpha:1.0];
                cell.customEventSubtitleLabel.text=[NSString stringWithFormat:@"YOU LOST %dPTS",abs(totalPoints)];
            }
            else{
                cell.customEventSubtitleLabel.textColor=[UIColor colorWithRed:86.0/255.0 green:185.0/255.0 blue:27.0/255.0 alpha:1.0];
                cell.customEventSubtitleLabel.text=[NSString stringWithFormat:@"YOU WON %dPTS",abs(totalPoints)];
            }
        }
        else{
            cell.customEventSubtitleLabel.text=game.progress.uppercaseString;
        }
        return cell;
    }
    else{
        MyWagersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"MyWagersCell" owner:self options:nil];
            cell = (MyWagersCell *)[nib objectAtIndex:0];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.dateLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
            [cell.awayScoreLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:55.0]];
            [cell.homeScoreLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:55.0]];
        }
        if(game.awayTeam.image){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:game.awayTeam.image]];
            __weak UIImageView *weakImageView = cell.awayImageView;
            weakImageView.image = nil;
            [cell.awayImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            cell.awayImageView.image=nil;
        }
        if(game.homeTeam.image){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:game.homeTeam.image]];
            __weak UIImageView *weakImageView = cell.homeImageView;
            weakImageView.image = nil;
            [cell.homeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        }
        else{
            cell.homeImageView.image=nil;
        }
        cell.homeImageView.backgroundColor=[UIColor colorWithHexString:game.homeTeam.color];
        cell.awayImageView.backgroundColor=[UIColor colorWithHexString:game.awayTeam.color];
        cell.teamsLabel.attributedText=[Utils gameAttributedStringWithHometeam:game.homeTeam awayTeam:game.awayTeam];
        
        NSDate *date= [Utils dateFromGamblinoDateString:game.startTime];
        NSString *dateString= [Utils stringFromDate:date];
        
        if([game.status rangeOfString:@"progress"].location!=NSNotFound){
            cell.awayScoreLabel.text=[NSString stringWithFormat:@"%d",game.awayScore];
            cell.homeScoreLabel.text=[NSString stringWithFormat:@"%d",game.homeScore];
            cell.awayScoreLabel.hidden=NO;
            cell.homeScoreLabel.hidden=NO;
            cell.dateLabel.textColor=[UIColor colorWithRed:126.0/255.0 green:120.0/255.0 blue:105.0/255.0 alpha:1.0];
            cell.dateLabel.text= [game.progress uppercaseString];
        }
        else if([game.status rangeOfString:@"finished"].location!=NSNotFound){
            cell.awayScoreLabel.text=[NSString stringWithFormat:@"%d",game.awayScore];
            cell.homeScoreLabel.text=[NSString stringWithFormat:@"%d",game.homeScore];
            cell.awayScoreLabel.hidden=NO;
            cell.homeScoreLabel.hidden=NO;
            int totalPoints=0;
            for(Wager *wager in [self wagersForSelectedSegment]){
                if(wager.event.eventIdentifier==game.eventIdentifier){
                    totalPoints+=wager.points;
                }
            }
            if(totalPoints<0){
                cell.dateLabel.textColor=[UIColor colorWithRed:230.0/255.0 green:66.0/255.0 blue:40.0/255.0 alpha:1.0];
                cell.dateLabel.text=[NSString stringWithFormat:@"YOU LOST %dPTS",abs(totalPoints)];
            }
            else{
                cell.dateLabel.textColor=[UIColor colorWithRed:86.0/255.0 green:185.0/255.0 blue:27.0/255.0 alpha:1.0];
                cell.dateLabel.text=[NSString stringWithFormat:@"YOU WON %dPTS",abs(totalPoints)];
            }
        }
        else{
            cell.awayScoreLabel.hidden=YES;
            cell.homeScoreLabel.hidden=YES;
            cell.dateLabel.textColor=[UIColor colorWithRed:126.0/255.0 green:120.0/255.0 blue:105.0/255.0 alpha:1.0];
            cell.dateLabel.text= [[NSString stringWithFormat:@"%@ @ %@",dateString,game.homeTeam.displayName] uppercaseString];
        }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    //Table DataSource Array To Check Count and Then Access Data
    
    if(([self.finalWagersArray count]>0 || self.finalWagersArray!=nil) && [self.finalWagersArray count]>indexPath.row){
        
        Event *game=[self.finalWagersArray objectAtIndex:indexPath.row];
        
        UIImage *blurImage=[self.navigationController.parentViewController.view lightBlurImage];
        MyWagersDetailViewController *myWagersDetailViewController;
        if([game.contextType isEqualToString:@"CustomEvent"]){
            myWagersDetailViewController=[[MyWagersDetailViewController alloc] initWithBackgroundImage:blurImage game:game wagers:[self wagersForSelectedSegment] context:@"" context_id:0 nibName:@"MyWagersCustomEventDetailViewController" bundle:nil];
        }
        else{
            myWagersDetailViewController=[[MyWagersDetailViewController alloc] initWithBackgroundImage:blurImage game:game wagers:[self wagersForSelectedSegment]
               context:@"" context_id:0 nibName:nil bundle:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:myWagersDetailViewController animated:YES completion:^{}];
            self.wagerDetailViewController = myWagersDetailViewController;
        });
    }
}


- (UITableViewCell *)loadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    //Commented the Code to hide the loading Icon at bottom
    /*
    UIActivityIndicatorView *activityIndicator =
    [[UIActivityIndicatorView alloc]
     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.center;
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:activityIndicator];
    [activityIndicator startAnimating];
    */
     cell.tag = kLoadingCellTag;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kLoadingCellTag) {
        if(self.segmentedControl.selectedSegmentIndex==0 && self.nextUpcomingPageURL){
            [self loadUpcomingWagersAtIndex:self.currentUpcomingPage+1];
        }
        else if(self.segmentedControl.selectedSegmentIndex==1 && self.nextInProgressPageURL){
            [self loadInProgressWagersAtIndex:self.currentInProgressPage+1];
        }
        else if(self.segmentedControl.selectedSegmentIndex==2 && self.nextResultsPageURL){
            [self loadFinalResultsWagersAtIndex:self.currentResultsPage+1];
        }
    }
}
-(IBAction)findGamesAction:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartBetting" object:nil];
}

-(IBAction)viewProfileAction:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewProfile" object:nil];
}

- (NSArray*)wagersForSelectedSegment {
    if(self.segmentedControl.selectedSegmentIndex==0) {
        return self.upcomingWagers;
    }
    if(self.segmentedControl.selectedSegmentIndex==1) {
        return self.inProgressWagers;
    }
    if(self.segmentedControl.selectedSegmentIndex==2) {
        return self.resultsWagers;
    }
    return nil;
}

@end
