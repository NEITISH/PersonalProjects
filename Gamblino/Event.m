//
//  Event.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/12/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "Event.h"
#import "Line.h"
#import "Team.h"
#import "Participant.h"
#import "Answer.h"

NSString *const kEventId = @"id";
NSString *const kEventHomeScore = @"home_score";
NSString *const kEventAwayTeam = @"away_team";
NSString *const kEventStatus = @"status";
NSString *const kEventNotificationsSent = @"notifications_sent";
NSString *const kEventLines = @"lines";
NSString *const kEventHomeTeam = @"home_team";
NSString *const kEventStartTime = @"start_time";
NSString *const kEventParticipants = @"participants";
NSString *const kEventProgress = @"progress";
NSString *const kEventAwayScore = @"away_score";
NSString *const kEventEndedAt = @"ended_at";
NSString *const kEventLeagueId = @"league_id";
NSString *const kEventContextType = @"context_type";
NSString *const kEventPicture = @"picture";
NSString *const kEventTitle = @"title";
NSString *const kEventSubtitle = @"subtitle";
NSString *const kEventSubtitle2 = @"subtitle2";
NSString *const kEventAnswers = @"answers";
NSString *const kEventAnswerId = @"answer_id";
NSString *const kEventConferenceId = @"conference_id";
NSString *const kEventTotalWagers = @"total_wagers";
NSString *const kEventPreviewURL = @"preview_url";

@interface Event ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Event

@synthesize eventIdentifier = _eventIdentifier;
@synthesize homeScore = _homeScore;
@synthesize awayTeam = _awayTeam;
@synthesize status = _status;
@synthesize notificationsSent = _notificationsSent;
@synthesize lines = _lines;
@synthesize homeTeam = _homeTeam;
@synthesize startTime = _startTime;
@synthesize participants = _participants;
@synthesize progress = _progress;
@synthesize awayScore = _awayScore;
@synthesize endedAt = _endedAt;
@synthesize leagueId = _leagueId;
@synthesize contextType = _contextType;
@synthesize picture = _picture;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize subtitle2 = _subtitle2;
@synthesize answers = _answers;
@synthesize answerId = _answerId;
@synthesize conferenceId = _conferenceId;
@synthesize totalWagers = _totalWagers;
@synthesize previewURL = _previewURL;

