//
//  AddFriendsContactsViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/29/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "AddFriendsContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import "FriendCell.h"
#import "Person.h"

@interface AddFriendsContactsViewController ()

@property(nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property(nonatomic,weak) IBOutlet UILabel *inviteFriendsLabel;
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIView *placeholderView;
@property(nonatomic) ABAddressBookRef addressBook;
@property(nonatomic,strong) NSArray *contacts;
@property(nonatomic,strong) NSArray *filteredContacts;
@property(nonatomic,strong) UITapGestureRecognizer *tapRecognizer;

-(IBAction)loadContactsAction:(id)sender;

@end

@implementation AddFriendsContactsViewController

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
    ABRecordRef source = ABAddressBookCopyDefaultSource(self.addressBook);
    NSArray *tempArray=(__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(self.addressBook, source, kABPersonSortByLastName));
    NSMutableArray *persons=[[NSMutableArray alloc] init];
    for(id contact in tempArray){
        Person *person=[[Person alloc] init];
        person.firstName = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)(contact), kABPersonFirstNameProperty);
        person.lastName = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)(contact), kABPersonLastNameProperty);
        
        ABMultiValueRef addressProperty = ABRecordCopyValue((__bridge ABRecordRef)(contact), kABPersonAddressProperty);
        NSArray *address = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(addressProperty);
        for (NSDictionary *addressDictionary in address)
        {
            NSMutableString *locationString=[[NSMutableString alloc] init];
            NSString *city=[addressDictionary valueForKey:(NSString*)kABPersonAddressCityKey];
            NSString *state=[addressDictionary valueForKey:(NSString*)kABPersonAddressStateKey];
            if(city){
                [locationString appendString:city];
            }
            if(locationString.length>0 && state){
                [locationString appendString:@", "];
                [locationString appendString:state];
            }
            person.hometown=locationString;
        }
        CFRelease(addressProperty);
        
        ABMultiValueRef emailMultiValue = ABRecordCopyValue((__bridge ABRecordRef)(contact), kABPersonEmailProperty);
        NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
        if(emailAddresses){
            person.email=[emailAddresses firstObject];
        }
        CFRelease(emailMultiValue);
        
        person.avatarImage=[UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageDataWithFormat((__bridge ABRecordRef)(contact), kABPersonImageFormatThumbnail)];
        
        if(person.email){
            [persons addObject:person];
        }
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
}

-(IBAction)loadContactsAction:(id)sender{
    self.addressBook=ABAddressBookCreateWithOptions(NULL,nil);
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadContacts];
            });
        }
    });
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
    [cell.avatarImageView setImage:person.avatarImage];
    if(person.avatarImage){
        cell.initialsLabel.hidden=YES;
    }
    else{
        cell.initialsLabel.hidden=NO;
        cell.initialsLabel.text=@"";
        if(person.firstName && person.lastName && person.firstName.length>0 &&person.lastName.length>0){
            cell.initialsLabel.text=[NSString stringWithFormat:@"%@%@",[person.firstName substringToIndex:1].uppercaseString,[person.lastName substringToIndex:1].uppercaseString];
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
            [self.delegate addFriendsContactsViewController:self didRemoveFriend:person];
        }
    }
    else{
        [self.selectedContacts addObject:person];
        if(self.delegate){
            [self.delegate addFriendsContactsViewController:self didAddFriend:person];
        }
    }
    [self.tableView reloadData];
}

@end
