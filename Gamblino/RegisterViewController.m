//
//  RegisterViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/27/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "RegisterViewController.h"
#import "AddFriendsViewController.h"
#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "UIImage+Resize.h"
#import "Constants.h"
#import "AnalyticsManager.h"

@interface RegisterViewController ()

@property(nonatomic,weak) IBOutlet UITextField *firstNameTextField;
@property(nonatomic,weak) IBOutlet UITextField *lastNameTextField;
@property(nonatomic,weak) IBOutlet UITextField *emailTextField;
@property(nonatomic,weak) IBOutlet UITextField *passwordTextField;
@property(nonatomic,weak) IBOutlet UIButton *cancelButton;
@property(nonatomic,weak) IBOutlet UIButton *nextButton;
@property(nonatomic,weak) IBOutlet UILabel *titleLabel;
@property(nonatomic,weak) IBOutlet UILabel *firstNameLabel;
@property(nonatomic,weak) IBOutlet UILabel *lastNameLabel;
@property(nonatomic,weak) IBOutlet UILabel *emailLabel;
@property(nonatomic,weak) IBOutlet UILabel *passwordLabel;
@property(nonatomic,weak) IBOutlet UILabel *orLabel;
@property(nonatomic,weak) IBOutlet UIButton *addPhotoButton;
@property(nonatomic,weak) IBOutlet UIView *contentView;
@property(nonatomic,strong) UIImage *userImage;

-(IBAction)nextAction:(id)sender;
-(IBAction)cancelAction:(id)sender;
-(IBAction)photoAction:(id)sender;
-(IBAction)facebookAction:(id)sender;

@end

@implementation RegisterViewController

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
    [Flurry logEvent:@"Register Screen Loaded"];
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.firstNameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]];
    [self.lastNameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]];
    [self.emailLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]];
    [self.passwordLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]];
    [self.orLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.addPhotoButton.layer setCornerRadius:self.addPhotoButton.bounds.size.width/2];
    [self.addPhotoButton.layer setMasksToBounds:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification{
    if(!IS_IPHONE_4INCHES){
        [UIView setAnimationDuration:0.3];
        [self.contentView setTransform:CGAffineTransformMakeTranslation(0.0, -60.0)];
        self.addPhotoButton.hidden=YES;
        [UIView commitAnimations];
    }
}

-(void)keyboardWillHide:(NSNotification*)notification{
    if(!IS_IPHONE_4INCHES){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [self.contentView setTransform:CGAffineTransformIdentity];
        self.addPhotoButton.hidden=NO;
        [UIView commitAnimations];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)nextAction:(id)sender{
    [Flurry logEvent:@"Register Screen - Pressed Next"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] authenticateWithUsername:self.emailTextField.text password:self.passwordTextField.text firstName:self.firstNameTextField.text lastName:self.lastNameTextField.text facebookToken:nil successBlock:^(NSString *username,NSString *authenticationToken){
        [Flurry logEvent:@"Register success"];
        [self signupDidSucceed];
    }failureBlock:^(NSError *error){
        [Flurry logEvent:@"Register failed"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to sign up." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

-(IBAction)cancelAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)photoAction:(id)sender{
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:nil otherButtonTitles:@"Photo Library",@"Camera",nil];
    [actionSheet showInView:self.view];
}

-(IBAction)facebookAction:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] performFacebookAuthenticationWithSuccessBlock:^(NSString *username,NSString *authenticationToken){
        [self signupDidSucceed];
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not Sign Up." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==0){
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.delegate=self;
        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{}];
    }
    else if(buttonIndex==1){
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.delegate=self;
        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:^{}];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    self.userImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.addPhotoButton setImage:self.userImage forState:UIControlStateNormal];
    self.addPhotoButton.layer.borderColor=[UIColor whiteColor].CGColor;
    self.addPhotoButton.layer.borderWidth=2.0f;
    [self.addPhotoButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
}

-(void)signupDidSucceed{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationDidSignupSucceed" object:nil];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    
    if (self.userImage) {
        [self uploadImage];
    }
}

-(void)uploadImage{
    UIImage *resizedImage = [self.userImage resizedImageToFitInSize:CGSizeMake(512.0f, 512.0f) scaleIfSmaller:NO];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage,0.7);
    
    NSURL *url=[[NetworkManager sharedInstance].requestOperationManager.baseURL URLByAppendingPathComponent:@"me/picture"];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url];
    NSString *authToken=[[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultsAccessTokenKey];
    [request addValue:authToken forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:imageData];
    
    AFHTTPRequestOperation *operation=[[NetworkManager sharedInstance].requestOperationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error=%@",error.description);
    }];
    
    [operation start];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==self.firstNameTextField){
        [self.lastNameTextField becomeFirstResponder];
    }
    else if(textField==self.lastNameTextField){
        [self.emailTextField becomeFirstResponder];
    }
    else if(textField==self.emailTextField){
        [self.passwordTextField becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    return YES;
}

@end
