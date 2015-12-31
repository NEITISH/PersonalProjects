//
//  PrizeCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/21/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PrizeCell;

@protocol PrizeCellDelegate <NSObject>
@optional
-(void)prizeCellDidRedeem:(PrizeCell*)prizeCell;
@end


@interface PrizeCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *contestImageView;
@property (nonatomic,weak) IBOutlet UILabel *contestTitleLabel;;
@property (nonatomic,weak) IBOutlet UILabel *redeemableMessageLabel;
@property (nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic,weak) IBOutlet UIButton *redeemButton;
@property (nonatomic,weak) IBOutlet UILabel *redeemedLabel;
@property (nonatomic,weak) IBOutlet UILabel *expiredLabel;
@property (nonatomic,weak) id<PrizeCellDelegate> delegate;

-(IBAction)redeemAction:(id)sender;

@end
