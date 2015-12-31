//
//  ContestMainViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/8/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "ContestMainViewController.h"
#import "NationalContestCell.h"
#import "LocalContestCell.h"
#import "Contest.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "Constants.h"
#import "LocationManager.h"
#import "Utils.h"
#import "ContestInfoViewController.h"
#import "UIView+Blur.h"
#import "ContestDetailsViewController.h"
#import "Sponsor.h"
#import "NoLocalContestCell.h"
#import "AnalyticsManager.h"

@interface ContestMainViewController ()

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSArray *nationalContests;
@property(nonatomic,strong) NSArray *localContests;
@property (nonatomic,assign) int remainingCallsToProcess;

@end

@implementation ContestMainViewController

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
    [Flurry logEvent:@"Contest list Screen Loaded"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.remainingCallsToProcess=2;
    [self loadNationalContests];
    [self loadLocalContests];
}

-(void)loadNationalContests{
    NSString *remotePath=@"/v2/contests";
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *contestsDictionary){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([contestsDictionary.allKeys containsObject:@"contests"]){
            NSArray *contestsValue=[contestsDictionary valueForKey:@"contests"];
            NSMutableArray *nationalContestsArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in contestsValue){
                Contest *contest=[[Contest alloc] initWithDictionary:dic];
                if([contest.type isEqualToString:kContestTypeNational]){
                    [nationalContestsArray addObject:contest];
                }
            }
            self.nationalContests=nationalContestsArray;
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

-(void)loadLocalContests{
    NSString *remotePath=@"/v2/contests";
    NSDictionary *parameters=nil;
    if([[LocationManager sharedInstance] currentLocation]){
        NSNumber *lat=[NSNumber numberWithDouble:[LocationManager sharedInstance].currentLocation.coordinate.latitude];
        NSNumber *lon=[NSNumber numberWithDouble:[LocationManager sharedInstance].currentLocation.coordinate.longitude];
        parameters=@{@"lat":lat,@"lon":lon};
    }
    [[NetworkManager sharedInstance] GET:remotePath withParameters:parameters successBlock:^(NSDictionary *contestsDictionary){
        self.remainingCallsToProcess--;
        if(self.remainingCallsToProcess==0){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
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


#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return 1;
    }
    else if(section==1){
        return self.localContests.count;
    }
    else if(section==2){
        if(self.localContests.count==0){
            return 1;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return 278.0;
    }
    else{
        return 196.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0 || section == 2){
        return 0.0;
    }
    else{
        return 30.0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 1){
        UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"localContests"]];
        return imageView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0){
        NationalContestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NationalCell"];
        if (cell == nil) {
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"NationalContestCell" owner:self options:nil];
            cell = (NationalContestCell *)[nib objectAtIndex:0];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.nationalContestHeaderLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:15.0]];
            cell.scrollView.delegate=self;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapAction:)];
            [recognizer setNumberOfTapsRequired:1];
            cell.scrollView.userInteractionEnabled = YES;
            [cell.scrollView addGestureRecognizer:recognizer];
        }
        cell.scrollView.contentSize=CGSizeMake(320.0*self.nationalContests.count, cell.scrollView.bounds.size.height);
        cell.pageControl.numberOfPages=self.nationalContests.count;
        for(UIView *subview in cell.scrollView.subviews){
            [subview removeFromSuperview];
        }
        for(Contest *contest in self.nationalContests){
            UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(320.0*[self.nationalContests indexOfObject:contest], 0, 320.0, cell.scrollView.bounds.size.height)];
            imageView.contentMode=UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds=YES;
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:contest.bigPictureUrl]];
            __weak UIImageView *weakImageView = imageView;
            weakImageView.image = nil;
            [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
            [cell.scrollView addSubview:imageView];
        }
        
        return cell;
    }
    else if(indexPath.section==1){
        LocalContestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocalCell"];
        if (cell == nil) {
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"LocalContestCell" owner:self options:nil];
            cell = (LocalContestCell *)[nib objectAtIndex:0];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.contestTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        }
        Contest *contest=[self.localContests objectAtIndex:indexPath.row];
        cell.contestTitleLabel.text=contest.title;
        cell.contestDescriptionLabel.text=contest.subtitle;
        
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:contest.sponsor.pictureUrl]];
        __weak UIImageView *weakImageView = cell.contestImageView;
        weakImageView.image = nil;
        [cell.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
        
        return cell;
    }
    else if(indexPath.section==2){
        NoLocalContestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoLocalContestCell"];
        if (cell == nil) {
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"NoLocalContestCell" owner:self options:nil];
            cell = (NoLocalContestCell *)[nib objectAtIndex:0];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        return cell;
    }

    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==1){
        Contest *contest=[self.localContests objectAtIndex:indexPath.row];
        [self didSelectContest:contest];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.bounds.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    NationalContestCell *cell=(NationalContestCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.pageControl.currentPage = page;
}

- (void)scrollViewTapAction:(id)sender{
    CGPoint touchLocation = [sender locationOfTouch:0 inView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    if(indexPath.section==0){
        NationalContestCell *cell=(NationalContestCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        Contest *contest=[self.nationalContests objectAtIndex:cell.pageControl.currentPage];
        [self didSelectContest:contest];
    }
}

- (void)didSelectContest:(Contest*)contest{
    if(contest.joined){
        UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
        ContestDetailsViewController *contestDetailsViewController=[[ContestDetailsViewController alloc] initWithBackgroundImage:blurImage contest:contest];
        UINavigationController *contestDetailsNavigationController=[[UINavigationController alloc] initWithRootViewController:contestDetailsViewController];
        contestDetailsNavigationController.navigationBarHidden=YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:contestDetailsNavigationController animated:YES completion:^{}];
        });
    }
    else{
        UIImage *blurImage=[self.navigationController.parentViewController.view lightBlurImage];
        ContestInfoViewController *contestInfoViewController=[[ContestInfoViewController alloc] initWithBackgroundImage:blurImage contest:contest game:nil];
        contestInfoViewController.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:contestInfoViewController animated:YES completion:^{}];
        });
    }
}

-(void)contestInfoViewController:(ContestInfoViewController *)contestInfoViewController didJoinContest:(Contest *)contest{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        UIImage *blurImage=[self.navigationController.parentViewController.view darkBlurImage];
        ContestDetailsViewController *contestDetailsViewController=[[ContestDetailsViewController alloc] initWithBackgroundImage:blurImage contest:contest];
        UINavigationController *contestDetailsNavigationController=[[UINavigationController alloc] initWithRootViewController:contestDetailsViewController];
        contestDetailsNavigationController.navigationBarHidden=YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:contestDetailsNavigationController animated:YES completion:^{}];
        });
    }];
}

@end
