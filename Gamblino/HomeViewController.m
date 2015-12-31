//
//  HomeViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/11/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "MainMenuCell.h"
#import "LeaguesViewController.h"
#import "WelcomeViewController.h"
#import "MyWagersViewController.h"
#import "ContestMainViewController.h"
#import "MyProfileViewController.h"
#import "FeedViewController.h"
#import "AlertViewController.h"
#import "UIView+Blur.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PoolsViewController.h"
#import "MBProgressHUD.h"

@interface HomeViewController ()

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *titleLabel;
@property(nonatomic,weak) IBOutlet UIView *contentView;
@property(nonatomic,weak) IBOutlet UIView *childView;
@property(nonatomic,weak) IBOutlet UIButton *menuButton;
@property(nonatomic,weak) IBOutlet UIButton *backButton;
@property(nonatomic,weak) IBOutlet UIButton *alertButton;
@property(nonatomic,weak) IBOutlet UIButton *infoButton;
@property(nonatomic) BOOL isMenuOpen;
@property(nonatomic,strong) NSArray *unOpenedMenuItems;
@property(nonatomic,strong) NSString *selectedMenuItem;
@property(nonatomic,strong) NSArray *allMenuItems;
@property(nonatomic,strong) UIViewController *currentChildViewController;
@property(nonatomic,strong) AlertViewController *alertViewController;

@end

@implementation HomeViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidSucceed:) name:@"NotificationDidLoginSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidSucceed:) name:@"NotificationDidSignupSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationCount:) name:@"UpdateNotificationCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startBetting:) name:@"StartBetting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModalAndStartBetting:) name:@"DismissModalAndStartBetting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModalAndOpenPool:) name:@"DismissModalAndOpenPool" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissModalAndOpenFeed:) name:@"DismissModalAndOpenFeed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewProfile:) name:@"ViewProfile" object:nil];
    self.allMenuItems=@[kMenuItemHome,kMenuItemContests,kMenuItemGames,kMenuItemMyWagers,kMenuItemProfile,kMenuItemPools];
    
    self.navigationController.navigationBarHidden=YES;
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.menuButton.hidden=NO;
    self.backButton.hidden=YES;
    
    [self.alertButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:16.0]];
    
    //will need to clean all that up
    if([[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultsAccessTokenKey]){
        [self loginDidSucceed:nil];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)loginDidSucceed:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentLogin) name:@"Notification401Error" object:nil];
    self.selectedMenuItem=kMenuItemHome;
    self.unOpenedMenuItems=@[kMenuItemContests,kMenuItemGames,kMenuItemMyWagers,kMenuItemProfile,kMenuItemPools];
    [self refreshMenu];
    FeedViewController *feedViewController=[[FeedViewController alloc] init];
    feedViewController.title=kMenuItemHome;
    [self openViewController:feedViewController];
    self.alertButton.hidden=YES;
    self.infoButton.hidden=YES;
//    self.alertViewController=[[AlertViewController alloc] initWithBackgroundImage:nil];
}

- (void)updateNotificationCount:(NSNotification*)notification{
    NSNumber *notificationCount = notification.object;
    [self.alertButton setTitle:[NSString stringWithFormat:@"%d",notificationCount.intValue] forState:UIControlStateNormal];
}

- (void)startBetting:(NSNotification*)notification{
    [self openMenu:kMenuItemGames];
}

- (void)dismissModalAndStartBetting:(NSNotification*)notification{
    [self dismissViewControllerAnimated:YES completion:^{
        [self startBetting:nil];
    }];
}

- (void)dismissModalAndOpenPool:(NSNotification*)notification{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self openMenu:kMenuItemPools];
}

- (void)dismissModalAndOpenFeed:(NSNotification*)notification{
    UIViewController *vc = self.navigationController.presentedViewController;
    if([vc isKindOfClass:[UINavigationController class]] && [[[(UINavigationController*)vc viewControllers] objectAtIndex:0] isKindOfClass:[WelcomeViewController class]]) {
        return;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self openMenu:kMenuItemHome];
}

- (void)viewProfile:(NSNotification*)notification{
    [self openMenu:kMenuItemProfile];
}

- (IBAction)menuAction:(id)sender {
    if(self.isMenuOpen){
        [self closeMenu];
    }
    else{
        [self openMenu];
    }
}

- (IBAction)backAction:(id)sender{
    if([self.currentChildViewController isKindOfClass:[UINavigationController class]]){
        [(UINavigationController*)self.currentChildViewController popViewControllerAnimated:YES];
    }
}

- (IBAction)alertAction:(id)sender{
    /*
    if(self.alertViewController){
        UIImage *blurImage=[self.view lightBlurImage];
        self.alertViewController.blurImage=blurImage;
        [self presentViewController:self.alertViewController animated:YES completion:^{}];
    }
    */ 
}

- (IBAction)infoAction:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Sign Out" otherButtonTitles: nil];
    [actionSheet showInView:self.view];
}

