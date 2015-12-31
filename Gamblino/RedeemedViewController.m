//
//  RedeemedViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/21/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "RedeemedViewController.h"
#import "Contest.h"
#import "UIImageView+AFNetworking.h"
#import "Prize.h"
#import "User.h"
#import "Utils.h"

@interface RedeemedViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *blurImageView;
@property (nonatomic,weak) IBOutlet UIImageView *contestImageView;
@property (nonatomic,weak) IBOutlet UILabel *contestTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *prizeMessageLabel;
@property (nonatomic,weak) IBOutlet UILabel *prizeDescriptionLabel;
@property (nonatomic,weak) IBOutlet UIImageView *userImageView;
@property (nonatomic,weak) IBOutlet UILabel *redeemedLabel;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) Notification *notification;

@end

@implementation RedeemedViewController

- (id)initWithBackgroundImage:(UIImage*)image notification:(Notification*)notification{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.notification=notification;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.blurImageView setImage:self.blurImage];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.notification.contest.bigPictureUrl]];
    __weak UIImageView *weakImageView = self.contestImageView;
    weakImageView.image = nil;
    [self.contestImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
        [weakImageView setImage:image];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
    [self.prizeMessageLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.contestTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.redeemedLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    self.contestTitleLabel.text=self.notification.contest.title;
    self.prizeMessageLabel.text=self.notification.prize.redeemableMessage;
    self.prizeDescriptionLabel.text=self.notification.prize.prizeDescription;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
