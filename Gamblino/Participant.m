//
//  Participants.m
//
//  Created by   on 12/12/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Participant.h"
#import "User.h"


NSString *const kParticipantsAmount = @"amount";
NSString *const kParticipantsResult = @"result";
NSString *const kParticipantsPoints = @"points";
NSString *const kParticipantsId = @"id";
NSString *const kParticipantsEventId = @"event_id";
NSString *const kParticipantsLine = @"line";
NSString *const kParticipantsType = @"type";
NSString *const kParticipantsUser = @"user";


@interface Participant ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Participant

@synthesize amount = _amount;
@synthesize result = _result;
@synthesize points = _points;
@synthesize participantsIdentifier = _participantsIdentifier;
@synthesize eventId = _eventId;
@synthesize line = _line;
@synthesize type = _type;
@synthesize user = _user;


+ (Participant *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Participant *instance = [[Participant alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.amount = [[self objectOrNilForKey:kParticipantsAmount fromDictionary:dict] intValue];
            self.result = [self objectOrNilForKey:kParticipantsResult fromDictionary:dict];
            self.points = [[self objectOrNilForKey:kParticipantsPoints fromDictionary:dict] intValue];
            self.participantsIdentifier = [[self objectOrNilForKey:kParticipantsId fromDictionary:dict] intValue];
            self.eventId = [[self objectOrNilForKey:kParticipantsEventId fromDictionary:dict] intValue];
            self.line = [[self objectOrNilForKey:kParticipantsLine fromDictionary:dict] intValue];
            self.type = [self objectOrNilForKey:kParticipantsType fromDictionary:dict];
            self.user = [User modelObjectWithDictionary:[dict objectForKey:kParticipantsUser]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithInt:self.amount] forKey:kParticipantsAmount];
    [mutableDict setValue:self.result forKey:kParticipantsResult];
    [mutableDict setValue:[NSNumber numberWithInt:self.points] forKey:kParticipantsPoints];
    [mutableDict setValue:[NSNumber numberWithInt:self.participantsIdentifier] forKey:kParticipantsId];
    [mutableDict setValue:[NSNumber numberWithInt:self.eventId] forKey:kParticipantsEventId];
    [mutableDict setValue:[NSNumber numberWithInt:self.line] forKey:kParticipantsLine];
    [mutableDict setValue:self.type forKey:kParticipantsType];
    [mutableDict setValue:[self.user dictionaryRepresentation] forKey:kParticipantsUser];

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

    self.amount = [aDecoder decodeIntForKey:kParticipantsAmount];
    self.result = [aDecoder decodeObjectForKey:kParticipantsResult];
    self.points = [aDecoder decodeIntForKey:kParticipantsPoints];
    self.participantsIdentifier = [aDecoder decodeIntForKey:kParticipantsId];
    self.eventId = [aDecoder decodeIntForKey:kParticipantsEventId];
    self.line = [aDecoder decodeIntForKey:kParticipantsLine];
    self.type = [aDecoder decodeObjectForKey:kParticipantsType];
    self.user = [aDecoder decodeObjectForKey:kParticipantsUser];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeInt:_amount forKey:kParticipantsAmount];
    [aCoder encodeObject:_result forKey:kParticipantsResult];
    [aCoder encodeInt:_points forKey:kParticipantsPoints];
    [aCoder encodeInt:_participantsIdentifier forKey:kParticipantsId];
    [aCoder encodeInt:_eventId forKey:kParticipantsEventId];
    [aCoder encodeInt:_line forKey:kParticipantsLine];
    [aCoder encodeObject:_type forKey:kParticipantsType];
    [aCoder encodeObject:_user forKey:kParticipantsUser];
}


@end
