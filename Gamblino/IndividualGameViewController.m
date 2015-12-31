//
//  IndividualGameViewController.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/22/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "IndividualGameViewController.h"
#import "Utils.h"
#import "Team.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+Gamblino.h"
#import "Line.h"
#import "LineSet.h"
#import "Constants.h"
#import "GradientView.h"
#import "PlaceWagerViewController.h"
#import "Answer.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "LineMarkersViewController.h"
#import "AnalyticsManager.h"

@interface IndividualGameViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UILabel *teamsLabel;
@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet GradientView *gradientView;
@property (nonatomic,weak) IBOutlet UIButton *linemakersButton;
@property (nonatomic,strong) UIImage *blurImage;
@property (nonatomic,strong) NSArray *lineSets;

@end

@implementation IndividualGameViewController

- (id)initWithBackgroundImage:(UIImage*)image game:(Event*)game{
    self = [super init];
    if(self){
        self.blurImage=image;
        self.game=game;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self.game.contextType isEqualToString:@"CustomEvent"]){
        [self setupCustomEventView];
    }
    else{
        [self setupRegularEventView];
    }
    if(!self.game.previewURL) {
        self.linemakersButton.hidden = YES;
    }
    
    [self.backgroundImageView setImage:self.blurImage];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    [self.dateLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:9.0]];
    [self prepareLines];
}

- (void)setupCustomEventView{
    self.gradientView.hidden=YES;
    [self.teamsLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0]];
    self.teamsLabel.text=self.game.title.uppercaseString;
    self.dateLabel.text=self.game.subtitle2.uppercaseString;
}

- (void)setupRegularEventView{
    UIColor *awayTeamColor=[UIColor colorWithHexString:self.game.awayTeam.color];
    UIColor *homeTeamColor=[UIColor colorWithHexString:self.game.homeTeam.color];
    self.gradientView.leftColor=[awayTeamColor colorByChangingAlphaTo:0.2];
    self.gradientView.rightColor=[homeTeamColor colorByChangingAlphaTo:0.2];
    NSDate *date= [Utils dateFromGamblinoDateString:self.game.startTime];
    NSString *dateString= [Utils stringFromDate:date];
    self.dateLabel.text= [[NSString stringWithFormat:@"%@ @ %@",dateString,self.game.homeTeam.displayName] uppercaseString];
    self.teamsLabel.attributedText = [Utils gameAttributedStringWithHometeam:self.game.homeTeam awayTeam:self.game.awayTeam];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)closeAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)refreshScreen {
    [self prepareLines];
    [self.tableView reloadData];
}

- (void)prepareLines{
    NSMutableArray *lineSets=[[NSMutableArray alloc] init];
    NSArray *spreadArray = [self.game.lines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(type == %@)", kSpreadType]];
    if(spreadArray && spreadArray.count>0){
        LineSet *lineSet=[[LineSet alloc] init];
        lineSet.lineTitle=kStraightSpreadTitle;
        for(Line *line in spreadArray){
            if(line.teamId==self.game.awayTeam.teamIdentifier){
                lineSet.awayLine=line;
            }
            else if(line.teamId==self.game.homeTeam.teamIdentifier){
                lineSet.homeLine=line;
            }
        }
        [lineSets addObject:lineSet];
    }
    NSArray *moneyArray = [self.game.lines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(type == %@)", kMoneyType]];
    if(moneyArray && moneyArray.count>0){
        LineSet *lineSet=[[LineSet alloc] init];
        lineSet.lineTitle=kMoneyLineTitle;
        for(Line *line in moneyArray){
            if(line.teamId==self.game.awayTeam.teamIdentifier){
                lineSet.awayLine=line;
            }
            else if(line.teamId==self.game.homeTeam.teamIdentifier){
                lineSet.homeLine=line;
            }
        }
        [lineSets addObject:lineSet];
    }
    NSArray *overUnderArray = [self.game.lines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(type == %@) OR (type == %@)", kOverType,kUnderType]];
    if(overUnderArray && overUnderArray.count>0){
        LineSet *lineSet=[[LineSet alloc] init];
        lineSet.lineTitle=kOverUnderTitle;
        for(Line *line in overUnderArray){
            if([line.type isEqualToString:kOverType]){
                lineSet.overLine=line;
            }
            else if([line.type isEqualToString:kUnderType]){
                lineSet.underLine=line;
            }
        }
        [lineSets addObject:lineSet];
    }
    self.lineSets=lineSets;
}

- (CGPathRef) pathForLeftImage:(CGRect)rect radius:(CGFloat)radius{
	CGMutablePathRef path = CGPathCreateMutable();
    
	CGPathMoveToPoint(path, NULL, rect.origin.x+radius, rect.origin.y);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+0.8*rect.size.width, rect.origin.y);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+0.2*rect.size.width, rect.origin.y+rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+radius, rect.origin.y+rect.size.height);
	CGPathAddArcToPoint(path, NULL, rect.origin.x, rect.origin.y+rect.size.height, rect.origin.x, rect.origin.y+rect.size.height-radius, radius);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y+radius);
    CGPathAddArcToPoint(path, NULL, rect.origin.x, rect.origin.y, rect.origin.x+radius, rect.origin.y, radius);
	CGPathCloseSubpath(path);
    
	return path;
}

