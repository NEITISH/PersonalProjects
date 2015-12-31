//
//  LineMarkersViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 3/5/15.
//  Copyright (c) 2015 Gamblino. All rights reserved.
//

#import "LineMarkersViewController.h"

@interface LineMarkersViewController ()

@property (nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) NSString *urlString;
@property (nonatomic) NSString *title;

@end

@implementation LineMarkersViewController

- (id)initWithUrlString:(NSString*)urlString title:(NSString *)title {
    self = [super init];
    if(self){
        self.urlString = urlString;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    self.titleLabel.text = self.title;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc
{
    self.webView.delegate = nil;
}

@end