- (void)openMenu {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect contentViewFrame=CGRectMake(0.0, kHeaderHeight+(self.unOpenedMenuItems.count)*kMenuLineHeight, kScreenWidth, self.view.bounds.size.height-kHeaderHeight-kFriendsSliderHeight);
        self.contentView.frame=contentViewFrame;
    }];
    self.isMenuOpen=YES;
}

- (void)closeMenu {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect contentViewFrame=CGRectMake(0.0, kHeaderHeight, kScreenWidth, self.view.bounds.size.height-kHeaderHeight);
        self.contentView.frame=contentViewFrame;
    }];
    self.isMenuOpen=NO;
}

- (void)refreshMenu {
    self.titleLabel.text=self.selectedMenuItem;
    [self.tableView reloadData];
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.unOpenedMenuItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *menuItem=[self.unOpenedMenuItems objectAtIndex:indexPath.row];
    MainMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"MainMenuCell" owner:self options:nil];
        cell = (MainMenuCell *)[nib objectAtIndex:0];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.menuItemLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    }
    cell.menuItemLabel.text=menuItem;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *menuItem=[self.unOpenedMenuItems objectAtIndex:indexPath.row];
    [self openMenu:menuItem];
}

-(void)openMenu:(NSString*)menuItem{
    [self closeMenu];
    if([menuItem isEqualToString:self.selectedMenuItem]){
        return;
    }
    NSMutableArray *updatedUnopenedMenuItems=[[NSMutableArray alloc] initWithArray:self.allMenuItems];
    [updatedUnopenedMenuItems removeObject:menuItem];
    self.unOpenedMenuItems=updatedUnopenedMenuItems;
    self.selectedMenuItem=menuItem;
    [self refreshMenu];
    
    if(self.currentChildViewController){
        [self.currentChildViewController willMoveToParentViewController:nil];
        [self.currentChildViewController.view removeFromSuperview];
        [self.currentChildViewController removeFromParentViewController];
    }
    if([self.selectedMenuItem isEqualToString:kMenuItemHome]){
        FeedViewController *feedViewController=[[FeedViewController alloc] init];
        feedViewController.title=kMenuItemHome;
        [self openViewController:feedViewController];
    }
    else if([self.selectedMenuItem isEqualToString:kMenuItemContests]){
        ContestMainViewController *contestMainViewController=[[ContestMainViewController alloc] init];
        contestMainViewController.title=kMenuItemContests;
        [self openViewController:contestMainViewController];
    }
    else if([self.selectedMenuItem isEqualToString:kMenuItemPools]){
        PoolsViewController *poolsViewController=[[PoolsViewController alloc] init];
        poolsViewController.title=kMenuItemPools;
        [self openViewController:poolsViewController];
    }
    else if([self.selectedMenuItem isEqualToString:kMenuItemGames]){
        LeaguesViewController *gamesViewController=[[LeaguesViewController alloc] init];
        gamesViewController.title=kMenuItemGames;
        [self openViewController:gamesViewController];
    }
    else if([self.selectedMenuItem isEqualToString:kMenuItemMyWagers]){
        MyWagersViewController *myWagersViewController=[[MyWagersViewController alloc] init];
        myWagersViewController.title=kMenuItemMyWagers;
        [self openViewController:myWagersViewController];
    }
    else if([self.selectedMenuItem isEqualToString:kMenuItemProfile]){
        MyProfileViewController *myProfileViewController=[[MyProfileViewController alloc] init];
        myProfileViewController.title=kMenuItemProfile;
        [self openViewController:myProfileViewController];
    }

    if([menuItem isEqualToString:kMenuItemProfile]){
        self.alertButton.hidden=YES;
        self.infoButton.hidden=NO;
    }
    else{
        self.alertButton.hidden=YES;
        self.infoButton.hidden=YES;
    }
}

-(void)openViewController:(UIViewController*)viewController{
    UINavigationController *navigationController=[[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBarHidden=YES;
    navigationController.delegate=self;
    [self addViewControllerToContentView:navigationController];
}


-(void)addViewControllerToContentView:(UIViewController *)viewController{
    [self addChildViewController:viewController];
    viewController.view.frame=CGRectMake(0,0,self.childView.bounds.size.width,self.childView.bounds.size.height);
    [self.childView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentChildViewController=viewController;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    self.titleLabel.text=viewController.title;
    if(navigationController.childViewControllers.count>1){
        self.menuButton.hidden=YES;
        self.backButton.hidden=NO;
    }
    else{
        self.menuButton.hidden=NO;
        self.backButton.hidden=YES;
    }
}

-(void)presentLogin{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Notification401Error" object:nil];

    [[FBSession activeSession] closeAndClearTokenInformation];
    self.alertViewController=nil;
    if(self.currentChildViewController){
        [self.currentChildViewController willMoveToParentViewController:nil];
        [self.currentChildViewController.view removeFromSuperview];
        [self.currentChildViewController removeFromParentViewController];
    }
    WelcomeViewController *welcomeViewController=[[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
    UINavigationController *loginNavigationViewController=[[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    [self dismissViewControllerAnimated:NO completion:^{
    }];
    [self presentViewController:loginNavigationViewController animated:NO completion:^{}];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsAccessTokenKey];
        [self presentLogin];
    }
}

@end