+ (Event *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Event *instance = [[Event alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.eventIdentifier = [[self objectOrNilForKey:kEventId fromDictionary:dict] intValue];
        self.homeScore = [[self objectOrNilForKey:kEventHomeScore fromDictionary:dict] intValue];
        self.awayTeam = [Team modelObjectWithDictionary:[dict objectForKey:kEventAwayTeam]];
        self.status = [self objectOrNilForKey:kEventStatus fromDictionary:dict];
        self.contextType = [self objectOrNilForKey:kEventContextType fromDictionary:dict];
        self.picture = [self objectOrNilForKey:kEventPicture fromDictionary:dict];
        self.title = [self objectOrNilForKey:kEventTitle fromDictionary:dict];
        self.subtitle = [self objectOrNilForKey:kEventSubtitle fromDictionary:dict];
        self.subtitle2 = [self objectOrNilForKey:kEventSubtitle2 fromDictionary:dict];
        self.previewURL = [self objectOrNilForKey:kEventPreviewURL fromDictionary:dict];
        self.notificationsSent = [[self objectOrNilForKey:kEventNotificationsSent fromDictionary:dict] boolValue];
        NSObject *receivedLines = [dict objectForKey:kEventLines];
        NSMutableArray *parsedLines = [NSMutableArray array];
        if ([receivedLines isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedLines) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedLines addObject:[Line modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedLines isKindOfClass:[NSDictionary class]]) {
            [parsedLines addObject:[Line modelObjectWithDictionary:(NSDictionary *)receivedLines]];
        }
        
        self.lines = [NSArray arrayWithArray:parsedLines];
        NSObject *receivedAnswers = [dict objectForKey:kEventAnswers];
        NSMutableArray *parsedAnswers = [NSMutableArray array];
        if ([receivedAnswers isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedAnswers) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedAnswers addObject:[Answer modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedAnswers isKindOfClass:[NSDictionary class]]) {
            [parsedAnswers addObject:[Answer modelObjectWithDictionary:(NSDictionary *)receivedAnswers]];
        }
        
        self.answers = [NSArray arrayWithArray:parsedAnswers];
        self.homeTeam = [Team modelObjectWithDictionary:[dict objectForKey:kEventHomeTeam]];
        self.startTime = [self objectOrNilForKey:kEventStartTime fromDictionary:dict];
        NSObject *receivedParticipants = [dict objectForKey:kEventParticipants];
        NSMutableArray *parsedParticipants = [NSMutableArray array];
        if ([receivedParticipants isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedParticipants) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedParticipants addObject:[Participant modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedParticipants isKindOfClass:[NSDictionary class]]) {
            [parsedParticipants addObject:[Participant modelObjectWithDictionary:(NSDictionary *)receivedParticipants]];
        }
        
        self.participants = [NSArray arrayWithArray:parsedParticipants];
        self.progress = [self objectOrNilForKey:kEventProgress fromDictionary:dict];
        self.awayScore = [[self objectOrNilForKey:kEventAwayScore fromDictionary:dict] intValue];
        self.endedAt = [self objectOrNilForKey:kEventEndedAt fromDictionary:dict];
        self.leagueId = [[self objectOrNilForKey:kEventLeagueId fromDictionary:dict] intValue];
        self.answerId = [[self objectOrNilForKey:kEventAnswerId fromDictionary:dict] intValue];
        self.conferenceId = [[self objectOrNilForKey:kEventConferenceId fromDictionary:dict] intValue];
        self.totalWagers = [[self objectOrNilForKey:kEventTotalWagers fromDictionary:dict] intValue];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithInt:self.eventIdentifier] forKey:kEventId];
    [mutableDict setValue:[NSNumber numberWithInt:self.homeScore] forKey:kEventHomeScore];
    [mutableDict setValue:[self.awayTeam dictionaryRepresentation] forKey:kEventAwayTeam];
    [mutableDict setValue:self.status forKey:kEventStatus];
    [mutableDict setValue:self.contextType forKey:kEventContextType];
    [mutableDict setValue:self.picture forKey:kEventPicture];
    [mutableDict setValue:self.title forKey:kEventTitle];
    [mutableDict setValue:self.subtitle forKey:kEventSubtitle];
    [mutableDict setValue:self.subtitle2 forKey:kEventSubtitle2];
    [mutableDict setValue:self.previewURL forKey:kEventPreviewURL];
    [mutableDict setValue:[NSNumber numberWithBool:self.notificationsSent] forKey:kEventNotificationsSent];
    NSMutableArray *tempArrayForAnswers = [NSMutableArray array];
    for (NSObject *subArrayObject in self.answers) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForAnswers addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForAnswers addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForAnswers] forKey:@"kEventAnswers"];
    NSMutableArray *tempArrayForLines = [NSMutableArray array];
    for (NSObject *subArrayObject in self.lines) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLines addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLines addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLines] forKey:kEventLines];
    [mutableDict setValue:[self.homeTeam dictionaryRepresentation] forKey:kEventHomeTeam];
    [mutableDict setValue:self.startTime forKey:kEventStartTime];
    NSMutableArray *tempArrayForParticipants = [NSMutableArray array];
    for (NSObject *subArrayObject in self.participants) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForParticipants addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForParticipants addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForParticipants] forKey:kEventParticipants];
    [mutableDict setValue:self.progress forKey:kEventProgress];
    [mutableDict setValue:[NSNumber numberWithInt:self.awayScore] forKey:kEventAwayScore];
    [mutableDict setValue:self.endedAt forKey:kEventEndedAt];
    [mutableDict setValue:[NSNumber numberWithInt:self.leagueId] forKey:kEventLeagueId];
    [mutableDict setValue:[NSNumber numberWithInt:self.answerId] forKey:kEventAnswerId];
    [mutableDict setValue:[NSNumber numberWithInt:self.conferenceId] forKey:kEventConferenceId];
    [mutableDict setValue:[NSNumber numberWithInt:self.totalWagers] forKey:kEventTotalWagers];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.eventIdentifier = [aDecoder decodeIntForKey:kEventId];
    self.homeScore = [aDecoder decodeIntForKey:kEventHomeScore];
    self.awayTeam = [aDecoder decodeObjectForKey:kEventAwayTeam];
    self.status = [aDecoder decodeObjectForKey:kEventStatus];
    self.contextType = [aDecoder decodeObjectForKey:kEventContextType];
    self.picture = [aDecoder decodeObjectForKey:kEventPicture];
    self.title = [aDecoder decodeObjectForKey:kEventTitle];
    self.subtitle = [aDecoder decodeObjectForKey:kEventSubtitle];
    self.subtitle2 = [aDecoder decodeObjectForKey:kEventSubtitle2];
    self.previewURL = [aDecoder decodeObjectForKey:kEventPreviewURL];
    self.notificationsSent = [aDecoder decodeBoolForKey:kEventNotificationsSent];
    self.lines = [aDecoder decodeObjectForKey:kEventLines];
    self.homeTeam = [aDecoder decodeObjectForKey:kEventHomeTeam];
    self.startTime = [aDecoder decodeObjectForKey:kEventStartTime];
    self.participants = [aDecoder decodeObjectForKey:kEventParticipants];
    self.progress = [aDecoder decodeObjectForKey:kEventProgress];
    self.awayScore = [aDecoder decodeIntForKey:kEventAwayScore];
    self.endedAt = [aDecoder decodeObjectForKey:kEventEndedAt];
    self.leagueId = [aDecoder decodeIntForKey:kEventLeagueId];
    self.answers = [aDecoder decodeObjectForKey:kEventAnswers];
    self.answerId = [aDecoder decodeIntForKey:kEventAnswerId];
    self.conferenceId = [aDecoder decodeIntForKey:kEventConferenceId];
    self.totalWagers = [aDecoder decodeIntForKey:kEventTotalWagers];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeInt:_eventIdentifier forKey:kEventId];
    [aCoder encodeInt:_homeScore forKey:kEventHomeScore];
    [aCoder encodeObject:_awayTeam forKey:kEventAwayTeam];
    [aCoder encodeObject:_status forKey:kEventStatus];
    [aCoder encodeObject:_contextType forKey:kEventContextType];
    [aCoder encodeObject:_picture forKey:kEventPicture];
    [aCoder encodeObject:_title forKey:kEventTitle];
    [aCoder encodeObject:_subtitle forKey:kEventSubtitle];
    [aCoder encodeObject:_subtitle2 forKey:kEventSubtitle2];
    [aCoder encodeObject:_previewURL forKey:kEventPreviewURL];
    [aCoder encodeBool:_notificationsSent forKey:kEventNotificationsSent];
    [aCoder encodeObject:_lines forKey:kEventLines];
    [aCoder encodeObject:_homeTeam forKey:kEventHomeTeam];
    [aCoder encodeObject:_startTime forKey:kEventStartTime];
    [aCoder encodeObject:_participants forKey:kEventParticipants];
    [aCoder encodeObject:_progress forKey:kEventProgress];
    [aCoder encodeInt:_awayScore forKey:kEventAwayScore];
    [aCoder encodeObject:_endedAt forKey:kEventEndedAt];
    [aCoder encodeInt:_leagueId forKey:kEventLeagueId];
    [aCoder encodeObject:_answers forKey:kEventAnswers];
    [aCoder encodeInt:_answerId forKey:kEventAnswerId];
    [aCoder encodeInt:_conferenceId forKey:kEventConferenceId];
    [aCoder encodeInt:_totalWagers forKey:kEventTotalWagers];
}


@end

