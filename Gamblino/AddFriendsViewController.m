//
//  AddFriendsViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/26/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "Person.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "PoolDetailsViewController.h"
#import "SelectPoolTypeViewController.h"
#import <Social/Social.h>


#define SHARE_ACTION_SHEET 1

@interface AddFriendsViewController ()

@property(nonatomic,weak) IBOutlet UILabel *titleLabel;
@property(nonatomic,weak) IBOutlet UILabel *PoolLink;
@property(nonatomic,weak) IBOutlet UILabel *ShareingMessage;


@property(nonatomic,weak) IBOutlet UIButton *skipInviteButton;
@property(nonatomic,weak) IBOutlet UIButton *skipButton2;

@property(nonatomic,weak) IBOutlet UIButton *messageBtn;
@property(nonatomic,weak) IBOutlet UIButton *shareBtn;

@property(nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic,weak) IBOutlet UIView *friendsListView;
@property(nonatomic,weak) IBOutlet UIView *contentView;
@property(nonatomic,weak) IBOutlet UIView *bottomcontentView;
@property(nonatomic,weak) IBOutlet UIView *topcontentView;
@property(nonatomic,weak) IBOutlet UIView *topheaderDivider;


@property (strong, nonatomic) UIImage *PoolTypeImage;


@property(nonatomic,weak) IBOutlet UIScrollView *selectedContactsScrollView;
@property(nonatomic,strong)  UIViewController *currentChildViewController;
@property(nonatomic,strong) AddFriendsContactsViewController *addFriendsContactsViewController;
@property(nonatomic,strong) AddFriendsFacebookViewController *addFriendsFacebookViewController;
@property(nonatomic,strong) AddFriendsGamblinoViewController *addFriendsGamblinoViewController;
@property(nonatomic,strong) NSArray *unifiedSelectedContacts;

-(IBAction)segmentedControlDidValueChange:(id)sender;
-(IBAction)skipInviteAction:(id)sender;
-(IBAction)ShareOrMessageAction:(id)sender;


@end

@implementation AddFriendsViewController
@synthesize PoolTypeImage;


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
    self.unifiedSelectedContacts=[[NSArray alloc] init];
    [self.skipInviteButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.skipButton2.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:
                                [UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0]
                                                           forKey:UITextAttributeFont];
    
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.addFriendsContactsViewController=[[AddFriendsContactsViewController alloc] init];
    self.addFriendsContactsViewController.delegate=self;
    self.addFriendsFacebookViewController=[[AddFriendsFacebookViewController alloc] init];
    self.addFriendsFacebookViewController.delegate=self;
    self.addFriendsGamblinoViewController=[[AddFriendsGamblinoViewController alloc] init];
    self.addFriendsGamblinoViewController.delegate=self;
    [self addViewControllerToContentView:self.addFriendsGamblinoViewController];
    self.segmentedControl.selectedSegmentIndex=0;
    
    
    [[self.PoolLink layer] setBorderColor:[[UIColor colorWithRed:0.79 green:0.76 blue:0.69 alpha:1.0] CGColor]];
    [[self.PoolLink layer] setBorderWidth:0.5];
    [[self.PoolLink layer] setCornerRadius:5];
    self.PoolLink.text=[NSString stringWithFormat:@"        %@",self.pool.landingpage];
    self.PoolLink.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyGamblinoURL)];
    [self.PoolLink addGestureRecognizer:tapGesture];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect contentViewFrame=CGRectMake(0.0, kHeaderHeight+kFriendsSliderHeight, kScreenWidth,
                                           self.view.bounds.size.height-64.0-79.0);
        self.contentView.frame=contentViewFrame;
    }];
    
    self.skipInviteButton.hidden=NO;
    [self LoadPoolTypeImage];
    
    
}
-(void)LoadPoolTypeImage{

    NSURL *request= [[NSURL alloc] initWithString:self.pool.poolType.image];
    [self downloadImageWithURL:request completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            PoolTypeImage=image;
           }
    }];

}

-(void)copyGamblinoURL{

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.URL = [NSURL URLWithString:self.pool.landingpage];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Link Copied to Clipboard..";
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:3];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)segmentedControlDidValueChange:(id)sender{
    if(!self.currentChildViewController){
        return;
    }
    [self.currentChildViewController willMoveToParentViewController:nil];
    [self.currentChildViewController.view removeFromSuperview];
    [self.currentChildViewController removeFromParentViewController];
    
    if(self.segmentedControl.selectedSegmentIndex==0){
        [self addViewControllerToContentView:self.addFriendsGamblinoViewController];
    }
    if(self.segmentedControl.selectedSegmentIndex==1){
        [self addViewControllerToContentView:self.addFriendsContactsViewController];
    }
    else if(self.segmentedControl.selectedSegmentIndex==2){
        [self addViewControllerToContentView:self.addFriendsFacebookViewController];
    }
}

