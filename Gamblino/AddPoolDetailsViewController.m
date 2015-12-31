//
//  AddPoolDetailsViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 3/15/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "AddPoolDetailsViewController.h"
#import "UIImage+Resize.h"
#import "NetworkManager.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "AddFriendsViewController.h"

@interface AddPoolDetailsViewController ()

@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIButton *photoButton;
@property (nonatomic,weak) IBOutlet UILabel *poolNameLabel;
@property (nonatomic,weak) IBOutlet UITextField *poolNameTextField;
@property (nonatomic,weak) IBOutlet UIButton *doneButton;
@property (nonatomic,strong) UIImage *poolImage;

@end

@implementation AddPoolDetailsViewController

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
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.poolNameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]];
    [self.doneButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.photoButton.layer setCornerRadius:self.photoButton.bounds.size.width/2];
    [self.photoButton.layer setMasksToBounds:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.poolNameTextField becomeFirstResponder];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneAction:(id)sender {
    if(!self.poolImage) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select a pool image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if(self.poolNameTextField.text.length==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a name for the pool" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImage *resizedImage = [self.poolImage resizedImageToFitInSize:CGSizeMake(512.0f, 512.0f) scaleIfSmaller:NO];
    NSDictionary *params = @{@"title":self.poolNameTextField.text,@"pool_type_id":@(self.poolType.poolTypeIdentifier)};
    [[NetworkManager sharedInstance].requestOperationManager POST:@"pools" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(self.poolImage){
            NSUUID  *UUID = [NSUUID UUID];
            NSString* fileName = [NSString stringWithFormat:@"%@.jpg",[UUID UUIDString]];
            [formData appendPartWithFileData:UIImageJPEGRepresentation(resizedImage, 0.7) name:@"image" fileName:fileName mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([[responseObject allKeys] containsObject:@"pool"]){
            NSDictionary *poolDic=[responseObject valueForKey:@"pool"];
            Pool *pool=[Pool modelObjectWithDictionary:poolDic];
            AddFriendsViewController *addFriendsViewController = [[AddFriendsViewController alloc] init];
            addFriendsViewController.pool=pool;
            [self.navigationController pushViewController:addFriendsViewController animated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (IBAction)addPhotoAction:(id)sender {
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:nil otherButtonTitles:@"Photo Library",@"Camera",nil];
    [actionSheet showInView:self.view];
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
    self.poolImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.photoButton setImage:self.poolImage forState:UIControlStateNormal];
    self.photoButton.layer.borderColor=[UIColor whiteColor].CGColor;
    self.photoButton.layer.borderWidth=2.0f;
    [self.photoButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
}

@end
