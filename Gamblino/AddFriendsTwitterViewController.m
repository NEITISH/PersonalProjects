//
//  AddFriendsTwitterViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/29/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "AddFriendsTwitterViewController.h"

@interface AddFriendsTwitterViewController ()

@property(nonatomic,weak) IBOutlet UISearchBar *searchBar;

@end

@implementation AddFriendsTwitterViewController

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
    self.searchBar.barTintColor=[UIColor colorWithRed:232.0/255.0 green:225.0/255.0 blue:214.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
