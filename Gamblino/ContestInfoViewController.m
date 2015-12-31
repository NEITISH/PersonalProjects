//
//  ContestInfoViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/27/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "ContestInfoViewController.h"
#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "GradientView.h"
#import "UIColor+Gamblino.h"
#import "Team.h"
#import "UIImageView+AFNetworking.h"
#import "Sponsor.h"
#import "User.h"

@interface ContestInfoViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,weak) IBOutlet UIImageView *contestImageView;
@property (nonatomic,weak) IBOutlet UIButton *joinContestButton;
@property (nonatomic,weak) IBOutlet UILabel *contestTitleLabel;
@property (nonatomic,weak) IBOutlet UITextView *contestDescriptionTextView;
@property (nonatomic,weak) IBOutlet GradientView *gradientView;
@property (nonatomic,weak) IBOutlet UIView *userPicturesView;
@property (nonatomic,weak) IBOutlet UILabel *numberOfUsersLabel;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) Contest *contest;
@property (nonatomic,strong) Event *game;
@property (nonatomic,weak) IBOutlet UIButton *CloseContestButton;
@property (nonatomic,weak) IBOutlet UIView *LabelView;

@end

@implementation ContestInfoViewController

- (id)initWithBackgroundImage:(UIImage*)image contest:(Contest*)contest game:(Event*)game{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.contest=contest;
        self.game=game;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.game){
        UIColor *awayTeamColor=[UIColor colorWithHexString:self.game.awayTeam.color];
        UIColor *homeTeamColor=[UIColor colorWithHexString:self.game.homeTeam.color];
        self.gradientView.leftColor=[awayTeamColor colorByChangingAlphaTo:0.5];
        self.gradientView.rightColor=[homeTeamColor colorByChangingAlphaTo:0.5];
    }
    else{
        self.gradientView.hidden=YES;
    }
    [self.backgroundImageView setImage:self.blurImage];
    
    if (self.contest.joined) {
        [self.CloseContestButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        [self.joinContestButton setHidden:YES];
        [self.LabelView setHidden:YES];
      [self.contestDescriptionTextView setFrame:CGRectMake(6, 90, 288, 201)];

    }
    else{
        [self.joinContestButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
                [self.CloseContestButton setHidden:YES];
        [self.contestDescriptionTextView setFrame:CGRectMake(6, 90, 288, 155)];

    }

    [self.contestTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.numberOfUsersLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
    self.contestTitleLabel.text=self.contest.title;
    self.contestDescriptionTextView.text=self.contest.contestDescription;
    NSMutableURLRequest *request;
    if([self.contest.type isEqualToString:@"national"]){
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.contest.bigPictureUrl]];
    }
    else{
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.contest.sponsor.pictureUrl]];
    }
    __weak UIImageView *weakImageView = self.contestImageView;
    weakImageView.image = nil;
    [weakImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
        [weakImageView setImage:image];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(IBAction)CloseContestButton:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{}];

}

-(IBAction)joinContestAction:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *remotePath=[NSString stringWithFormat:@"v2/contests/%d/join",self.contest.contestIdentifier];
    [[NetworkManager sharedInstance] PUT:remotePath withParameters:nil successBlock:^(NSDictionary *resultDictionary) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([resultDictionary.allKeys containsObject:@"contest"]){
            NSDictionary *contestValue=[resultDictionary valueForKey:@"contest"];
            Contest *contest=[[Contest alloc] initWithDictionary:contestValue];
            if(self.delegate){
                [self.delegate contestInfoViewController:self didJoinContest:contest];
            }
        }
    } failureBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)contestRulesAction:(id)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Contest Rules" message:self.contest.rules delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];

}

- (IBAction)CloseContest:(id)sender {
   [self dismissViewControllerAnimated:YES completion:^{}];

}
@end
