//
//  GameListViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/12/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "GameListViewController.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "Event.h"
#import "GameListCell.h"
#import "League.h"
#import "Team.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+Gamblino.h"
#import "Utils.h"
#import "Line.h"
#import "ConferencesViewController.h"
#import "UIView+Blur.h"
#import "Conference.h"
#import "Constants.h"
#import "IndividualGameViewController.h"
#import "Participant.h"
#import "AnalyticsManager.h"

@interface GameListViewController ()

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIButton *conferenceButton;
@property(nonatomic,strong) NSArray *games;
@property(nonatomic,strong) NSArray *filteredGames;
@property(nonatomic,strong) NSArray *filteredGamesForTable;
@property(nonatomic,strong) Conference *selectedConference;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,weak) IndividualGameViewController *selectedIndividualGameViewController;

@end

@implementation GameListViewController

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
    [Flurry logEvent:@"Game List Screen Loaded"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGames) name:@"NotificationDidLoginSucceed" object:nil];
    [self.conferenceButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    if(self.league.custom){
        [self.conferenceButton setTitle:@"ALL EVENTS" forState:UIControlStateNormal];
    }
    else{
        [self.conferenceButton setTitle:@"ALL CONFERENCES" forState:UIControlStateNormal];
    }
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    self.games=[[NSArray alloc] init];
    self.filteredGames=[[NSArray alloc] init];
    [self loadGames];
    self.timer=[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(loadGames) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self isMovingFromParentViewController]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)loadGames{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *remotePath=[NSString stringWithFormat:@"v2/leagues/%d/events",self.league.leaguesIdentifier];
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *eventsDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([eventsDictionary.allKeys containsObject:@"events"]){
            NSArray *eventsValue=[eventsDictionary valueForKey:@"events"];
            NSMutableArray *eventsArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in eventsValue){
                Event *event=[[Event alloc] initWithDictionary:dic];
                if(event.eventIdentifier == self.selectedIndividualGameViewController.game.eventIdentifier) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.selectedIndividualGameViewController.game = event;
                        [self.selectedIndividualGameViewController refreshScreen];
                    });
                }
                [eventsArray addObject:event];
            }
            self.games=eventsArray;
            [self sortGamesPerDate];
            [self filterGameListWithSelectedConference];
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

- (void)sortGamesPerDate{
    self.games = [self.games sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(Event *game1, Event* game2) {
        NSDate *date1 = [Utils dateFromGamblinoDateString:game1.startTime];
        NSDate *date2 = [Utils dateFromGamblinoDateString:game2.startTime];
        return [date1 compare:date2];
    }];
}

