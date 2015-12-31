//
//  PoolsInfoViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 3/17/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "PoolsInfoViewController.h"
#import "PoolType.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"

@interface PoolsInfoViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,weak) IBOutlet UIButton *joinPoolButton;
@property (nonatomic,weak) IBOutlet UIButton *closePoolButton;
@property (nonatomic,weak) IBOutlet UIButton *declinePoolButton;

@property (nonatomic,weak) IBOutlet UITextView *poolDescriptionTextView;

@property (nonatomic,strong) IBOutlet UIImageView *poolTypeImageView;
@property (nonatomic,strong) IBOutlet UIImageView *poolImageView;
@property (nonatomic,strong) IBOutlet UILabel *poolsNameLabel;
@property (nonatomic,strong) IBOutlet UILabel *poolsTypeLabel;
@property (nonatomic,strong) IBOutlet UILabel *dateLabel;
@property (nonatomic,strong) IBOutlet UILabel *numberParticipantsLabel;
@property (nonatomic,strong) IBOutlet UIScrollView *usersView;

@property (nonatomic,strong) Pool *pool;
@property (nonatomic,strong) UIImage *blurImage;

@end

@implementation PoolsInfoViewController

- (id)initWithBackgroundImage:(UIImage*)image pool:(Pool*)pool{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.pool=pool;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.backgroundImageView setImage:self.blurImage];
    [self.joinPoolButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.closePoolButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.declinePoolButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.poolsNameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.poolsTypeLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
    [self.dateLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];
    [self.numberParticipantsLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:10.0]];

    if(self.pool.joined){
        self.joinPoolButton.hidden=YES;
        self.declinePoolButton.hidden=YES;
    }
    
    self.poolDescriptionTextView.text=self.pool.poolType.poolTypeDescription;
    
    if(self.pool.image){
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.pool.image]];
        __weak UIImageView *weakImageView = self.poolImageView;
        weakImageView.image = nil;
        [self.poolImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    if(self.pool.poolType && self.pool.poolType.image){
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.pool.poolType.image]];
        __weak UIImageView *weakImageView = self.poolTypeImageView;
        weakImageView.image = nil;
        [self.poolTypeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    self.poolsNameLabel.text=self.pool.poolType.title.uppercaseString;
    self.poolsTypeLabel.text=self.pool.poolType.subtitle.uppercaseString;
    NSDate *poolActiveDate = [Utils dateFromGamblinoDateString:self.pool.poolType.activeAt];
    NSDate *poolEndDate = [Utils dateFromGamblinoDateString:self.pool.poolType.endsAt];
    NSDate *today= [NSDate date];
    if ([poolActiveDate laterDate:today] == poolActiveDate) {
        self.dateLabel.text=[NSString stringWithFormat:@"STARTS %@",[Utils monthDayStringFromDate:poolActiveDate].uppercaseString];
    } else {
        self.dateLabel.text=[NSString stringWithFormat:@"ENDS %@",[Utils monthDayStringFromDate:poolEndDate].uppercaseString];
    }
    
    
    self.numberParticipantsLabel.text=[NSString stringWithFormat:@"%d MEMBERS",self.pool.totalUsers];    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)joinPoolAction:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *remotePath=[NSString stringWithFormat:@"pools/%d/join",self.pool.poolIdentifier];
    [[NetworkManager sharedInstance] PUT:remotePath withParameters:nil successBlock:^(NSDictionary *resultDictionary) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        Pool *pool=[[Pool alloc] initWithDictionary:resultDictionary];
        if(self.delegate){
            [self.delegate poolsInfoViewController:self didJoinPool:pool];
        }
    } failureBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(IBAction)declinePoolAction:(id)sender{
    /*
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *remotePath=[NSString stringWithFormat:@"pools/%d/leave",self.pool.poolIdentifier];
    
    [[NetworkManager sharedInstance] PUT:remotePath withParameters:nil successBlock:^(NSDictionary *resultDictionary) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self dismissViewControllerAnimated:YES completion:^{}];
        
    } failureBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    */
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *remotePath=[NSString stringWithFormat:@"pools/%d/leave",self.pool.poolIdentifier];
    
    [[NetworkManager sharedInstance] PUT:remotePath withParameters:nil successBlock:^(NSDictionary *poolDictionary){
        
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self closeAction:nil];
        
    }failureBlock:^(NSError *error){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
    
}

@end
