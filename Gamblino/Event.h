//
//  Event.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/12/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Team;

@interface Event : NSObject <NSCoding>

@property (nonatomic, assign) int eventIdentifier;
@property (nonatomic, assign) int homeScore;
@property (nonatomic, strong) Team *awayTeam;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign) BOOL notificationsSent;
@property (nonatomic, strong) NSArray *lines;
@property (nonatomic, strong) Team *homeTeam;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSArray *participants;
@property (nonatomic, strong) NSString *progress;
@property (nonatomic, assign) int awayScore;
@property (nonatomic, strong) NSString *endedAt;
@property (nonatomic, assign) int leagueId;
@property (nonatomic, strong) NSString *contextType;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *subtitle2;
@property (nonatomic, strong) NSArray *answers;
@property (nonatomic, assign) int answerId;
@property (nonatomic, assign) int conferenceId;
@property (nonatomic, assign) int totalWagers;
@property (nonatomic, strong) NSString *previewURL;

+ (Event *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
