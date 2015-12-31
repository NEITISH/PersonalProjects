//
//  LoginViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/4/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "Constants.h"

@interface LoginViewController ()

@property(nonatomic,weak) IBOutlet UITextField *emailTextField;
@property(nonatomic,weak) IBOutlet UITextField *passwordTextField;
@property(nonatomic,weak) IBOutlet UIButton *cancelButton;
@property(nonatomic,weak) IBOutlet UIButton *nextButton;
@property(nonatomic,weak) IBOutlet UILabel *signInLabel;
@property(nonatomic,weak) IBOutlet UILabel *emailLabel;
@property(nonatomic,weak) IBOutlet UILabel *passwordLabel;
@property(nonatomic,weak) IBOutlet UIButton *forgotDetailsButton;
@property(nonatomic,weak) IBOutlet UILabel *orLabel;
@property(nonatomic,weak) IBOutlet UIView *contentView;

@end

@implementation LoginViewController

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
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.signInLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.emailLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]];
    [self.passwordLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]];
    [self.forgotDetailsButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]];
    [self.orLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification{
    if(!IS_IPHONE_4INCHES){
        [UIView setAnimationDuration:0.3];
        [self.contentView setTransform:CGAffineTransformMakeTranslation(0.0, -35.0)];
        [UIView commitAnimations];
    }
}

-(void)keyboardWillHide:(NSNotification*)notification{
    if(!IS_IPHONE_4INCHES){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [self.contentView setTransform:CGAffineTransformIdentity];
        [UIView commitAnimations];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)signInAction:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] authenticateWithUsername:self.emailTextField.text password:self.passwordTextField.text firstName:nil lastName:nil facebookToken:nil successBlock:^(NSString *username,NSString *authenticationToken){
        [self didLoginSucceed];
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not sign in. Please check your internet connection, email and password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

-(IBAction)cancelAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)forgotDetailsAction:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://app.gamblino.com/password/help"]];
}

-(IBAction)facebookAction:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] performFacebookAuthenticationWithSuccessBlock:^(NSString *username,NSString *authenticationToken){
        [self didLoginSucceed];
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not Sign In." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

-(void)didLoginSucceed{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationDidLoginSucceed" object:nil];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==self.emailTextField){
        [self.passwordTextField becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    return YES;
}

@end
