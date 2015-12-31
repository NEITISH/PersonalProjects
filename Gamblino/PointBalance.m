//
//  Points.m
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PointBalance.h"


NSString *const kPointsId = @"id";
NSString *const kPointsUserId = @"user_id";
NSString *const kPointsContestId = @"contest_id";
NSString *const kPointsBalance = @"balance";
NSString *const kPointsAvailable = @"available";


@interface PointBalance ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation PointBalance

@synthesize pointsIdentifier = _pointsIdentifier;
@synthesize userId = _userId;
@synthesize contestId = _contestId;
@synthesize balance = _balance;
@synthesize available = _available;


+ (PointBalance *)modelObjectWithDictionary:(NSDictionary *)dict
{
    PointBalance *instance = [[PointBalance alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.pointsIdentifier = [self objectOrNilForKey:kPointsId fromDictionary:dict];
            self.userId = [[self objectOrNilForKey:kPointsUserId fromDictionary:dict] doubleValue];
            self.contestId = [[self objectOrNilForKey:kPointsContestId fromDictionary:dict] doubleValue];
            self.balance = [[self objectOrNilForKey:kPointsBalance fromDictionary:dict] doubleValue];
            self.available = [[self objectOrNilForKey:kPointsAvailable fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.pointsIdentifier forKey:kPointsId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.userId] forKey:kPointsUserId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.contestId] forKey:kPointsContestId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.balance] forKey:kPointsBalance];
    [mutableDict setValue:[NSNumber numberWithDouble:self.available] forKey:kPointsAvailable];

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

    self.pointsIdentifier = [aDecoder decodeObjectForKey:kPointsId];
    self.userId = [aDecoder decodeDoubleForKey:kPointsUserId];
    self.contestId = [aDecoder decodeDoubleForKey:kPointsContestId];
    self.balance = [aDecoder decodeDoubleForKey:kPointsBalance];
    self.available = [aDecoder decodeDoubleForKey:kPointsAvailable];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_pointsIdentifier forKey:kPointsId];
    [aCoder encodeDouble:_userId forKey:kPointsUserId];
    [aCoder encodeDouble:_contestId forKey:kPointsContestId];
    [aCoder encodeDouble:_balance forKey:kPointsBalance];
    [aCoder encodeDouble:_available forKey:kPointsAvailable];
}


@end