-(IBAction)skipInviteAction:(id)sender{
    if(self.unifiedSelectedContacts && self.unifiedSelectedContacts.count){
        NSMutableArray *facebookPersonIDs=[[NSMutableArray alloc] init];
        NSMutableArray *invitees=[[NSMutableArray alloc] init];
        
        for(Person *person in self.unifiedSelectedContacts){
            if(person.facebookID){
                [facebookPersonIDs addObject:person.facebookID];
                NSDictionary *inviteeDictionary=@{@"first_name":person.firstName?person.firstName:@"",@"last_name":person.lastName?person.lastName:@"",@"tracking_context":@"facebook",@"tracking_id":person.facebookID,@"context":@"Pool",@"context_id":@(self.pool.poolIdentifier)};
                [invitees addObject:inviteeDictionary];
            }
            else if(person.gamblinoId){
                NSDictionary *inviteeDictionary=@{@"tracking_context":@"user",@"tracking_id":@(person.gamblinoId),@"context":@"Pool",@"context_id":@(self.pool.poolIdentifier)};
                [invitees addObject:inviteeDictionary];
            }
            else{
                NSDictionary *inviteeDictionary=@{@"first_name":person.firstName?person.firstName:@"",@"last_name":person.lastName?person.lastName:@"",@"tracking_context":@"email",@"tracking_id":person.email?person.email:@"",@"context":@"Pool",@"context_id":@(self.pool.poolIdentifier)};
                [invitees addObject:inviteeDictionary];
            }
        }
        if(facebookPersonIDs.count>0){
            NSString *facebookIDsString=[facebookPersonIDs componentsJoinedByString:@","];
            NSDictionary *params=@{@"to":facebookIDsString};
            [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"Gamblino is bringing the thrill of sports betting to fans across the US. Live odds & scores and free contests with great prizes. Make every game matter." title:@"Join me on Gamblino!" parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                 if (error) {
                     NSLog(@"Error sending request.");
                 }
                 else {
                     if (result == FBWebDialogResultDialogNotCompleted) {
                         NSLog(@"User canceled request.");
                     }
                     else {
//                         [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
                     }
                 }
             }];
        }
        if(invitees.count>0){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSDictionary *inviteeDictionary=@{@"invitees":invitees};
            
            [[NetworkManager sharedInstance] POST:@"invites" withParameters:inviteeDictionary successBlock:^(NSDictionary *rootDictionary) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self closeThisView];
            } failureBlock:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        }else{
            [self closeThisView];
        }
    }
    else{
        [self closeThisView];
    }
}

