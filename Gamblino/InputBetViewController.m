//
//  InputBetViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/30/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "InputBetViewController.h"
#import "GradientView.h"
#import "UIColor+Gamblino.h"
#import "Team.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
#import "User.h"
#import "PointBalance.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "Utils.h"
#import "Pool.h"
#import "PoolType.h"

@interface InputBetViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet GradientView *gradientView;
@property (nonatomic,weak) IBOutlet UIImageView *contestImageView;
@property (nonatomic,weak) IBOutlet UILabel *contestTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *pointsAvailableTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *maxBetTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *pointsAvailableLabel;
@property (nonatomic,weak) IBOutlet UILabel *maxBetLabel;
@property (nonatomic,weak) IBOutlet UILabel *atRiskTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *atRiskLabel;
@property (nonatomic,weak) IBOutlet UILabel *toWinTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *toWinLabel;
@property (nonatomic,weak) IBOutlet UITextField *betTextField;
@property (nonatomic,weak) IBOutlet UITextField *dummyBetTextField;
@property (nonatomic,weak) IBOutlet UIButton *placeBetButton;
@property (nonatomic,weak) IBOutlet UIView *cardView;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) Contest *contest;
@property (nonatomic,strong) Pool *pool;
@property (nonatomic,strong) Line *line;
@property (nonatomic,strong) Event *game;
@property (nonatomic,strong) Answer *answer;

@end

@implementation InputBetViewController

- (id)initWithBackgroundImage:(UIImage*)image contest:(Contest*)contest pool:(Pool*)pool line:(Line*)line game:(Event*)game answer:(Answer*)answer{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.contest=contest;
        self.pool=pool;
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
        self.gradientView.hidden=YES;
    }
    else{
        UIColor *awayTeamColor=[UIColor colorWithHexString:self.game.awayTeam.color];
        UIColor *homeTeamColor=[UIColor colorWithHexString:self.game.homeTeam.color];
        self.gradientView.leftColor=[awayTeamColor colorByChangingAlphaTo:0.5];
        self.gradientView.rightColor=[homeTeamColor colorByChangingAlphaTo:0.5];
    }
    
    [self.backgroundImageView setImage:self.blurImage];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.contestTitleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.betTextField setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.pointsAvailableTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.maxBetTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self.pointsAvailableLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:15.0]];
    [self.maxBetLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:15.0]];
    [self.toWinTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:12.0]];
    [self.atRiskTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:12.0]];
    [self.toWinLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    [self.atRiskLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0]];
    
    if(self.line){
        self.titleLabel.text=[self titleForLine:self.line];
    }
    else if(self.answer){
        self.titleLabel.text=self.answer.title.uppercaseString;
    }
    if(self.contest){
        self.contestTitleLabel.text=self.contest.title.uppercaseString;
    }
    else if(self.pool){
        self.contestTitleLabel.text=self.pool.title.uppercaseString;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.usesGroupingSeparator = YES;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    NSString *maxWagerString;
    NSString *pointsAvailableString;
    if(self.contest){
        maxWagerString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.contest.maxWager]];
        pointsAvailableString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.contest.me.points.available]];
    }
    else if(self.pool){
        maxWagerString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.pool.poolType.maxWager]];
        pointsAvailableString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.pool.me.points.available]];
    }
    self.maxBetLabel.text=[NSString stringWithFormat:@"%@pts",maxWagerString];
    self.pointsAvailableLabel.text=[NSString stringWithFormat:@"%@pts",pointsAvailableString];
//    self.placeBetButton.enabled=NO;
    
    NSMutableURLRequest *request;
    if(self.contest){
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.contest.bigPictureUrl]];
    }
    else if(self.pool){
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.pool.poolType.image]];
    }
    __weak UIImageView *weakImageView = self.contestImageView;
    weakImageView.image = nil;
    [weakImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
        [weakImageView setImage:image];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.dummyBetTextField becomeFirstResponder];
}

