//
//  AddFriendsGamblinoViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 3/16/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "AddFriendsGamblinoViewController.h"
#import "Person.h"
#import "FriendCell.h"
#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
#define kLoadingCellTag 123456

@interface AddFriendsGamblinoViewController ()

@property(nonatomic,strong) NSMutableArray *contacts;
@property(nonatomic,strong) NSMutableArray *selectedContacts;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UILabel *inviteFriendsLabel;
@property(nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property(nonatomic,weak) IBOutlet UIView *placeholderView;
@property(nonatomic,strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic,strong) NSString *currentSearchedText;
@property (nonatomic,strong) NSString *nextPageURL;
@property (nonatomic,assign) int currentPage;


@end

@implementation AddFriendsGamblinoViewController

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
    [self.inviteFriendsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:30.0]];
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"searchBarBackground"]];
    self.contacts=[[NSMutableArray alloc] init];
    self.selectedContacts=[[NSMutableArray alloc] init];
    self.tableView.hidden=YES;
    self.placeholderView.hidden=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.currentPage=0;
    self.nextPageURL=@"";
    self.currentSearchedText=@"";
    [self loadFriends];
  
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
    if(self.searchBar.text.length==0){
        [self loadFriends];
    }
}

-(void)searchGamblinoUsers{
    int currentUserId=[[[NSUserDefaults standardUserDefaults] valueForKey:kUserId] intValue];
    NSString *encodedSearchString = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *remotePath=@"";
    if(![self.currentSearchedText isEqualToString:self.searchBar.text]){
        self.currentPage=0;
        self.nextPageURL=@"";
        self.contacts =[[NSMutableArray alloc] init];
    }
    
    if(self.currentPage==0){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        remotePath = [NSString stringWithFormat:@"users/search?query=%@",encodedSearchString];
    }
    else if(self.currentPage > 0){
        remotePath=self.nextPageURL;
    }

    
    [[NetworkManager sharedInstance] GET:remotePath withParameters:nil successBlock:^(NSDictionary *searchDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([searchDictionary.allKeys containsObject:@"pagination"]){
            NSDictionary *paginationValue=[searchDictionary valueForKey:@"pagination"];
            self.nextPageURL=[paginationValue objectForKey:@"next_page"];
            if(self.nextPageURL==0 || [self.nextPageURL isKindOfClass:[NSNull class]] || [self.nextPageURL isEqualToString:@""]||[self.nextPageURL  isEqualToString:NULL]||[self.nextPageURL isEqualToString:@"(null)"]||self.nextPageURL==nil || [self.nextPageURL isEqualToString:@"<null>"]){
                self.nextPageURL=@"";
                self.currentPage=0;
            }else{
                self.currentPage++;
            }
        }
        self.currentSearchedText=self.searchBar.text;
        
        if([searchDictionary.allKeys containsObject:@"users"]){
            NSArray *usersValue=[searchDictionary valueForKey:@"users"];
            NSMutableArray *personsArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in usersValue){
                User *user=[[User alloc] initWithDictionary:dic];
                Person *person=[[Person alloc] init];
                person.firstName=user.firstName;
                person.lastName=user.lastName;
                person.email=user.email;
                person.thumbnailURL=user.picture;
                person.gamblinoId=user.usersIdentifier;
                person.hometown=user.location;
                if(user.usersIdentifier!=currentUserId){
                    [personsArray addObject:person];
                }
            }
            
            if(self.currentPage==0){
                self.nextPageURL=@"";
                self.contacts=personsArray;
            }else{
                [self.contacts addObjectsFromArray:personsArray];
            }
            NSUInteger numberOfRows=[self.contacts count];
            if(numberOfRows==0){ 
                self.tableView.hidden=YES;
                self.placeholderView.hidden=NO;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gamblino"
                                                                message:@"No Result Found"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];

                
            }
            else{
                self.tableView.hidden=NO;
                self.placeholderView.hidden=YES;
            }
            [self reloadTableView:self.selectedContacts];
            //[self.tableView reloadData];
        }
    
    
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];

}