-(IBAction)ShareOrMessageAction:(id)sender{

    NSString *StrToShare=[NSString stringWithFormat:@"Join my %@ pool on Gamblino: %@",
                          self.pool.poolType.title,self.pool.landingpage];
    
    UIButton *senderBtn=(UIButton *)sender;
    if(senderBtn==self.messageBtn){
        if([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.body = StrToShare;
            controller.recipients = [NSArray arrayWithObjects:nil];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
    if(senderBtn==self.shareBtn){
        //http://www.albertopasca.it/whiletrue/2012/10/objective-c-custom-uiactivityviewcontroller-icons-text/
       UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter",nil];
        actionSheet.tag=SHARE_ACTION_SHEET;
        [actionSheet showInView:self.view];
    
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    switch(result) {
        case MessageComposeResultCancelled:
            // user canceled sms
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MessageComposeResultSent:
            // user sent sms
            //perhaps put an alert here and dismiss the view on one of the alerts buttons
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MessageComposeResultFailed:
            // sms send failed
            //perhaps put an alert here and dismiss the view when the alert is canceled
            break;
        default:
            break;
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
   if(actionSheet.tag==SHARE_ACTION_SHEET){
       
       NSString *StrToShare=[NSString stringWithFormat:@"Join my %@ pool on #Gamblino",
                             self.pool.poolType.title];
       
       if(buttonIndex==0){
       
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
               
               SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                StrToShare=[NSString stringWithFormat:@"%@ %@",StrToShare,self.pool.landingpage];
               [controller setInitialText:StrToShare];
               [controller addURL:[NSURL URLWithString:self.pool.landingpage]];
               //[controller addImage:PoolTypeImage];
               
               [self presentViewController:controller animated:YES completion:Nil];
               
           }else{
           //If Not available
           
           }
          
       }
       if(buttonIndex==1){
       
           if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
               SLComposeViewController *tweetSheet = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
               StrToShare=[NSString stringWithFormat:@"%@ %@",StrToShare,self.pool.landingpage];
               [tweetSheet setInitialText:StrToShare];
               [tweetSheet addImage:PoolTypeImage];
               [self presentViewController:tweetSheet animated:YES completion:nil];
           }else{
            //If Not available
               
           }
       }
       
       
    }
}

-(IBAction)skipAction:(id)sender{
    [self closeThisView];
}

-(void)closeThisView{
    if(self.navigationController && self.navigationController.viewControllers.count>0 && [[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2] isKindOfClass:[PoolDetailsViewController class]]){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(self.navigationController && self.navigationController.viewControllers.count>0 && [[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-1] isKindOfClass:[SelectPoolTypeViewController class]]){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(self.navigationController && self.navigationController.viewControllers.count>0 && [[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2] isKindOfClass:[SelectPoolTypeViewController class]]){
        
        //UIImage *blurImage=[self.navigationController.parentViewController. darkBlurImage];
        UIImage *blurImage=[UIImage imageNamed:@"defaultBlur.png"];
        PoolDetailsViewController *poolDetailsViewController = [[PoolDetailsViewController alloc] initWithBackgroundImage:blurImage pool:self.pool];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:poolDetailsViewController animated:YES];
        });
    }
    else{
        [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    }
}

-(void)addViewControllerToContentView:(UIViewController *)viewController{
    [self addChildViewController:viewController];
    viewController.view.frame=CGRectMake(0,0,self.friendsListView.bounds.size.width,self.friendsListView.bounds.size.height);
    [self.friendsListView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentChildViewController=viewController;
}

-(void)addFriendsFacebookViewController:(AddFriendsFacebookViewController *)addFriendsFacebookViewController didAddFriend:(Person *)person{
    NSMutableArray *unifiedSelectedContacts=[[NSMutableArray alloc] initWithArray:self.unifiedSelectedContacts];
    [unifiedSelectedContacts addObject:person];
    self.unifiedSelectedContacts=unifiedSelectedContacts;
    [self refreshSelectedThumbnailsView];
}

-(void)addFriendsFacebookViewController:(AddFriendsFacebookViewController *)addFriendsFacebookViewController didRemoveFriend:(Person *)person{
    NSMutableArray *unifiedSelectedContacts=[[NSMutableArray alloc] initWithArray:self.unifiedSelectedContacts];
    if([unifiedSelectedContacts containsObject:person]){
        [unifiedSelectedContacts removeObject:person];
    }
    self.unifiedSelectedContacts=unifiedSelectedContacts;
    [self refreshSelectedThumbnailsView];
}

-(void)addFriendsContactsViewController:(AddFriendsContactsViewController *)addFriendsContactsViewController didAddFriend:(Person *)person{
    NSMutableArray *unifiedSelectedContacts=[[NSMutableArray alloc] initWithArray:self.unifiedSelectedContacts];
    [unifiedSelectedContacts addObject:person];
    self.unifiedSelectedContacts=unifiedSelectedContacts;
    [self refreshSelectedThumbnailsView];
}

-(void)addFriendsContactsViewController:(AddFriendsContactsViewController *)addFriendsContactsViewController didRemoveFriend:(Person *)person{
    NSMutableArray *unifiedSelectedContacts=[[NSMutableArray alloc] initWithArray:self.unifiedSelectedContacts];
    if([unifiedSelectedContacts containsObject:person]){
        [unifiedSelectedContacts removeObject:person];
    }
    self.unifiedSelectedContacts=unifiedSelectedContacts;
    [self refreshSelectedThumbnailsView];
}

-(void)addFriendsGamblinoViewController:(AddFriendsGamblinoViewController *)addFriendsGamblinoViewController didAddFriend:(Person *)person{
    NSMutableArray *unifiedSelectedContacts=[[NSMutableArray alloc] initWithArray:self.unifiedSelectedContacts];
    [unifiedSelectedContacts addObject:person];
    self.unifiedSelectedContacts=unifiedSelectedContacts;
    [self refreshSelectedThumbnailsView];
}

-(void)addFriendsGamblinoViewController:(AddFriendsGamblinoViewController *)addFriendsGamblinoViewController didRemoveFriend:(Person *)person{
    NSMutableArray *unifiedSelectedContacts=[[NSMutableArray alloc] initWithArray:self.unifiedSelectedContacts];
    if([unifiedSelectedContacts containsObject:person]){
        [unifiedSelectedContacts removeObject:person];
    }
    self.unifiedSelectedContacts=unifiedSelectedContacts;
    [self refreshSelectedThumbnailsView];
}

-(void)refreshSelectedThumbnailsView{
    //first we remove everything in the scrollview
    for(UIView *subview in self.selectedContactsScrollView.subviews){
        [subview removeFromSuperview];
    }
    //then we iterate through selected contacts
    int contactIndex=0;
    for(Person *person in self.unifiedSelectedContacts){
        UIView *AddFriendView =[[UIView alloc] initWithFrame:CGRectMake(contactIndex*64.0, 0.0, 48.0, 48.0)];
        
        UIImageView *thumbnailImageView=[[UIImageView alloc]initWithFrame:CGRectMake(15.0, 16.0, 48.0, 48.0)];
        [thumbnailImageView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.25]];
        thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        [thumbnailImageView.layer setCornerRadius:thumbnailImageView.bounds.size.width/2];
        [thumbnailImageView.layer setMasksToBounds:YES];
        thumbnailImageView.userInteractionEnabled=YES;
        thumbnailImageView.tag=contactIndex;
        
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
        //swipeGesture.delegate=self;
        [AddFriendView addGestureRecognizer:swipeGesture];
        
        
        //[self.selectedContactsScrollView addSubview:thumbnailImageView];
        [AddFriendView addSubview:thumbnailImageView];
        if(person.avatarImage){
            [thumbnailImageView setImage:person.avatarImage];
        }
        else if(person.thumbnailURL&&person.thumbnailURL.length>0){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:person.thumbnailURL]];
            __weak UIImageView *weakImageView = thumbnailImageView;
            weakImageView.image = nil;
            [thumbnailImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        
        }
        else{
            UILabel *initialsLabel=[[UILabel alloc] initWithFrame:thumbnailImageView.frame];
            [initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [initialsLabel setTextAlignment:NSTextAlignmentCenter];
            [initialsLabel setTextColor:[UIColor whiteColor]];
            if(person.firstName && person.lastName && person.firstName.length>0 &&person.lastName.length>0){
                initialsLabel.text=[NSString stringWithFormat:@"%@%@",[person.firstName substringToIndex:1],[person.lastName substringToIndex:1]];
            }
            [AddFriendView addSubview:initialsLabel];
            //[self.selectedContactsScrollView addSubview:initialsLabel];
        }
        [self.selectedContactsScrollView addSubview:AddFriendView];
        contactIndex++;
    }
    //We resize the scrollview and scroll to right
    [self.selectedContactsScrollView setContentSize:CGSizeMake(30.0+self.unifiedSelectedContacts.count*64.0, self.selectedContactsScrollView.bounds.size.height)];
    CGPoint rightOffset = CGPointMake(self.selectedContactsScrollView.contentSize.width - self.selectedContactsScrollView.bounds.size.width, 0);
    if(self.selectedContactsScrollView.contentSize.width>self.selectedContactsScrollView.bounds.size.width){
        [self.selectedContactsScrollView setContentOffset:rightOffset animated:YES];
    }
    //we slide up or down if necessary
    if(self.unifiedSelectedContacts.count==0){
        self.topheaderDivider.hidden=YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.topcontentView.hidden=NO;
            /*
            CGRect contentViewFrame=CGRectMake(0.0, kHeaderHeight, kScreenWidth, self.view.bounds.size.height-64.0);
            self.contentView.frame=contentViewFrame;
            */
            
        }];
    }
    else{
        self.topheaderDivider.hidden=NO;
        self.skipInviteButton.hidden=NO;
        [self.skipInviteButton setTitle:@"DONE" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            self.topcontentView.hidden=YES;
            CGRect contentViewFrame=CGRectMake(0.0, kHeaderHeight+kFriendsSliderHeight, kScreenWidth, self.view.bounds.size.height-64.0-79.0);
            self.contentView.frame=contentViewFrame;
            
        }];
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}
/*
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint velocity = [panGestureRecognizer velocityInView:self.selectedContactsScrollView];
    return fabs(velocity.y) > fabs(velocity.x);
}
 */

-(void)handleSwipeGesture:(UISwipeGestureRecognizer *) sender
{
    //Gesture detect - swipe up/down , can be recognized direction
    if(sender.direction == UISwipeGestureRecognizerDirectionUp){
   
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionDown){
    
        int index = (int)[sender locationInView:self.selectedContactsScrollView].x/64.0;
        
        if(self.unifiedSelectedContacts.count>index){
            
            UIView *imageView = sender.view;
            CGFloat targetX = CGRectGetMinX(imageView.frame);
            CGFloat targetY = CGRectGetMinY(imageView.frame);
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 imageView.frame = CGRectMake(targetX, targetY+64.0,CGRectGetWidth(imageView.frame),
                                                              CGRectGetHeight(imageView.frame));
                             }
                             completion:^(BOOL finished){
                                 Person *person =[self.unifiedSelectedContacts objectAtIndex:index];
                                 [self addFriendsGamblinoViewController:self.addFriendsGamblinoViewController didRemoveFriend:person];
                                 NSMutableArray *UpdatedunifiedSelectedContacts=[self.unifiedSelectedContacts mutableCopy];
                                 [self.addFriendsGamblinoViewController reloadTableView:UpdatedunifiedSelectedContacts];
                                 
                             }];
            
            
          
        }
    }
}