-(void)keyboardWillShow:(NSNotification*)notification{
    if(!IS_IPHONE_4INCHES){
        [UIView setAnimationDuration:0.3];
        [self.cardView setTransform:CGAffineTransformMakeTranslation(0.0, -35.0)];
        [UIView commitAnimations];
    }
}

-(void)keyboardWillHide:(NSNotification*)notification{
    if(!IS_IPHONE_4INCHES){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [self.cardView setTransform:CGAffineTransformIdentity];
        [UIView commitAnimations];
    }
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

-(IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)placeBetAction:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *numbersOnlyText=[[self.betTextField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]componentsJoinedByString:@""];
   
    NSDictionary *parameters;
    if(self.line){
        if(self.contest){
            parameters=@{@"line":[NSNumber numberWithInt:self.line.linesIdentifier],@"contest_id":[NSNumber numberWithInt:self.contest.contestIdentifier],@"amount":[NSNumber numberWithInt:numbersOnlyText.integerValue]};
        }
        else if(self.pool){
            parameters=@{@"line":[NSNumber numberWithInt:self.line.linesIdentifier],@"pool_id":[NSNumber numberWithInt:self.pool.poolIdentifier],@"amount":[NSNumber numberWithInt:numbersOnlyText.integerValue]};
        }
    }
    else if(self.answer){
        if(self.contest){
            parameters=@{@"answer_id":[NSNumber numberWithInt:self.answer.answerIdentifier],@"contest_id":[NSNumber numberWithInt:self.contest.contestIdentifier],@"amount":[NSNumber numberWithInt:numbersOnlyText.integerValue]};
        }
        else if(self.pool){
            parameters=@{@"answer_id":[NSNumber numberWithInt:self.answer.answerIdentifier],@"pool_id":[NSNumber numberWithInt:self.pool.poolIdentifier],@"amount":[NSNumber numberWithInt:numbersOnlyText.integerValue]};
        }
    }
    
    NSString *remotePath=@"wagers";
    [[NetworkManager sharedInstance] POST:remotePath withParameters:parameters successBlock:^(NSDictionary *contestsDictionary){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:^{}];
    }failureBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error=%@",error.description);
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField==self.dummyBetTextField){
        NSString *editedText=[textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *numbersOnlyText=[[editedText componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]componentsJoinedByString:@""];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.usesGroupingSeparator = YES;
        numberFormatter.groupingSeparator = @",";
        numberFormatter.groupingSize = 3;
        NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:numbersOnlyText.doubleValue]];
        self.betTextField.text = [NSString stringWithFormat:@"%@pts",formattedNumberString];
        self.atRiskLabel.text = [NSString stringWithFormat:@"%@pts",formattedNumberString];
        double pointsToWin;
        if([self.game.contextType isEqualToString:@"CustomEvent"]){
            pointsToWin=[Utils pointsToWinForWager:numbersOnlyText.doubleValue lineType:@"custom" lineAmount:self.answer.value];
        }
        else{
            pointsToWin=[Utils pointsToWinForWager:numbersOnlyText.doubleValue lineType:self.line.type lineAmount:self.line.line];
        }
        NSString *pointsToWinNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:pointsToWin]];
        self.toWinLabel.text = [NSString stringWithFormat:@"%@pts",pointsToWinNumberString];
//        if(self.contest && numbersOnlyText.doubleValue>0 && numbersOnlyText.doubleValue<=self.contest.me.points.available && numbersOnlyText.doubleValue<=self.contest.maxWager){
//            self.placeBetButton.enabled=YES;
//        }
//        else if(self.pool && numbersOnlyText.doubleValue>0 && numbersOnlyText.doubleValue<=self.pool.me.points.available && numbersOnlyText.doubleValue<=self.pool.poolType.maxWager){
//            self.placeBetButton.enabled=YES;
//        }
//        else{
//            self.placeBetButton.enabled=NO;
//        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField==self.betTextField){
        return NO;
    }
    return YES;
}

@end
