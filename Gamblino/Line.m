//
//  Lines.m
//
//  Created by   on 12/12/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Line.h"


NSString *const kLinesStatus = @"status";
NSString *const kLinesId = @"id";
NSString *const kLinesCreatedAt = @"created_at";
NSString *const kLinesTeamId = @"team_id";
NSString *const kLinesEventId = @"event_id";
NSString *const kLinesLine = @"line";
NSString *const kLinesType = @"type";
NSString *const kLinesUpdatedAt = @"updated_at";


@interface Line ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Line

@synthesize status = _status;
@synthesize linesIdentifier = _linesIdentifier;
@synthesize createdAt = _createdAt;
@synthesize teamId = _teamId;
@synthesize eventId = _eventId;
@synthesize line = _line;
@synthesize type = _type;
@synthesize updatedAt = _updatedAt;


+ (Line *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Line *instance = [[Line alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.status = [self objectOrNilForKey:kLinesStatus fromDictionary:dict];
            self.linesIdentifier = [[self objectOrNilForKey:kLinesId fromDictionary:dict] intValue];
            self.createdAt = [self objectOrNilForKey:kLinesCreatedAt fromDictionary:dict];
            self.teamId = [[self objectOrNilForKey:kLinesTeamId fromDictionary:dict] intValue];
            self.eventId = [[self objectOrNilForKey:kLinesEventId fromDictionary:dict] intValue];
            self.line = [[self objectOrNilForKey:kLinesLine fromDictionary:dict] doubleValue];
            self.type = [self objectOrNilForKey:kLinesType fromDictionary:dict];
            self.updatedAt = [self objectOrNilForKey:kLinesUpdatedAt fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.status forKey:kLinesStatus];
    [mutableDict setValue:[NSNumber numberWithInt:self.linesIdentifier] forKey:kLinesId];
    [mutableDict setValue:self.createdAt forKey:kLinesCreatedAt];
    [mutableDict setValue:[NSNumber numberWithInt:self.teamId] forKey:kLinesTeamId];
    [mutableDict setValue:[NSNumber numberWithInt:self.eventId] forKey:kLinesEventId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.line] forKey:kLinesLine];
    [mutableDict setValue:self.type forKey:kLinesType];
    [mutableDict setValue:self.updatedAt forKey:kLinesUpdatedAt];

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

    self.status = [aDecoder decodeObjectForKey:kLinesStatus];
    self.linesIdentifier = [aDecoder decodeIntForKey:kLinesId];
    self.createdAt = [aDecoder decodeObjectForKey:kLinesCreatedAt];
    self.teamId = [aDecoder decodeIntForKey:kLinesTeamId];
    self.eventId = [aDecoder decodeIntForKey:kLinesEventId];
    self.line = [aDecoder decodeDoubleForKey:kLinesLine];
    self.type = [aDecoder decodeObjectForKey:kLinesType];
    self.updatedAt = [aDecoder decodeObjectForKey:kLinesUpdatedAt];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_status forKey:kLinesStatus];
    [aCoder encodeInt:_linesIdentifier forKey:kLinesId];
    [aCoder encodeObject:_createdAt forKey:kLinesCreatedAt];
    [aCoder encodeInt:_teamId forKey:kLinesTeamId];
    [aCoder encodeInt:_eventId forKey:kLinesEventId];
    [aCoder encodeDouble:_line forKey:kLinesLine];
    [aCoder encodeObject:_type forKey:kLinesType];
    [aCoder encodeObject:_updatedAt forKey:kLinesUpdatedAt];
}


@end