- (CGPathRef) pathForRightImage:(CGRect)rect radius:(CGFloat)radius{
	CGMutablePathRef path = CGPathCreateMutable();
    
	CGPathMoveToPoint(path, NULL, rect.origin.x+rect.size.width-radius, rect.origin.y+rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+0.2*rect.size.width, rect.origin.y+rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+0.8*rect.size.width, rect.origin.y);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+rect.size.width-radius, rect.origin.y);
	CGPathAddArcToPoint(path, NULL, rect.origin.x+rect.size.width, rect.origin.y, rect.origin.x+rect.size.width, rect.origin.y+radius, radius);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height-radius);
    CGPathAddArcToPoint(path, NULL, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height, rect.origin.x+rect.size.width-radius, rect.origin.y+rect.size.height, radius);
	CGPathCloseSubpath(path);
    
	return path;
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.game.contextType isEqualToString:@"CustomEvent"]){
        return 87.0;
    }
    else{
        return 106.0;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.game.contextType isEqualToString:@"CustomEvent"]){
        return self.game.answers.count;
    }
    else{
        return self.lineSets.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameLineCell *cell;
    if([self.game.contextType isEqualToString:@"CustomEvent"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"CustomEventCell"];
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
    if (cell == nil) {
        NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"GameLineCell" owner:self options:nil];
        if([self.game.contextType isEqualToString:@"CustomEvent"]){
            cell = (GameLineCell *)[nib objectAtIndex:1];
        }
        else{
            cell = (GameLineCell *)[nib objectAtIndex:0];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        
        [cell.awayButton setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
        cell.awayButton.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        cell.awayButton.layer.cornerRadius = 12.0;
        cell.awayButton.layer.borderWidth = 2.0;
        [cell.awayButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:40.0]];
        
        [cell.homeButton setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
        cell.homeButton.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        cell.homeButton.layer.cornerRadius = 12.0;
        cell.homeButton.layer.borderWidth = 2.0;
        [cell.homeButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:40.0]];
        
        [cell.customEventAnswerButton setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
        cell.customEventAnswerButton.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        cell.customEventAnswerButton.layer.cornerRadius = 12.0;
        cell.customEventAnswerButton.layer.borderWidth = 2.0;
        [cell.customEventAnswerButton.titleLabel setFont:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:40.0]];
        
        cell.customEventAnswerImageView.layer.cornerRadius = 12.0;
        
        [cell.lineTitleLabel setFont:[UIFont fontWithName:@"Knockout-HTF30-JuniorWelterwt" size:12.0]];
    }
    cell.delegate=self;
    
    if([self.game.contextType isEqualToString:@"CustomEvent"]){
        Answer *answer=[self.game.answers objectAtIndex:indexPath.row];
        cell.customEventAnswerImageView.layer.mask=nil;
        cell.customEventAnswerImageView.layer.cornerRadius=10.0;
        NSString *pointsString=[NSString stringWithFormat:@"%+g",answer.value];
        NSString *title=[self middlePaddedStringWithLeftString:[NSString stringWithFormat:@"  %@",answer.title] rightString:[NSString stringWithFormat:@"%@  ",pointsString] font:cell.customEventAnswerButton.titleLabel.font size:cell.customEventAnswerButton.bounds.size];
        [cell.customEventAnswerButton setTitle:title forState:UIControlStateNormal];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:answer.picture]];
        __weak UIImageView *weakImageView = cell.customEventAnswerImageView;
        weakImageView.image = nil;
        [weakImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
            [weakImageView setImage:image];
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"error=%@",[error description]);
        }];
    }
    else{
        LineSet *lineSet=[self.lineSets objectAtIndex:indexPath.row];
        if([lineSet.lineTitle isEqualToString:kStraightSpreadTitle]){
            [self configureLogosOnGameLineCell:cell];
            [cell.awayButton setTitle:[NSString stringWithFormat:@"%+g",lineSet.awayLine.line] forState:UIControlStateNormal];
            [cell.homeButton setTitle:[NSString stringWithFormat:@"%+g",lineSet.homeLine.line] forState:UIControlStateNormal];
        }
        else if([lineSet.lineTitle isEqualToString:kMoneyLineTitle]){
            [self configureLogosOnGameLineCell:cell];
            [cell.awayButton setTitle:[NSString stringWithFormat:@"%+g",lineSet.awayLine.line] forState:UIControlStateNormal];
            [cell.homeButton setTitle:[NSString stringWithFormat:@"%+g",lineSet.homeLine.line] forState:UIControlStateNormal];
        }
        else if([lineSet.lineTitle isEqualToString:kOverUnderTitle]){
            [self configureSplitImagesWithLeftImageView:cell.awayLeftImageView rightImageView:cell.awayRightImageView];
            [self configureSplitImagesWithLeftImageView:cell.homeLeftImageView rightImageView:cell.homeRightImageView];
            [cell.awayButton setTitle:[NSString stringWithFormat:@"U%g",lineSet.underLine.line] forState:UIControlStateNormal];
            [cell.homeButton setTitle:[NSString stringWithFormat:@"O%g",lineSet.overLine.line] forState:UIControlStateNormal];
        }
        cell.lineTitleLabel.text=lineSet.lineTitle;
    }
    
    return cell;
}