- (void)filterGameListWithSelectedConference{
    if(!self.selectedConference || self.selectedConference.conferenceId==kAllConferencesConferenceID){
        self.filteredGames=self.games;
    }
    else{
        NSMutableArray *filteredGames=[[NSMutableArray alloc] init];
        for(Event *game in self.games){
            if([game.contextType isEqualToString:@"CustomEvent"]){
                if(game.conferenceId==self.selectedConference.conferenceId){
                    [filteredGames addObject:game];
                }
            }
            else{
                if(game.homeTeam.conferenceId==self.selectedConference.conferenceId || game.awayTeam.conferenceId==self.selectedConference.conferenceId){
                    [filteredGames addObject:game];
                }
            }
        }
        self.filteredGames=filteredGames;
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
    self.filteredGamesForTable=[self.filteredGames mutableCopy];
    return [self.filteredGamesForTable count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *game=[self.filteredGamesForTable objectAtIndex:indexPath.row];
    if([game.contextType isEqualToString:@"CustomEvent"]){
        return 175.0;
    }
    else{
        return 133.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *game=[self.filteredGamesForTable objectAtIndex:indexPath.row];
    if([game.contextType isEqualToString:@"CustomEvent"]){
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
        cell.customEventSubtitleLabel.text=game.subtitle.uppercaseString;
        return cell;

    }
    else{
        GameListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"GameListCell" owner:self options:nil];
            cell = (GameListCell *)[nib objectAtIndex:0];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.dateLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
            [cell.betsLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
            [cell.underLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
            [cell.overLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
            cell.indexOfCurrentLine=0;
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
        cell.teamsLabel.attributedText=[Utils gameAttributedStringWithHometeam:game.homeTeam awayTeam:game.awayTeam];;
        
        NSDate *date= [Utils dateFromGamblinoDateString:game.startTime];
        NSString *dateString= [Utils stringFromDate:date];
        cell.dateLabel.text= [[NSString stringWithFormat:@"%@ @ %@",dateString,game.homeTeam.displayName] uppercaseString];
        
        double lineUnder=0;
        double lineOver=0;
        for(Line *line in game.lines){
            if([line.type isEqualToString:kUnderType]){
                lineUnder=line.line;
            }
            if([line.type isEqualToString:kOverType]){
                lineOver=line.line;
            }
        }
        cell.underLabel.text=[NSString stringWithFormat:@"U%g",lineUnder];
        cell.overLabel.text=[NSString stringWithFormat:@"O%g",lineOver];
        cell.betsLabel.text=[NSString stringWithFormat:@"%d BETS",game.totalWagers];
//        for(int i=0;i<game.participants.count && i<20;i++){
//            Participant *participant=[game.participants objectAtIndex:i];
//            UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(15.0*i,0,15,15)];
//            imageView.contentMode=UIViewContentModeScaleAspectFill;
//            imageView.clipsToBounds=YES;
//            if(participant.user.picture && participant.user.picture.length>0){
//                imageView.backgroundColor=[UIColor blackColor];
//                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:participant.user.picture]];
//                __weak UIImageView *weakImageView = imageView;
//                [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
//                    [weakImageView setImage:image];
//                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
//                    NSLog(@"error=%@",[error description]);
//                }];
//                [cell.userPicturesView addSubview:imageView];
//            }
//            else{
//                imageView.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
//                [cell.userPicturesView addSubview:imageView];
//                UILabel *initialsLabel=[[UILabel alloc] initWithFrame:imageView.frame];
//                [initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:12.0]];
//                initialsLabel.textAlignment=UITextAlignmentCenter;
//                initialsLabel.textColor=[UIColor whiteColor];
//                initialsLabel.text=[NSString stringWithFormat:@"%@%@",[participant.user.firstName.uppercaseString substringToIndex:1],[participant.user.lastName.uppercaseString substringToIndex:1]];
//                [cell.userPicturesView addSubview:initialsLabel];
//            }
//            
//        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *game=[self.filteredGamesForTable objectAtIndex:indexPath.row];
    UIImage *blurImage=[self.navigationController.parentViewController.view lightBlurImage];
    IndividualGameViewController *individualGameViewController=[[IndividualGameViewController alloc] initWithBackgroundImage:blurImage game:game];
    UINavigationController *individualGameNavigationController=[[UINavigationController alloc] initWithRootViewController:individualGameViewController];
    individualGameNavigationController.navigationBarHidden=YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:individualGameNavigationController animated:YES completion:^{}];
        self.selectedIndividualGameViewController = individualGameViewController;
    });
}

-(IBAction)conferenceAction:(id)sender{
    UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
    ConferencesViewController *conferencesViewController=[[ConferencesViewController alloc] initWithBackgroundImage:blurImage league:self.league selectedConference:self.selectedConference delegate:self];
    [self presentViewController:conferencesViewController animated:YES completion:^{}];
}

-(void)conferencesViewController:(ConferencesViewController *)conferencesViewController didSelectConference:(Conference *)conference{
    self.selectedConference=conference;
    [self.conferenceButton setTitle:conference.shortName forState:UIControlStateNormal];
    [self filterGameListWithSelectedConference];
}

-(void)gameListCellShowNextLine:(GameListCell *)gameListCell{
    NSIndexPath *indexPath=[self.tableView indexPathForCell:gameListCell];
    Event *game=[self.filteredGamesForTable objectAtIndex:indexPath.row];
    if(game.lines.count==0){
        return;
    }
    int indexOfNextLine=gameListCell.indexOfCurrentLine+1;
    if(game.lines.count<indexOfNextLine+1){
        indexOfNextLine=0;
    }
    gameListCell.indexOfCurrentLine=indexOfNextLine;
    Line *nextLine=[game.lines objectAtIndex:indexOfNextLine];
    [self showLine:nextLine onCell:gameListCell];
}

-(void)showLine:(Line*)line onCell:(GameListCell*)cell{
    
}

@end
