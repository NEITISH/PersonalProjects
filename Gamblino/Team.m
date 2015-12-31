//
//  Team.m
//
//  Created by   on 12/12/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Team.h"


NSString *const kTeamCity = @"city";
NSString *const kTeamColor = @"color";
NSString *const kTeamId = @"id";
NSString *const kTeamNickname = @"nickname";
NSString *const kTeamLargeImage = @"large_image";
NSString *const kTeamLeagueId = @"league_id";
NSString *const kTeamConferenceId = @"conference_id";
NSString *const kTeamShortName = @"short_name";
NSString *const kTeamImage = @"image";
NSString *const kTeamDisplay = @"display";
NSString *const kTeamName = @"name";
NSString *const kTeamDisplayName = @"display_name";


@interface Team ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Team

@synthesize city = _city;
@synthesize color = _color;
@synthesize teamIdentifier = _teamIdentifier;
@synthesize nickname = _nickname;
@synthesize teamLargeImage = _teamLargeImage;
@synthesize leagueId = _leagueId;
@synthesize conferenceId = _conferenceId;
@synthesize shortName = _shortName;
@synthesize image = _image;
@synthesize display = _display;
@synthesize name = _name;
@synthesize displayName = _displayName;


+ (Team *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Team *instance = [[Team alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.city = [self objectOrNilForKey:kTeamCity fromDictionary:dict];
            self.color = [self objectOrNilForKey:kTeamColor fromDictionary:dict];
            self.teamIdentifier = [[self objectOrNilForKey:kTeamId fromDictionary:dict] intValue];
            self.nickname = [self objectOrNilForKey:kTeamNickname fromDictionary:dict];
            self.teamLargeImage = [self objectOrNilForKey:kTeamLargeImage fromDictionary:dict];
            self.leagueId = [[self objectOrNilForKey:kTeamLeagueId fromDictionary:dict] intValue];
            self.conferenceId = [[self objectOrNilForKey:kTeamConferenceId fromDictionary:dict] intValue];
            self.shortName = [self objectOrNilForKey:kTeamShortName fromDictionary:dict];
            self.image = [self objectOrNilForKey:kTeamImage fromDictionary:dict];
            self.display = [[self objectOrNilForKey:kTeamDisplay fromDictionary:dict] boolValue];
            self.name = [self objectOrNilForKey:kTeamName fromDictionary:dict];
        self.displayName = [self objectOrNilForKey:kTeamDisplayName fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.city forKey:kTeamCity];
    [mutableDict setValue:self.color forKey:kTeamColor];
    [mutableDict setValue:[NSNumber numberWithInt:self.teamIdentifier] forKey:kTeamId];
    [mutableDict setValue:self.nickname forKey:kTeamNickname];
    [mutableDict setValue:self.teamLargeImage forKey:kTeamLargeImage];
    [mutableDict setValue:[NSNumber numberWithInt:self.leagueId] forKey:kTeamLeagueId];
    [mutableDict setValue:[NSNumber numberWithInt:self.conferenceId] forKey:kTeamConferenceId];
    [mutableDict setValue:self.shortName forKey:kTeamShortName];
    [mutableDict setValue:self.image forKey:kTeamImage];
    [mutableDict setValue:[NSNumber numberWithBool:self.display] forKey:kTeamDisplay];
    [mutableDict setValue:self.name forKey:kTeamName];
    [mutableDict setValue:self.displayName forKey:kTeamDisplayName];

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

    self.city = [aDecoder decodeObjectForKey:kTeamCity];
    self.color = [aDecoder decodeObjectForKey:kTeamColor];
    self.teamIdentifier = [aDecoder decodeIntForKey:kTeamId];
    self.nickname = [aDecoder decodeObjectForKey:kTeamNickname];
    self.teamLargeImage = [aDecoder decodeObjectForKey:kTeamLargeImage];
    self.leagueId = [aDecoder decodeIntForKey:kTeamLeagueId];
    self.conferenceId = [aDecoder decodeIntForKey:kTeamConferenceId];
    self.shortName = [aDecoder decodeObjectForKey:kTeamShortName];
    self.image = [aDecoder decodeObjectForKey:kTeamImage];
    self.display = [aDecoder decodeBoolForKey:kTeamDisplay];
    self.name = [aDecoder decodeObjectForKey:kTeamName];
    self.displayName = [aDecoder decodeObjectForKey:kTeamDisplayName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_city forKey:kTeamCity];
    [aCoder encodeObject:_color forKey:kTeamColor];
    [aCoder encodeInt:_teamIdentifier forKey:kTeamId];
    [aCoder encodeObject:_nickname forKey:kTeamNickname];
    [aCoder encodeObject:_teamLargeImage forKey:kTeamLargeImage];
    [aCoder encodeInt:_leagueId forKey:kTeamLeagueId];
    [aCoder encodeInt:_conferenceId forKey:kTeamConferenceId];
    [aCoder encodeObject:_shortName forKey:kTeamShortName];
    [aCoder encodeObject:_image forKey:kTeamImage];
    [aCoder encodeBool:_display forKey:kTeamDisplay];
    [aCoder encodeObject:_name forKey:kTeamName];
    [aCoder encodeObject:_displayName forKey:kTeamDisplayName];
}


@end