- (NSString*)middlePaddedStringWithLeftString:(NSString*)leftString rightString:(NSString*)rightString font:(UIFont*)font size:(CGSize)size{
    //works but kind of hacky, has to be a better way
    int numberOfSpaces=0;
    CGSize expectedLabelSize;
    NSString *resultString;
    do {
        NSString* spaces = [@"" stringByPaddingToLength:numberOfSpaces withString:@" " startingAtIndex:0];
        resultString=[NSString stringWithFormat:@"%@%@%@",leftString,spaces,rightString];
        expectedLabelSize = [resultString sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)lineBreakMode:UILineBreakModeTailTruncation];
        numberOfSpaces++;
    } while (expectedLabelSize.width<size.width);
    
    NSString* spaces = [@"" stringByPaddingToLength:MAX(0,numberOfSpaces-2) withString:@" " startingAtIndex:0];
    resultString=[NSString stringWithFormat:@"%@%@%@",leftString,spaces,rightString];

    return resultString;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)configureSplitImagesWithLeftImageView:(UIImageView*)leftImageView rightImageView:(UIImageView*)rightImageView{
    CAShapeLayer *leftShapeLayer = [[CAShapeLayer alloc] init];
    leftShapeLayer.frame = leftImageView.layer.bounds;
    leftShapeLayer.fillColor = [[UIColor blackColor] CGColor];
    leftShapeLayer.path = [self pathForLeftImage:leftImageView.bounds radius:10.0];
    leftImageView.layer.mask = leftShapeLayer;
    
    leftImageView.backgroundColor=[UIColor colorWithHexString:self.game.awayTeam.color];
    NSMutableURLRequest *leftRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.game.awayTeam.image]];
    __weak UIImageView *weakLeftImageView = leftImageView;
    weakLeftImageView.image = nil;
    [weakLeftImageView setImageWithURLRequest:leftRequest placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
        [weakLeftImageView setImage:image];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
    
    CAShapeLayer *rightShapeLayer = [[CAShapeLayer alloc] init];
    rightShapeLayer.frame = rightImageView.layer.bounds;
    rightShapeLayer.fillColor = [[UIColor blackColor] CGColor];
    rightShapeLayer.path = [self pathForRightImage:rightImageView.bounds radius:10.0];
    rightImageView.layer.mask = rightShapeLayer;
    
    rightImageView.backgroundColor=[UIColor colorWithHexString:self.game.homeTeam.color];
    NSMutableURLRequest *rightRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.game.homeTeam.image]];
    __weak UIImageView *weakRightImageView = rightImageView;
    weakRightImageView.image = nil;
    [weakRightImageView setImageWithURLRequest:rightRequest placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *rightImage ){
        [weakRightImageView setImage:rightImage];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
}