-(void)loadFriends{
    self.currentPage=0;
    self.nextPageURL=@"";
    self.currentSearchedText=@"";
    self.contacts =[[NSMutableArray alloc] init];
    int currentUserId=[[[NSUserDefaults standardUserDefaults] valueForKey:kUserId] intValue];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetworkManager sharedInstance] GET:@"friends"
                        withParameters:nil
                        successBlock:^(NSDictionary *searchDictionary){
                            
                            
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([searchDictionary.allKeys containsObject:@"users"]){
            NSArray *usersValue=[searchDictionary valueForKey:@"users"];
            NSMutableArray *personsArray=[[NSMutableArray alloc] init];
            for(NSDictionary *dic in usersValue){
                User *user=[[User alloc] initWithDictionary:dic];
                Person *person=[[Person alloc] init];
                person.firstName=user.firstName;
                person.lastName=user.lastName;
                person.email=user.email;
                person.thumbnailURL=user.picture;
                person.gamblinoId=user.usersIdentifier;
                person.hometown=user.location;
                if(user.usersIdentifier!=currentUserId){
                    [personsArray addObject:person];
                }
            }
            self.contacts=personsArray;
            NSUInteger numberOfRows=[self.contacts count];
            if(numberOfRows==0){
                self.tableView.hidden=YES;
                self.placeholderView.hidden=NO;
            }
            else{
                self.tableView.hidden=NO;
                self.placeholderView.hidden=YES;
            }
            //[self.tableView reloadData];
            [self reloadTableView:self.selectedContacts];
        }
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length]>0) {
    } else {
        [self.searchBar resignFirstResponder];
        [self loadFriends];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    if(self.searchBar.text.length>0){
        [self searchGamblinoUsers];
    }
    else{
        [self loadFriends];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self loadFriends];
}


-(IBAction)searchAction:(id)sender{
    [self.searchBar becomeFirstResponder];
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.nextPageURL.length>0 && self.currentPage>0){
        return [self.contacts count]+1;
    }else{
        return [self.contacts count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.nextPageURL.length>0 && self.currentPage>0){
        if([self.contacts count] == indexPath.row){
            return 44;
        }else{
            return 72;
        }
    }else{
        return 72;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.contacts count] > indexPath.row){
        Person *person=[self.contacts objectAtIndex:indexPath.row];
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
            cell = (FriendCell *)[nib objectAtIndex:1];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.nameLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            [cell.locationLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:15.0]];
            [cell.emailLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:15.0]];
            [cell.initialsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
            cell.emailLabel.hidden=YES;
        }
        cell.nameLabel.text=[NSString stringWithFormat:@"%@ %@",person.firstName?:@"",person.lastName?:@""];
        cell.locationLabel.text=person.hometown;
    //    cell.emailLabel.text=person.email;
        if(person.thumbnailURL&&person.thumbnailURL.length>0){
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
        [cell.selectedImageView setImage:[UIImage imageNamed:@"icon-unchecked"]];
        for(Person *ObjectCheck in self.selectedContacts){
            if(ObjectCheck.gamblinoId == person.gamblinoId){
                [cell.selectedImageView setImage:[UIImage imageNamed:@"icon-checked"]];
                break;
            }
        }
     return cell;
    }else if (self.contacts.count==indexPath.row && self.nextPageURL.length>0 && self.currentPage>0){
        return [self loadingCell];
    }else{
        return NULL;
    }
   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Person *person=[self.contacts objectAtIndex:indexPath.row];
    if([self.selectedContacts containsObject:person]){
        [self.selectedContacts removeObject:person];
        if(self.delegate){
            [self.delegate addFriendsGamblinoViewController:self didRemoveFriend:person];
        }
    }
    else{
        [self.selectedContacts addObject:person];
        if(self.delegate){
            [self.delegate addFriendsGamblinoViewController:self didAddFriend:person];
        }
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kLoadingCellTag) {
        if(self.nextPageURL.length>0 && self.currentPage>0){
            [self searchGamblinoUsers];
        }
    }
}

- (UITableViewCell *)loadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:nil];
    UIActivityIndicatorView *activityIndicator =
    [[UIActivityIndicatorView alloc]
     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.center;
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:activityIndicator];
    [activityIndicator startAnimating];
    cell.tag = kLoadingCellTag;
    
    return cell;
}

-(void)reloadTableView:(NSMutableArray*)selectedContacts{
    self.selectedContacts=selectedContacts;
    [self.tableView reloadData];
    

}


@end
