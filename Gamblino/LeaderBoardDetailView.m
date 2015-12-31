//
//  LeaderBoardDetailView.m
//  Gamblino
//
//  Created by Prodio on 31/10/15.
//  Copyright © 2015 Gamblino. All rights reserved.
//

#import "LeaderBoardDetailView.h"
#import "LeaderBoardDetailCell.h"
#import "User.h"
#import "PointBalance.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MyProfileViewController.h"
#import "UIImage+ImageEffects.h"

@interface LeaderBoardDetailView ()

@end

@implementation LeaderBoardDetailView
@synthesize LeaderBoardArray,Creator;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        [self.username setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.userinitals setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.userpoints setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:12.0]];
    [self.userrank setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self UpdateUserData];
    self.Gamblinoimage.hidden = YES;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)UpdateUserData{

    User *currentUser =nil;
    int position =0;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.usesGroupingSeparator = YES;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    NSString *userPointstxt=@"";
    
        if([self.type isEqualToString:@"contest"]){
            currentUser = self.contest.me.user;
            position=[[Utils shortStringForInt:self.contest.me.place] intValue];
            userPointstxt = [NSString stringWithFormat:@"%@PTS",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.contest.me.points.balance]]];
            
            
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.headerImgSrc]];
            __weak UIImageView *weakImageView = self.ImageHeader;
            weakImageView.image = nil;
            [self.ImageHeader setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
            self.OverlayView.hidden = YES;
            self.usernameheader.hidden = YES;
            self.Userimage.hidden = YES;
            self.Leaderboardtext.hidden = NO;
            self.Poolname.hidden = YES;
            self.Playername.hidden =YES;
            [self.Leaderboardtext setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            self.Leaderboardtext.text=@"LEADERBOARD";

        }else{
            
            self.Leaderboardtext.hidden = NO;
            self.Poolname.hidden = NO;
            self.Playername.hidden =NO;
            self.usernameheader.hidden = NO;
            self.Userimage.hidden = NO;
        
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.pool.poolType.background_image]];
            __weak UIImageView *weakImageView = self.ImageHeader;
           weakImageView.image = nil;
            [self.ImageHeader setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
            
            currentUser = self.pool.me.user;
            Creator = self.pool.creator.picture;
            position=[[Utils shortStringForInt:self.pool.me.place] intValue];
            userPointstxt = [NSString stringWithFormat:@"%@PTS",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.pool.me.points.balance]]];
            [self.Leaderboardtext setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [self.Poolname setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [self.Playername setFont:[UIFont fontWithName:@"AvenirNextLTPro-Heavy" size:10.0]];
            self.Leaderboardtext.text=@"LEADERBOARD";
            self.Playername.text = [NSString stringWithFormat:@"%@ %@'S",self.pool.creator.firstName.uppercaseString,self.pool.creator.lastName.uppercaseString];
            self.Poolname.text = [NSString  stringWithFormat:@"%@",self.pool.poolType.title.uppercaseString];
            
            
            if(Creator && Creator.length>0){
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:Creator]];
                __weak UIImageView *weakImageView = self.Userimage;
                weakImageView.image = nil;
                [self.Userimage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                    [weakImageView setImage:image];
                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    NSLog(@"error=%@",[error description]);
                }];
            }
            else{
                [self.Userimage setBackgroundColor:[UIColor clearColor]];
                self.Userimage.layer.borderColor=[UIColor whiteColor].CGColor;
                self.Userimage.layer.borderWidth=4.0f;

                self.Userimage.backgroundColor=[UIColor clearColor];
                [self.usernameheader setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:48.0]];
                self.usernameheader.text=[NSString stringWithFormat:@"%@%@",[self.pool.creator.firstName.uppercaseString substringToIndex:1],[self.pool.creator.lastName.uppercaseString substringToIndex:1]];
                self.usernameheader.hidden=NO;
            }
            [self.Userimage.layer setCornerRadius:self.Userimage.bounds.size.width/2];
            [self.Userimage.layer setMasksToBounds:YES];
            
            NSLog(@"Shareable :: %@",self.pool.Shareable);
            if ([self.pool.Shareable isEqualToString:@"0"] || [self.pool.Shareable isKindOfClass:[NSNull class]] || self.pool.Shareable==nil) {
                self.shareIcon.hidden=YES;
            }
        }
    
        self.userrank.text = [NSString stringWithFormat:@"%d",position].uppercaseString;
        self.userpoints.text =userPointstxt;
        self.userinitals.hidden=YES;
        if(currentUser.picture && currentUser.picture.length>0){
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:currentUser.picture]];
            __weak UIImageView *weakImageView = self.userImage;
            weakImageView.image = nil;
            [self.userImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                [weakImageView setImage:image];
            }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"error=%@",[error description]);
            }];
        } else{
            self.userImage.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
            self.userinitals.text=[NSString stringWithFormat:@"%@%@",[currentUser.firstName.uppercaseString substringToIndex:1],[currentUser.lastName.uppercaseString substringToIndex:1]];
            self.userinitals.hidden=NO;
        }
        [self.userImage.layer setCornerRadius:self.userImage.bounds.size.width/2];
        [self.userImage.layer setMasksToBounds:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return [LeaderBoardArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"LeaderBoardDetailCell";
    LeaderBoardDetailCell *cell = (LeaderBoardDetailCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LeaderBoardDetailCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell.names setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [cell.nameinitials setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [cell.points setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:12.0]];
    [cell.ranks setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    
    User *user = [LeaderBoardArray objectAtIndex:indexPath.row];
    cell.names.text= user.firstName.uppercaseString;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.usesGroupingSeparator = YES;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    
    if(user.picture && user.picture.length>0){
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:user.picture]];
        __weak UIImageView *weakImageView = cell.players;
        weakImageView.image = nil;
        [cell.players setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    } else{
        cell.players.backgroundColor=[UIColor colorWithRed:142.0/255.0 green:44.0/255.0 blue:31.0/255.0 alpha:1.0];
        cell.nameinitials.text=[NSString stringWithFormat:@"%@%@",[user.firstName.uppercaseString substringToIndex:1],[user.lastName.uppercaseString substringToIndex:1]];
        cell.nameinitials.hidden=NO;
    }
    [cell.players.layer setCornerRadius:cell.players.bounds.size.width/2];
    [cell.players.layer setMasksToBounds:YES];
    
    cell.points.text = [NSString stringWithFormat:@"%@PTS",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:user.points.balance]]];
    int position=(int)[LeaderBoardArray indexOfObject:user];

    cell.ranks.text = [NSString stringWithFormat:@"%d",position+1].uppercaseString;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    User *user=[self.LeaderBoardArray objectAtIndex:indexPath.row];
    NSString *StrType=@"";
    int typeId=0;
    
    if([self.type isEqualToString:@"pool"]){
        StrType=@"pool";
        typeId=self.pool.poolIdentifier;
    }else{
        StrType=@"contest";
        typeId=self.contest.contestIdentifier;
    }
    
    MyProfileViewController *profileViewController = [[MyProfileViewController alloc] initWithNibName:@"ProfileViewController"
                                                                                               bundle:nil
                                                                                                 user:user
                                                                                              context:StrType
                                                                                                   id:typeId];
    [self.navigationController pushViewController:profileViewController animated:YES];

}

- (IBAction)Back:(id)sender{
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)Share:(id)sender{
    
    self.Gamblinoimage.hidden = NO;
    self.BackAction.hidden = YES;
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   // UIImageWriteToSavedPhotosAlbum(screenshotImage, nil, nil, nil);
    
    NSString *texttoshare;
    NSString *position = @"";

    if([self.type isEqualToString:@"pool"]){
        position=[Utils addSuffixToNumber:self.pool.me.place];
        texttoshare = [NSString stringWithFormat:@"I’m in %@ place in %@ pool on #Gamblino %@",position,self.pool.title.uppercaseString,self.pool.landingpage];
        
    }else if ([self.type isEqualToString:@"contest"]){
        position=[Utils addSuffixToNumber:self.contest.me.place];
        texttoshare = [NSString stringWithFormat:@"I’m in %@ place in the %@ contest on #Gamblino %@",position,self.contest.title.uppercaseString,self.contest.landingpage];
    }
    
        UIImage *imagetoshare = screenshotImage;
        NSArray *activityItems = @[texttoshare, imagetoshare];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
        [self presentViewController:activityVC animated:TRUE completion:nil];
    self.Gamblinoimage.hidden = YES;
    self.BackAction.hidden = NO;
    

    
}



@end
