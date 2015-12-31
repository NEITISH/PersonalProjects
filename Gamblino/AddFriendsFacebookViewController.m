//
//  AddFriendsFacebookViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/29/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "AddFriendsFacebookViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Person.h"
#import "FriendCell.h"
#import "UIImageView+AFNetworking.h"
#import "NetworkManager.h"
#import "MBProgressHUD.h"

@interface AddFriendsFacebookViewController ()

@property(nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property(nonatomic,weak) IBOutlet UILabel *inviteFriendsLabel;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIView *placeholderView;
@property(nonatomic,strong) NSArray *contacts;
@property(nonatomic,strong) NSArray *filteredContacts;
@property(nonatomic,strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation AddFriendsFacebookViewController

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
    [self.inviteFriendsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:30.0]];
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"searchBarBackground"]];
    self.contacts=[[NSArray alloc] init];
    self.selectedContacts=[[NSMutableArray alloc] init];
    self.tableView.hidden=YES;
    self.searchBar.hidden=YES;
    self.placeholderView.hidden=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.parentViewController.view addGestureRecognizer:self.tapRecognizer];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    if(self.tapRecognizer){
        [self.parentViewController.view removeGestureRecognizer:self.tapRecognizer];
    }
}

- (void)dismissKeyboard{
    [self.searchBar resignFirstResponder];
}

-(void)loadContacts{
    NSMutableArray *persons=[[NSMutableArray alloc] init];
    FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=first_name,last_name,picture,hometown"];
    [ friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *data = [result objectForKey:@"data"];
        for (FBGraphObject<FBGraphUser> *friend in data) {
            Person *person=[[Person alloc] init];
            person.firstName=[friend valueForKey:@"first_name"];
            person.lastName=[friend valueForKey:@"last_name"];
            person.facebookID=[friend valueForKey:@"id"];
            NSDictionary *hometownDictionary=[friend valueForKey:@"hometown"];
            if(hometownDictionary && [hometownDictionary valueForKey:@"name"]){
                person.hometown=[hometownDictionary valueForKey:@"name"];
            }
            NSDictionary *pictureDictionary=[friend valueForKey:@"picture"];
            if(pictureDictionary && [pictureDictionary valueForKey:@"data"]){
                NSDictionary *pictureDataDictionary=[pictureDictionary valueForKey:@"data"];
                NSNumber *isSilhouette=[pictureDataDictionary valueForKey:@"is_silhouette"];
                if(!isSilhouette.boolValue){
                    person.thumbnailURL=[pictureDataDictionary valueForKey:@"url"];
                }
            }
            [persons addObject:person];
        }
        self.contacts=persons;
        self.filteredContacts=self.contacts;
        NSUInteger numberOfRows=[self.contacts count];
        if(numberOfRows==0){
            self.tableView.hidden=YES;
            self.searchBar.hidden=YES;
            self.placeholderView.hidden=NO;
        }
        else{
            self.tableView.hidden=NO;
            self.searchBar.hidden=NO;
            self.placeholderView.hidden=YES;
        }
        [self.tableView reloadData];
    }];
}

-(IBAction)loadContactsAction:(id)sender{
    if (![FBSession activeSession] || ![[FBSession activeSession] isOpen] ) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NetworkManager sharedInstance] performFacebookOnlyAuthenticationWithSuccessBlock:^(NSString *username, NSString *authenticationToken) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self loadContacts];
        } failureBlock:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
    else {
        [self loadContacts];
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length==0){
        self.filteredContacts=self.contacts;
    }
    else{
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(firstName BEGINSWITH[cd] %@)OR(lastName BEGINSWITH[cd] %@)", searchText,searchText]];
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredContacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Person *person=[self.filteredContacts objectAtIndex:indexPath.row];
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
        cell = (FriendCell *)[nib objectAtIndex:0];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.nameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
        [cell.locationLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:15.0]];
        [cell.emailLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:15.0]];
        [cell.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    }
    cell.nameLabel.text=[NSString stringWithFormat:@"%@ %@",person.firstName?:@"",person.lastName?:@""];
    cell.locationLabel.text=person.hometown;
    cell.emailLabel.text=person.email;
    if(person.thumbnailURL){
        cell.initialsLabel.hidden=YES;
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:person.thumbnailURL]];
        __weak UIImageView *weakImageView = cell.avatarImageView;
        weakImageView.image = nil;
        [cell.avatarImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    else{
        [cell.avatarImageView setImage:nil];
        cell.initialsLabel.hidden=NO;
        cell.initialsLabel.text=@"";
        if(person.firstName && person.lastName && person.firstName.length>0 &&person.lastName.length>0){
            cell.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[person.firstName substringToIndex:1],[person.lastName substringToIndex:1]];
        }
    }
    [cell.avatarImageView.layer setCornerRadius:cell.avatarImageView.bounds.size.width/2];
    [cell.avatarImageView.layer setMasksToBounds:YES];
    if([self.selectedContacts containsObject:person]){
        [cell.selectedImageView setImage:[UIImage imageNamed:@"icon-checked"]];
    }
    else{
        [cell.selectedImageView setImage:[UIImage imageNamed:@"icon-unchecked"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Person *person=[self.filteredContacts objectAtIndex:indexPath.row];
    if([self.selectedContacts containsObject:person]){
        [self.selectedContacts removeObject:person];
        if(self.delegate){
            [self.delegate addFriendsFacebookViewController:self didRemoveFriend:person];
        }
    }
    else{
        [self.selectedContacts addObject:person];
        if(self.delegate){
            [self.delegate addFriendsFacebookViewController:self didAddFriend:person];
        }
    }
    [self.tableView reloadData];
}


@end
