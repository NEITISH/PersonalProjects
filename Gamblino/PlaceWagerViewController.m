//
//  PlaceWagerViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/26/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "PlaceWagerViewController.h"
#import "GradientView.h"
#import "Team.h"
#import "UIColor+Gamblino.h"
#import "ContestListViewController.h"
#import "PoolsListViewController.h"
#import "Constants.h"

@interface PlaceWagerViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet GradientView *gradientViewTop;
@property (nonatomic,weak) IBOutlet GradientView *gradientViewBottom;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) Line *line;
@property (nonatomic,strong) Event *game;
@property (nonatomic,strong) Answer *answer;
@property (nonatomic,strong) UIViewController *currentChildViewController;
@property (nonatomic,strong) ContestListViewController *contestListViewController;
@property (nonatomic,strong) PoolsListViewController *poolsListViewController;

@end

@implementation PlaceWagerViewController

- (id)initWithBackgroundImage:(UIImage*)image line:(Line*)line game:(Event*)game answer:(Answer*)answer{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.line=line;
        self.game=game;
        self.answer=answer;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self.game.contextType isEqualToString:@"CustomEvent"]){
        self.gradientViewBottom.hidden=YES;
        self.gradientViewTop.hidden=YES;
    }
    else{
        UIColor *awayTeamColor=[UIColor colorWithHexString:self.game.awayTeam.color];
        UIColor *homeTeamColor=[UIColor colorWithHexString:self.game.homeTeam.color];
        self.gradientViewTop.leftColor=[awayTeamColor colorByChangingAlphaTo:0.2];
        self.gradientViewTop.rightColor=[homeTeamColor colorByChangingAlphaTo:0.2];
        self.gradientViewBottom.leftColor=[awayTeamColor colorByChangingAlphaTo:0.5];
        self.gradientViewBottom.rightColor=[homeTeamColor colorByChangingAlphaTo:0.5];
    }
    [self.backgroundImageView setImage:self.blurImage];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    if(self.line){
        self.titleLabel.text=[self titleForLine:self.line];
    }
    else if(self.answer){
        self.titleLabel.text=[NSString stringWithFormat:@"%@ %+g",self.answer.title.uppercaseString,self.answer.value];
    }
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:14.0] forKey:UITextAttributeFont];
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.contestListViewController=[[ContestListViewController alloc] initWithBackgroundImage:self.blurImage line:self.line game:self.game answer:self.answer];
    self.poolsListViewController=[[PoolsListViewController alloc] initWithBackgroundImage:self.blurImage line:self.line game:self.game answer:self.answer];
    [self addViewControllerToContentView:self.contestListViewController];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(NSString*)titleForLine:(Line*)line{
    NSString *lineValueString=@"";
    NSString *linePrefixString=@"";
    if([line.type isEqualToString:kUnderType]){
        lineValueString=[NSString stringWithFormat:@"%g",self.line.line];
        linePrefixString=@"U";
    }
    else if([line.type isEqualToString:kOverType]){
        lineValueString=[NSString stringWithFormat:@"%g",self.line.line];
        linePrefixString=@"O";
    }
    else{
        lineValueString=[NSString stringWithFormat:@"%+g",self.line.line];
        if(line.teamId==self.game.awayTeam.teamIdentifier){
            linePrefixString=self.game.awayTeam.shortName;
        }
        else if(line.teamId==self.game.homeTeam.teamIdentifier){
            linePrefixString=self.game.homeTeam.shortName;
        }
    }
    return [NSString stringWithFormat:@"%@ %@",linePrefixString,lineValueString];
}

- (IBAction)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)segmentedControlDidValueChange:(id)sender{
    if(!self.currentChildViewController){
        return;
    }
    [self.currentChildViewController willMoveToParentViewController:nil];
    [self.currentChildViewController.view removeFromSuperview];
    [self.currentChildViewController removeFromParentViewController];
    
    if(self.segmentedControl.selectedSegmentIndex==0){
        [self addViewControllerToContentView:self.contestListViewController];
    }
    else if(self.segmentedControl.selectedSegmentIndex==1){
        [self addViewControllerToContentView:self.poolsListViewController];
    }
}

-(void)addViewControllerToContentView:(UIViewController *)viewController{
    [self addChildViewController:viewController];
    viewController.view.frame=CGRectMake(0,0,self.contentView.bounds.size.width,self.contentView.bounds.size.height);
    [self.contentView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentChildViewController=viewController;
}


@end
