//
//  WelcomeViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/25/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "Constants.h"
#import "Flurry.h"

@interface WelcomeViewController ()

@property(nonatomic,weak) IBOutlet UILabel *welcomeLabel;
@property(nonatomic,weak) IBOutlet UIButton *createAccountButton;
@property(nonatomic,weak) IBOutlet UIButton *signInButton;
@property(nonatomic,weak) IBOutlet UIView *createAccountOrSignInLabel;

@end

@implementation WelcomeViewController

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
    [Flurry logEvent:@"Welcome to Gamblino screen"];
    self.navigationController.navigationBarHidden=YES;
    [self.welcomeLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:30.0]];
    [self.createAccountButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.signInButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    if(!IS_IPHONE_4INCHES){
        self.createAccountOrSignInLabel.hidden=YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)createAccountAction:(id)sender{
    RegisterViewController *registerViewController=[[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

-(IBAction)signInAction:(id)sender{
    LoginViewController *loginViewController=[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:loginViewController animated:YES];
}

-(IBAction)termsAndConditionsAction:(id)sender{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"termsAndConditions" ofType:@"txt"];
    NSString *legalStuff = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Terms Of Use" message:legalStuff delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

@end
