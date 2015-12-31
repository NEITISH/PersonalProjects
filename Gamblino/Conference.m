//
//  Conference.m
//
//  Created by   on 12/14/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Conference.h"


NSString *const kConferenceShortName = @"short_name";
NSString *const kConferenceId = @"id";
NSString *const kConferenceActive = @"active";
NSString *const kConferenceName = @"name";
NSString *const kConferenceLeagueId = @"league_id";


@interface Conference ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Conference

@synthesize shortName = _shortName;
@synthesize conferenceId = _conferenceId;
@synthesize active = _active;
@synthesize name = _name;
@synthesize leagueId = _leagueId;


+ (Conference *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Conference *instance = [[Conference alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.shortName = [self objectOrNilForKey:kConferenceShortName fromDictionary:dict];
            self.conferenceId = [[self objectOrNilForKey:kConferenceId fromDictionary:dict] intValue];
            self.active = [[self objectOrNilForKey:kConferenceActive fromDictionary:dict] boolValue];
            self.name = [self objectOrNilForKey:kConferenceName fromDictionary:dict];
            self.leagueId = [[self objectOrNilForKey:kConferenceLeagueId fromDictionary:dict] intValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.shortName forKey:kConferenceShortName];
    [mutableDict setValue:[NSNumber numberWithInt:self.conferenceId] forKey:kConferenceId];
    [mutableDict setValue:[NSNumber numberWithBool:self.active] forKey:kConferenceActive];
    [mutableDict setValue:self.name forKey:kConferenceName];
    [mutableDict setValue:[NSNumber numberWithInt:self.leagueId] forKey:kConferenceLeagueId];

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

    self.shortName = [aDecoder decodeObjectForKey:kConferenceShortName];
    self.conferenceId = [aDecoder decodeIntForKey:kConferenceId];
    self.active = [aDecoder decodeBoolForKey:kConferenceActive];
    self.name = [aDecoder decodeObjectForKey:kConferenceName];
    self.leagueId = [aDecoder decodeIntForKey:kConferenceLeagueId];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_shortName forKey:kConferenceShortName];
    [aCoder encodeInt:_conferenceId forKey:kConferenceId];
    [aCoder encodeBool:_active forKey:kConferenceActive];
    [aCoder encodeObject:_name forKey:kConferenceName];
    [aCoder encodeInt:_leagueId forKey:kConferenceLeagueId];
}


@end
