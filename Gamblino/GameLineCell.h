//
//  LineViewCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/22/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameLineCell;

@protocol GameLineCellDelegate <NSObject>
@optional
-(void)gameLineCellDidTapLeftButton:(GameLineCell*)gameLineCell;
-(void)gameLineCellDidTapRightButton:(GameLineCell*)gameLineCell;
-(void)gameLineCellDidTapAnswer:(GameLineCell*)gameLineCell;
@end

@interface GameLineCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *awayLeftImageView;
@property (nonatomic,weak) IBOutlet UIImageView *awayRightImageView;
@property (nonatomic,weak) IBOutlet UIImageView *homeLeftImageView;
@property (nonatomic,weak) IBOutlet UIImageView *homeRightImageView;
@property (nonatomic,weak) IBOutlet UIButton *awayButton;
@property (nonatomic,weak) IBOutlet UIButton *homeButton;
@property (nonatomic,weak) IBOutlet UILabel *lineTitleLabel;
@property (nonatomic,weak) IBOutlet UIImageView *customEventAnswerImageView;
@property (nonatomic,weak) IBOutlet UIButton *customEventAnswerButton;
@property (nonatomic,weak) id<GameLineCellDelegate> delegate;

-(IBAction)leftButtonAction:(id)sender;
-(IBAction)rightButtonAction:(id)sender;
-(IBAction)customAnswerAction:(id)sender;

@end
