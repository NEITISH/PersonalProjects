//
//  ConferencesViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/14/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "ConferencesViewController.h"
#import "Conference.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "League.h"
#import "Constants.h"

@interface ConferencesViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) League *league;
@property (nonatomic,strong) Conference *selectedConference;
@property (nonatomic,strong) NSArray *conferences;

@end

@implementation ConferencesViewController

- (id)initWithBackgroundImage:(UIImage*)image league:(League*)league selectedConference:(Conference*)conference delegate:(id)delegate{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.league=league;
        self.delegate=delegate;
        if(conference){
            self.selectedConference=conference;
        }
        else{
            self.selectedConference=[self allConferencesObject];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.backgroundImageView setImage:self.blurImage];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    self.conferences=@[[self allConferencesObject]];
    [self loadConferences];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)loadConferences{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *remotePath=[NSString stringWithFormat:@"leagues/%d/conferences",self.league.leaguesIdentifier];
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *conferencesDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([conferencesDictionary.allKeys containsObject:@"conferences"]){
            NSArray *conferencesValue=[conferencesDictionary valueForKey:@"conferences"];
            NSMutableArray *conferencesArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in conferencesValue){
                Conference *conference=[[Conference alloc] initWithDictionary:dic];
                [conferencesArray addObject:conference];
            }
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"shortName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            [conferencesArray setArray:[conferencesArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
            [conferencesArray insertObject:[self allConferencesObject] atIndex:0];
            self.conferences=conferencesArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

-(Conference*)allConferencesObject{
    Conference *conference=[[Conference alloc] init];
    if(self.league.custom){
        conference.shortName=@"ALL EVENTS";
    }
    else{
        conference.shortName=@"ALL CONFERENCES";
    }
    conference.conferenceId=kAllConferencesConferenceID;
    return conference;
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.conferences count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Conference *conference=[self.conferences objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        [cell.textLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    cell.textLabel.text=conference.shortName.uppercaseString;
    if(conference.conferenceId==self.selectedConference.conferenceId){
        cell.accessoryView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-checkmark"]];
    }
    else{
        cell.accessoryView=nil;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedConference=[self.conferences objectAtIndex:indexPath.row];
    [self.tableView reloadData];
    if(self.delegate){
        [self.delegate conferencesViewController:self didSelectConference:self.selectedConference];
    }
    //should not have to encapsulate that, but for some reason, needed on iOS7.0
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{}];
    });
}


@end
