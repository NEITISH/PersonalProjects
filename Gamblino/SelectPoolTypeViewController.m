//
//  SelectPoolTypeViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 3/15/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "SelectPoolTypeViewController.h"
#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "PoolType.h"
#import "PoolTypeCell.h"
#import "UIImageView+AFNetworking.h"
#import "AddPoolDetailsViewController.h"
#import "UIView+Blur.h"
#import "PoolsTypeInfoViewController.h"
#import "AddFriendsViewController.h"


@interface SelectPoolTypeViewController ()

@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *poolTypes;

@end

@implementation SelectPoolTypeViewController

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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self loadPoolTypes];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)loadPoolTypes{
    NSString *remotePath=@"pools/types";
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *poolTypesDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([poolTypesDictionary.allKeys containsObject:@"pool_types"]){
            NSArray *poolTypesValue=[poolTypesDictionary valueForKey:@"pool_types"];
            NSMutableArray *poolTypesArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in poolTypesValue){
                PoolType *poolType=[[PoolType alloc] initWithDictionary:dic];
                [poolTypesArray addObject:poolType];
            }
            self.poolTypes=poolTypesArray;
            [self.tableView reloadData];
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.poolTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PoolType *poolType=[self.poolTypes objectAtIndex:indexPath.row];
    PoolTypeCell *cell=[tableView dequeueReusableCellWithIdentifier:@"PoolTypeCell"];
    if(cell == nil){
        NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"PoolTypeCell" owner:self options:nil];
        cell = (PoolTypeCell *)[nib objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        [cell.typeLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    }
    cell.typeLabel.text=poolType.title.uppercaseString;
    cell.typeDescription.text=poolType.subtitle;
    if(poolType.image){
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:poolType.image]];
        __weak UIImageView *weakImageView = cell.typeImageView;
        weakImageView.image = nil;
        [cell.typeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PoolType *poolType=[self.poolTypes objectAtIndex:indexPath.row];
    
    UIImage *blurImage=[self.view darkBlurImage];
    PoolsTypeInfoViewController *poolsTypeInfoViewController=[[PoolsTypeInfoViewController alloc] initWithBackgroundImage:blurImage pool:poolType];
    poolsTypeInfoViewController.delegate=self;
    [self presentViewController:poolsTypeInfoViewController animated:YES completion:^{}];
}

-(void)poolsInfoViewController:(PoolsTypeInfoViewController *)poolsTypeInfoViewController didCreatePool:(Pool *)pool{
    
    AddFriendsViewController *addFriendsViewController = [[AddFriendsViewController alloc] init];
    addFriendsViewController.pool=pool;
    [self.navigationController pushViewController:addFriendsViewController animated:YES];
    
}

@end