-(void)configureLogosOnGameLineCell:(GameLineCell*)cell{
    cell.awayLeftImageView.layer.mask=nil;
    cell.awayLeftImageView.layer.cornerRadius=10.0;
    cell.awayLeftImageView.clipsToBounds=YES;
    cell.homeLeftImageView.layer.mask=nil;
    cell.homeLeftImageView.layer.cornerRadius=10.0;
    cell.homeLeftImageView.clipsToBounds=YES;
    
    cell.awayLeftImageView.backgroundColor=[UIColor colorWithHexString:self.game.awayTeam.color];
    NSMutableURLRequest *awayRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.game.awayTeam.image]];
    __weak UIImageView *weakAwayImageView = cell.awayLeftImageView;
    weakAwayImageView.image = nil;
    [weakAwayImageView setImageWithURLRequest:awayRequest placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
        [weakAwayImageView setImage:image];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
    cell.awayRightImageView.image=nil;
    
    cell.homeLeftImageView.backgroundColor=[UIColor colorWithHexString:self.game.homeTeam.color];
    NSMutableURLRequest *homeRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.game.homeTeam.image]];
    __weak UIImageView *weakHomeImageView = cell.homeLeftImageView;
    weakHomeImageView.image = nil;
    [weakHomeImageView setImageWithURLRequest:homeRequest placeholderImage:nil success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
        [weakHomeImageView setImage:image];
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"error=%@",[error description]);
    }];
}

-(void)gameLineCellDidTapLeftButton:(GameLineCell *)gameLineCell{
    NSIndexPath *indexPath=[self.tableView indexPathForCell:gameLineCell];
    LineSet *lineSet=[self.lineSets objectAtIndex:indexPath.row];
    Line *line;
    if(lineSet.awayLine){
        line=lineSet.awayLine;
    }
    else if(lineSet.underLine){
        line=lineSet.underLine;
    }
    [self presentPlaceWagerViewControllerWithLine:line];
}

-(void)gameLineCellDidTapRightButton:(GameLineCell *)gameLineCell{
    NSIndexPath *indexPath=[self.tableView indexPathForCell:gameLineCell];
    LineSet *lineSet=[self.lineSets objectAtIndex:indexPath.row];
    Line *line;
    if(lineSet.homeLine){
        line=lineSet.homeLine;
    }
    else if(lineSet.overLine){
        line=lineSet.overLine;
    }
    [self presentPlaceWagerViewControllerWithLine:line];
}

-(void)gameLineCellDidTapAnswer:(GameLineCell*)gameLineCell{
    NSIndexPath *indexPath=[self.tableView indexPathForCell:gameLineCell];
    Answer *answer=[self.game.answers objectAtIndex:indexPath.row];
    PlaceWagerViewController *placeWagerViewController=[[PlaceWagerViewController alloc] initWithBackgroundImage:self.blurImage line:nil game:self.game answer:answer];
    [self.navigationController pushViewController:placeWagerViewController animated:YES];
}

-(void)presentPlaceWagerViewControllerWithLine:(Line*)line{
    PlaceWagerViewController *placeWagerViewController=[[PlaceWagerViewController alloc] initWithBackgroundImage:self.blurImage line:line game:self.game answer:nil];
    [self.navigationController pushViewController:placeWagerViewController animated:YES];
}

- (IBAction)lineMakersAction:(id)sender {
    [Flurry logEvent:@"Tapped LineMakers preview button"];
    if(self.game.previewURL) {
        NSString *titleString=[NSString stringWithFormat:@"%@ VS %@",self.game.awayTeam.displayName,self.game.homeTeam.displayName].uppercaseString;
        LineMarkersViewController *lineMakersViewController = [[LineMarkersViewController alloc] initWithUrlString:self.game.previewURL title:titleString];
        [self presentViewController:lineMakersViewController animated:YES completion:nil];
    }
}

@end
