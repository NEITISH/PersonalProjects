//
//  Leagues.m
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "League.h"
#import "Pivot.h"


NSString *const kLeaguesShortName = @"short_name";
NSString *const kLeaguesId = @"id";
NSString *const kLeaguesActive = @"active";
NSString *const kLeaguesCustom = @"custom";
NSString *const kLeaguesNickname = @"nickname";
NSString *const kLeaguesName = @"name";
NSString *const kLeaguesPivot = @"pivot";


@interface League ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation League

@synthesize shortName = _shortName;
@synthesize leaguesIdentifier = _leaguesIdentifier;
@synthesize active = _active;
@synthesize custom = _custom;
@synthesize nickname = _nickname;
@synthesize name = _name;
@synthesize pivot = _pivot;


+ (League *)modelObjectWithDictionary:(NSDictionary *)dict
{
    League *instance = [[League alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.shortName = [self objectOrNilForKey:kLeaguesShortName fromDictionary:dict];
            self.leaguesIdentifier = [[self objectOrNilForKey:kLeaguesId fromDictionary:dict] intValue];
            self.active = [[self objectOrNilForKey:kLeaguesActive fromDictionary:dict] boolValue];
            self.custom = [[self objectOrNilForKey:kLeaguesCustom fromDictionary:dict] boolValue];
            self.nickname = [self objectOrNilForKey:kLeaguesNickname fromDictionary:dict];
            self.name = [self objectOrNilForKey:kLeaguesName fromDictionary:dict];
            self.pivot = [Pivot modelObjectWithDictionary:[dict objectForKey:kLeaguesPivot]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.shortName forKey:kLeaguesShortName];
    [mutableDict setValue:[NSNumber numberWithInt:self.leaguesIdentifier] forKey:kLeaguesId];
    [mutableDict setValue:[NSNumber numberWithBool:self.active] forKey:kLeaguesActive];
    [mutableDict setValue:[NSNumber numberWithBool:self.custom] forKey:kLeaguesCustom];
    [mutableDict setValue:self.nickname forKey:kLeaguesNickname];
    [mutableDict setValue:self.name forKey:kLeaguesName];
    [mutableDict setValue:[self.pivot dictionaryRepresentation] forKey:kLeaguesPivot];

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

    self.shortName = [aDecoder decodeObjectForKey:kLeaguesShortName];
    self.leaguesIdentifier = [aDecoder decodeIntForKey:kLeaguesId];
    self.active = [aDecoder decodeBoolForKey:kLeaguesActive];
    self.custom = [aDecoder decodeBoolForKey:kLeaguesCustom];
    self.nickname = [aDecoder decodeObjectForKey:kLeaguesNickname];
    self.name = [aDecoder decodeObjectForKey:kLeaguesName];
    self.pivot = [aDecoder decodeObjectForKey:kLeaguesPivot];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_shortName forKey:kLeaguesShortName];
    [aCoder encodeInt:_leaguesIdentifier forKey:kLeaguesId];
    [aCoder encodeBool:_active forKey:kLeaguesActive];
    [aCoder encodeBool:_custom forKey:kLeaguesCustom];
    [aCoder encodeObject:_nickname forKey:kLeaguesNickname];
    [aCoder encodeObject:_name forKey:kLeaguesName];
    [aCoder encodeObject:_pivot forKey:kLeaguesPivot];
}


@end
