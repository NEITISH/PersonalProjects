//
//  Utils.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/12/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "Utils.h"
#import "UIColor+Gamblino.h"
#import "Constants.h"

@implementation Utils

+ (NSDate*)dateFromGamblinoDateString:(NSString*)dateString{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd h:mm a z"];
    inputFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDate *date=[inputFormatter dateFromString:dateString];
    return date;
}

+ (NSString*)apiStringFromDate:(NSDate*)date{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [outputFormatter stringFromDate:date];
}

+ (NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setAMSymbol:@"A"];
    [outputFormatter setPMSymbol:@"P"];
    [outputFormatter setDateFormat:@"h:mma z MMMM dd"];
    
    NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
    [monthDayFormatter setDateFormat:@"d"];
    int date_day = [[monthDayFormatter stringFromDate:date] intValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];
    
    NSString *string=[NSString stringWithFormat:@"%@%@",[outputFormatter stringFromDate:date],suffix].uppercaseString;
    return string;
}

+ (NSString*)shortStringFromDate:(NSDate*)date{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"MMM"];
    NSString *monthString=[NSString stringWithFormat:@"%@",[outputFormatter stringFromDate:date].uppercaseString];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger date_year = [components year];
    NSInteger date_day = [components day];
    
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];
    
    NSString *dayString=[NSString stringWithFormat:@"%ld%@",(long)date_day,suffix].uppercaseString;
    
    NSString *dateString=[NSString stringWithFormat:@"%@. %@ %ld",monthString,dayString,(long)date_year];
    return dateString;
}

+ (NSString*)monthDayStringFromDate:(NSDate*)date{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"MM/dd"];
    return [outputFormatter stringFromDate:date];
}

+ (NSAttributedString*)gameAttributedStringWithHometeam:(Team*)homeTeam awayTeam:(Team*)awayTeam{
    NSString *teamsLabelString=[NSString stringWithFormat:@"%@ VS %@",awayTeam.displayName,homeTeam.displayName].uppercaseString;
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:teamsLabelString];
    if(awayTeam.displayName){
        NSRange awayTeamRange=[teamsLabelString rangeOfString:awayTeam.displayName.uppercaseString];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0] range:awayTeamRange];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:awayTeam.color] range:awayTeamRange];
    }
    if(homeTeam.displayName){
        NSRange homeTeamRange=[teamsLabelString rangeOfString:homeTeam.displayName.uppercaseString options:NSBackwardsSearch];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:24.0] range:homeTeamRange];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:homeTeam.color] range:homeTeamRange];
    }
    NSRange vsRange=[teamsLabelString rangeOfString:@"VS"];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0] range:vsRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:201.0/255.0 green:194.0/255.0 blue:176.0/255.0 alpha:1.0] range:vsRange];
    return attributedString;
}

+ (NSAttributedString*)wagerAttributedStringWithAmountPlayed:(double)amountPlayed toWin:(double)toWinAmount{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.usesGroupingSeparator = YES;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    NSString *amountPlayedString = [NSString stringWithFormat:@"%@pts",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:amountPlayed]]];
    NSString *toWinAmountString = [NSString stringWithFormat:@"%@pts",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:toWinAmount]]];
    NSString *wagerString = [NSString stringWithFormat:@"%@ to win %@",amountPlayedString,toWinAmountString];
    
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:wagerString];
    NSRange amountPlayedRange=[wagerString rangeOfString:amountPlayedString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0] range:amountPlayedRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:32.0/255.0 green:28.0/255.0 blue:20.0/255.0 alpha:1.0] range:amountPlayedRange];
    
    NSRange toWinAmountRange=[wagerString rangeOfString:toWinAmountString options:NSBackwardsSearch];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0] range:toWinAmountRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:32.0/255.0 green:28.0/255.0 blue:20.0/255.0 alpha:1.0] range:toWinAmountRange];
    
    NSRange toWinRange=[wagerString rangeOfString:@"to win"];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0] range:toWinRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:201.0/255.0 green:194.0/255.0 blue:176.0/255.0 alpha:1.0] range:toWinRange];
    
    return attributedString;
}

+ (NSAttributedString*)wagerAttributedStringWithResult:(NSString*)result points:(int)points name:(NSString*)name{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.usesGroupingSeparator = YES;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.groupingSize = 3;
    NSString *pointsString = [NSString stringWithFormat:@"%@pts",[numberFormatter stringFromNumber:[NSNumber numberWithInt:abs(points)]]];
    NSString *prefixString;
    if([result isEqualToString:@"win"]||[result isEqualToString:@"tie"]) {
        prefixString=[NSString stringWithFormat:@"%@ won",name];
    }
    else{
        prefixString=[NSString stringWithFormat:@"%@ lost",name];
    }
    NSString *resultsString = [NSString stringWithFormat:@"%@ %@",prefixString,pointsString];
    
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:resultsString];
    NSRange prefixRange=[resultsString rangeOfString:prefixString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0] range:prefixRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:201.0/255.0 green:194.0/255.0 blue:176.0/255.0 alpha:1.0] range:prefixRange];
    
    NSRange pointsRange=[resultsString rangeOfString:pointsString options:NSBackwardsSearch];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamHTF-BoldCondensed" size:18.0] range:pointsRange];
    if([result isEqualToString:@"win"]||[result isEqualToString:@"tie"]) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:86.0/255.0 green:185.0/255.0 blue:27.0/255.0 alpha:1.0] range:pointsRange];
    }
    else{
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:230.0/255.0 green:66.0/255.0 blue:40.0/255.0 alpha:1.0] range:pointsRange];
    }

    return attributedString;
}


+ (double)pointsToWinForWager:(double)wager lineType:(NSString*)lineType lineAmount:(double)lineAmount{
    if([lineType isEqualToString:kMoneyType]||[lineType isEqualToString:kCustomType]){
        if(lineAmount>0){
            return wager*abs(lineAmount)/100;
        }
        else{
            return wager*100/abs(lineAmount);
        }
    }
    else{
        return wager;
    }
    return 0;
}

+ (NSString *) addSuffixToNumber:(int) number{
    NSString *suffix;
    int ones = number % 10;
    int temp = floor(number/10.0);
    int tens = temp%10;
    
    if (tens ==1) {
        suffix = @"th";
    } else if (ones ==1){
        suffix = @"st";
    } else if (ones ==2){
        suffix = @"nd";
    } else if (ones ==3){
        suffix = @"rd";
    } else {
        suffix = @"th";
    }
    
    NSString *completeAsString = [NSString stringWithFormat:@"%d%@",number,suffix];
    return completeAsString;
}

+ (NSString*)shortStringForInt:(int)i {
    NSString * string;
    if(i < 1000) {
        string = [NSString stringWithFormat:@"%d",i];
    }
    else {
        float iInThousands = (float)i / 1000;
        string = [NSString stringWithFormat:@"%.1fk",iInThousands];
    }
    return string;
}

@end
