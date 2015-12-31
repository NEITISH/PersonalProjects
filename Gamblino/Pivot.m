//
//  Pivot.m
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Pivot.h"


NSString *const kPivotUserId = @"user_id";
NSString *const kPivotLeagueId = @"league_id";
NSString *const kPivotContestId = @"contest_id";


@interface Pivot ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Pivot

@synthesize userId = _userId;
@synthesize leagueId = _leagueId;
@synthesize contestId = _contestId;


+ (Pivot *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Pivot *instance = [[Pivot alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.userId = [[self objectOrNilForKey:kPivotUserId fromDictionary:dict] doubleValue];
            self.leagueId = [[self objectOrNilForKey:kPivotLeagueId fromDictionary:dict] doubleValue];
            self.contestId = [[self objectOrNilForKey:kPivotContestId fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.userId] forKey:kPivotUserId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.leagueId] forKey:kPivotLeagueId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.contestId] forKey:kPivotContestId];

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

    self.userId = [aDecoder decodeDoubleForKey:kPivotUserId];
    self.leagueId = [aDecoder decodeDoubleForKey:kPivotLeagueId];
    self.contestId = [aDecoder decodeDoubleForKey:kPivotContestId];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_userId forKey:kPivotUserId];
    [aCoder encodeDouble:_leagueId forKey:kPivotLeagueId];
    [aCoder encodeDouble:_contestId forKey:kPivotContestId];
}


@end
