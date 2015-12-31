//
//  Utils.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/12/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Team.h"
#import "Contest.h"
#import "User.h"
#import "PointBalance.h"

@interface Utils : NSObject

+ (NSDate*)dateFromGamblinoDateString:(NSString*)dateString;
+ (NSString*)apiStringFromDate:(NSDate*)date;
+ (NSString*)stringFromDate:(NSDate*)date;
+ (NSString*)shortStringFromDate:(NSDate*)date;
+ (NSString*)monthDayStringFromDate:(NSDate*)date;
+ (NSAttributedString*)gameAttributedStringWithHometeam:(Team*)homeTeam awayTeam:(Team*)awayTeam;
+ (UIImage *)image:(UIImage *)img withMask:(UIImage *)maskImg;
+ (double)pointsToWinForWager:(double)wager lineType:(NSString*)lineType lineAmount:(double)lineAmount;
+ (NSAttributedString*)wagerAttributedStringWithAmountPlayed:(double)amountPlayed toWin:(double)toWinAmount;
+ (NSAttributedString*)wagerAttributedStringWithResult:(NSString*)result points:(int)points name:(NSString*)name;
+ (NSString *) addSuffixToNumber:(int) number;
+ (NSString*)shortStringForInt:(int)i;

@end