- (void)DragAndRemove:(UIPanGestureRecognizer *)recognizer{
    
    typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
        UIPanGestureRecognizerDirectionUndefined,
        UIPanGestureRecognizerDirectionUp,
        UIPanGestureRecognizerDirectionDown,
        UIPanGestureRecognizerDirectionLeft,
        UIPanGestureRecognizerDirectionRight
    };
    
    static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
    
    UIView *imageView = recognizer.view;
    UIView *container = imageView.superview;
    CGFloat targetX = CGRectGetMinX(imageView.frame);
    CGFloat targetY = CGRectGetMinY(imageView.frame);
    
    UIGestureRecognizerState state = [recognizer state];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        [recognizer.view setTransform:CGAffineTransformTranslate(recognizer.view.transform, translation.x, translation.y)];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
        
        
        if (direction == UIPanGestureRecognizerDirectionUndefined) {
            
            CGPoint velocity = [recognizer velocityInView:self.selectedContactsScrollView];
            
            BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
            
            if (isVerticalGesture) {
                if (velocity.y > 0) {
                    direction = UIPanGestureRecognizerDirectionDown;
                } else {
                    direction = UIPanGestureRecognizerDirectionUp;
                }
            }
        }
        
    }
    else if(state==UIGestureRecognizerStateEnded){
      
        if(targetX>0){
            targetX = targetX;
        }else if(CGRectGetMaxX(imageView.frame)<CGRectGetWidth(container.bounds)){
            targetX = CGRectGetWidth(container.bounds)-CGRectGetWidth(imageView.frame);
        
        }
        if(targetY>0){
            targetY = targetY;
        }else if(CGRectGetMaxY(imageView.frame)<CGRectGetHeight(container.bounds)){
            targetY = CGRectGetHeight(container.bounds)-CGRectGetHeight(imageView.frame);
       
        }
        
        if(direction==UIPanGestureRecognizerDirectionDown){
            [self handleDownwardsGesture:recognizer];
            direction = UIPanGestureRecognizerDirectionUndefined;
            /*
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame = CGRectMake(targetX, targetY,CGRectGetWidth(imageView.frame),
                                             CGRectGetHeight(imageView.frame));
            }];
            */
        }else{
        }
      
    }

}

- (void)handleUpwardsGesture:(UIPanGestureRecognizer *)sender{
    NSLog(@"Up");
}

- (void)handleDownwardsGesture:(UIPanGestureRecognizer *)sender{
    int index = (int)[sender locationInView:self.selectedContactsScrollView].x/64.0;
    if(self.unifiedSelectedContacts.count>index){
        Person *person =[self.unifiedSelectedContacts objectAtIndex:index];
        [self addFriendsGamblinoViewController:self.addFriendsGamblinoViewController didRemoveFriend:person];
        NSMutableArray *UpdatedunifiedSelectedContacts=[self.unifiedSelectedContacts mutableCopy];
        [self.addFriendsGamblinoViewController reloadTableView:UpdatedunifiedSelectedContacts];
    }
}

- (void)handleLeftGesture:(UIPanGestureRecognizer *)sender{
    NSLog(@"Left");
}

- (void)handleRightGesture:(UIPanGestureRecognizer *)sender{
    NSLog(@"Right");
}

-(void)RemoveFriendAndReload:(UIPanGestureRecognizer *)sender{

}


#pragma mark - Dealloc

- (void)dealloc {
    self.selectedContactsScrollView.delegate = nil;
}

@end
