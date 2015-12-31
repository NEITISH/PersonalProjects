//
//  PoolsInfoViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 3/17/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "PoolsTypeInfoViewController.h"
#import "PoolType.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "AddFriendsViewController.h"

@interface PoolsTypeInfoViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,weak) IBOutlet UIButton *useThisPoolButton;
@property (nonatomic,weak) IBOutlet UIButton *closePoolButton;
@property (nonatomic,strong) IBOutlet UITextView *poolDescriptionTV;

@property (nonatomic,strong) IBOutlet UIImageView *poolTypeImageView;
@property (nonatomic,strong) IBOutlet UILabel *poolsTypeLabel;

@property (nonatomic,strong) PoolType *pooltype;
@property (nonatomic,strong) UIImage *blurImage;

@end

@implementation PoolsTypeInfoViewController

- (id)initWithBackgroundImage:(UIImage*)image pool:(PoolType*)pooltype{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.pooltype=pooltype;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.backgroundImageView setImage:self.blurImage];
    [self.useThisPoolButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.closePoolButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.poolsTypeLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    self.poolDescriptionTV.delegate=self;
    self.poolDescriptionTV.text=self.pooltype.poolTypeDescription;
    self.poolDescriptionTV.textContainerInset = UIEdgeInsetsZero;
    self.poolDescriptionTV.textContainer.lineFragmentPadding = 0;
    
    if(self.pooltype.image){
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.pooltype.image]];
        __weak UIImageView *weakImageView = self.poolTypeImageView;
        weakImageView.image = nil;
        [self.poolTypeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    self.poolsTypeLabel.text=self.pooltype.title.uppercaseString;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)useThisPoolAction:(id)sender{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *params = @{@"title":self.pooltype.title,@"pool_type_id":@(self.pooltype.poolTypeIdentifier)};
    [[NetworkManager sharedInstance].requestOperationManager POST:@"pools" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if([[responseObject allKeys] containsObject:@"pool"]){
            NSDictionary *poolDic=[responseObject valueForKey:@"pool"];
            Pool *pool=[Pool modelObjectWithDictionary:poolDic];
            
            
            //if(self.delegate){
                //[self.delegate poolsTypeInfoViewController:self didCreatePool:pool];
                [self.delegate poolsInfoViewController:self didCreatePool:pool];
                [self closeAction:nil];
            //}
           
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

@end
