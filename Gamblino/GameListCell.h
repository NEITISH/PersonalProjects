//
//  GameListCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/12/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameListCell;

@protocol GameListCellDelegate <NSObject>
@optional
-(void)gameListCellShowNextLine:(GameListCell*)gameListCell;
@end

@interface GameListCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *teamsLabel;
@property(nonatomic,weak) IBOutlet UILabel *dateLabel;
@property(nonatomic,weak) IBOutlet UIImageView *awayImageView;
@property(nonatomic,weak) IBOutlet UIImageView *homeImageView;
@property(nonatomic,weak) IBOutlet UILabel *overLabel;
@property(nonatomic,weak) IBOutlet UILabel *underLabel;
@property(nonatomic,weak) IBOutlet UILabel *betsLabel;
@property(nonatomic,weak) IBOutlet UIImageView *customEventImageView;
@property(nonatomic,weak) IBOutlet UILabel *customEventTitleLabel;
@property(nonatomic,weak) IBOutlet UILabel *customEventSubtitleLabel;
@property(nonatomic,weak) IBOutlet UIView *userPicturesView;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,weak) id<GameListCellDelegate>delegate;
@property(nonatomic) int indexOfCurrentLine;

@end
