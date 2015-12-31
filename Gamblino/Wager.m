//
//  Wager.m
//
//  Created by   on 1/5/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "Wager.h"
#import "Contest.h"
#import "Event.h"
#import "Team.h"
#import "User.h"
#import "Answer.h"
#import "Pool.h"

NSString *const kWagerId = @"id";
NSString *const kWagerPoints = @"points";
NSString *const kWagerContest = @"contest";
NSString *const kWagerAmount = @"amount";
NSString *const kWagerOpponent = @"opponent";
NSString *const kWagerEvent = @"event";
NSString *const kWagerCustomEvent = @"custom_event";
NSString *const kWagerType = @"type";
NSString *const kWagerTeam = @"team";
NSString *const kWagerResult = @"result";
NSString *const kWagerLine = @"line";
NSString *const kWagerUser = @"user";
NSString *const kWagerAnswer = @"answer";
NSString *const kWagerPool = @"pool";

@interface Wager ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Wager

@synthesize wagerIdentifier = _wagerIdentifier;
@synthesize points = _points;
@synthesize contest = _contest;
@synthesize amount = _amount;
@synthesize opponent = _opponent;
@synthesize event = _event;
@synthesize customEvent = _customEvent;
@synthesize type = _type;
@synthesize team = _team;
@synthesize result = _result;
@synthesize line = _line;
@synthesize user = _user;
@synthesize answer = _answer;
@synthesize pool = _pool;

+ (Wager *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Wager *instance = [[Wager alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.wagerIdentifier = [[self objectOrNilForKey:kWagerId fromDictionary:dict] intValue];
            self.points = [[self objectOrNilForKey:kWagerPoints fromDictionary:dict] intValue];
            self.contest = [Contest modelObjectWithDictionary:[dict objectForKey:kWagerContest]];
            self.amount = [[self objectOrNilForKey:kWagerAmount fromDictionary:dict] intValue];
            self.opponent = [self objectOrNilForKey:kWagerOpponent fromDictionary:dict];
            self.event = [Event modelObjectWithDictionary:[dict objectForKey:kWagerEvent]];
            self.customEvent = [Event modelObjectWithDictionary:[dict objectForKey:kWagerCustomEvent]];
            self.type = [self objectOrNilForKey:kWagerType fromDictionary:dict];
            self.team = [Team modelObjectWithDictionary:[dict objectForKey:kWagerTeam]];
            self.result = [self objectOrNilForKey:kWagerResult fromDictionary:dict];
            self.line = [[self objectOrNilForKey:kWagerLine fromDictionary:dict] doubleValue];
            self.user = [User modelObjectWithDictionary:[dict objectForKey:kWagerUser]];
            self.answer = [Answer modelObjectWithDictionary:[dict objectForKey:kWagerAnswer]];
        self.pool = [Pool modelObjectWithDictionary:[dict objectForKey:kWagerPool]];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithInt:self.wagerIdentifier] forKey:kWagerId];
    [mutableDict setValue:[NSNumber numberWithInt:self.points] forKey:kWagerPoints];
    [mutableDict setValue:[self.contest dictionaryRepresentation] forKey:kWagerContest];
    [mutableDict setValue:[NSNumber numberWithInt:self.amount] forKey:kWagerAmount];
    [mutableDict setValue:self.opponent forKey:kWagerOpponent];
    [mutableDict setValue:[self.event dictionaryRepresentation] forKey:kWagerEvent];
    [mutableDict setValue:[self.customEvent dictionaryRepresentation] forKey:kWagerCustomEvent];
    [mutableDict setValue:self.type forKey:kWagerType];
    [mutableDict setValue:[self.team dictionaryRepresentation] forKey:kWagerTeam];
    [mutableDict setValue:self.result forKey:kWagerResult];
    [mutableDict setValue:[NSNumber numberWithDouble:self.line] forKey:kWagerLine];
    [mutableDict setValue:[self.user dictionaryRepresentation] forKey:kWagerUser];
    [mutableDict setValue:[self.answer dictionaryRepresentation] forKey:kWagerAnswer];
    [mutableDict setValue:[self.pool dictionaryRepresentation] forKey:kWagerPool];

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

    self.wagerIdentifier = [aDecoder decodeIntForKey:kWagerId];
    self.points = [aDecoder decodeIntForKey:kWagerPoints];
    self.contest = [aDecoder decodeObjectForKey:kWagerContest];
    self.amount = [aDecoder decodeIntForKey:kWagerAmount];
    self.opponent = [aDecoder decodeObjectForKey:kWagerOpponent];
    self.event = [aDecoder decodeObjectForKey:kWagerEvent];
    self.customEvent = [aDecoder decodeObjectForKey:kWagerCustomEvent];
    self.type = [aDecoder decodeObjectForKey:kWagerType];
    self.team = [aDecoder decodeObjectForKey:kWagerTeam];
    self.result = [aDecoder decodeObjectForKey:kWagerResult];
    self.line = [aDecoder decodeDoubleForKey:kWagerLine];
    self.user = [aDecoder decodeObjectForKey:kWagerUser];
    self.answer = [aDecoder decodeObjectForKey:kWagerAnswer];
    self.pool = [aDecoder decodeObjectForKey:kWagerPool];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeInt:_wagerIdentifier forKey:kWagerId];
    [aCoder encodeInt:_points forKey:kWagerPoints];
    [aCoder encodeObject:_contest forKey:kWagerContest];
    [aCoder encodeInt:_amount forKey:kWagerAmount];
    [aCoder encodeObject:_opponent forKey:kWagerOpponent];
    [aCoder encodeObject:_event forKey:kWagerEvent];
    [aCoder encodeObject:_customEvent forKey:kWagerCustomEvent];
    [aCoder encodeObject:_type forKey:kWagerType];
    [aCoder encodeObject:_team forKey:kWagerTeam];
    [aCoder encodeObject:_result forKey:kWagerResult];
    [aCoder encodeDouble:_line forKey:kWagerLine];
    [aCoder encodeObject:_user forKey:kWagerUser];
    [aCoder encodeObject:_answer forKey:kWagerAnswer];
    [aCoder encodeObject:_pool forKey:kWagerPool];
}


@end
