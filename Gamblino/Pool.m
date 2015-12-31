//
//  Pool.m
//
//  Created by   on 3/15/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "Pool.h"
#import "PoolType.h"
#import "User.h"


NSString *const kPoolId = @"id";
NSString *const kPoolPoolType = @"pool_type";
NSString *const kPoolTitle = @"title";
NSString *const kPoolPoolTypeId = @"pool_type_id";
NSString *const kPoolImage = @"image";
NSString *const kPoolUserId = @"user_id";
NSString *const kPoolLeaderboard = @"leaderboard";
NSString *const kPoolJoined = @"joined";
NSString *const kPoolTotalUsers = @"total_users";
NSString *const kPoolCreator = @"creator";
NSString *const kPoolLeader = @"leader";
NSString *const kPoolMe = @"me";
NSString *const kPoollanding_page=@"landing_page";
NSString *const kPoolShareable=@"shareable";

@interface Pool ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Pool

@synthesize poolIdentifier = _poolIdentifier;
@synthesize poolType = _poolType;
@synthesize title = _title;
@synthesize poolTypeId = _poolTypeId;
@synthesize image = _image;
@synthesize userId = _userId;
@synthesize leaderboard = _leaderboard;
@synthesize joined = _joined;
@synthesize totalUsers = _totalUsers;
@synthesize creator = _creator;
@synthesize leader = _leader;
@synthesize me = _me;
@synthesize landingpage = _landingPage;
@synthesize Shareable = _Shareable;

+ (Pool *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Pool *instance = [[Pool alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.poolIdentifier = [[self objectOrNilForKey:kPoolId fromDictionary:dict] intValue];
        self.poolType = [PoolType modelObjectWithDictionary:[dict objectForKey:kPoolPoolType]];
        self.title = [self objectOrNilForKey:kPoolTitle fromDictionary:dict];
        self.landingpage = [self objectOrNilForKey:kPoollanding_page fromDictionary:dict];
        self.Shareable = [self objectOrNilForKey:kPoolShareable fromDictionary:dict];
        self.poolTypeId = [[self objectOrNilForKey:kPoolPoolTypeId fromDictionary:dict] intValue];
        self.image = [self objectOrNilForKey:kPoolImage fromDictionary:dict];
        self.userId = [[self objectOrNilForKey:kPoolUserId fromDictionary:dict] intValue];
        self.joined = [[self objectOrNilForKey:kPoolJoined fromDictionary:dict] boolValue];
        self.totalUsers = [[self objectOrNilForKey:kPoolTotalUsers fromDictionary:dict] intValue];
        self.creator = [User modelObjectWithDictionary:[dict objectForKey:kPoolCreator]];
        self.leader = [User modelObjectWithDictionary:[dict objectForKey:kPoolLeader]];
        self.me = [User modelObjectWithDictionary:[dict objectForKey:kPoolMe]];
        NSObject *receivedUsers = [dict objectForKey:kPoolLeaderboard];
        NSMutableArray *parsedUsers = [NSMutableArray array];
        if ([receivedUsers isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedUsers) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedUsers addObject:[User modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedUsers isKindOfClass:[NSDictionary class]]) {
            [parsedUsers addObject:[User modelObjectWithDictionary:(NSDictionary *)receivedUsers]];
        }
        
        self.leaderboard = [NSArray arrayWithArray:parsedUsers];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithInt:self.poolIdentifier] forKey:kPoolId];
    [mutableDict setValue:[self.poolType dictionaryRepresentation] forKey:kPoolPoolType];
    [mutableDict setValue:self.title forKey:kPoolTitle];
    [mutableDict setValue:self.landingpage forKey:kPoollanding_page];
    [mutableDict setValue:self.Shareable forKey:kPoolShareable];
    [mutableDict setValue:[NSNumber numberWithInt:self.poolTypeId] forKey:kPoolPoolTypeId];
    [mutableDict setValue:self.image forKey:kPoolImage];
    [mutableDict setValue:[NSNumber numberWithInt:self.userId] forKey:kPoolUserId];
    [mutableDict setValue:[NSNumber numberWithBool:self.joined] forKey:kPoolJoined];
    [mutableDict setValue:[NSNumber numberWithInt:self.totalUsers] forKey:kPoolTotalUsers];
    [mutableDict setValue:[self.creator dictionaryRepresentation] forKey:kPoolCreator];
    [mutableDict setValue:[self.leader dictionaryRepresentation] forKey:kPoolLeader];
    [mutableDict setValue:[self.me dictionaryRepresentation] forKey:kPoolMe];
    NSMutableArray *tempArrayForUsers = [NSMutableArray array];
    for (NSObject *subArrayObject in self.leaderboard) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForUsers addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForUsers addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForUsers] forKey:@"kPoolLeaderboard"];
    
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
    
    self.poolIdentifier = [aDecoder decodeIntForKey:kPoolId];
    self.poolType = [aDecoder decodeObjectForKey:kPoolPoolType];
    self.title = [aDecoder decodeObjectForKey:kPoolTitle];
    self.landingpage = [aDecoder decodeObjectForKey:kPoollanding_page];
    self.Shareable = [aDecoder decodeObjectForKey:kPoolShareable];
    self.poolTypeId = [aDecoder decodeIntForKey:kPoolPoolTypeId];
    self.image = [aDecoder decodeObjectForKey:kPoolImage];
    self.userId = [aDecoder decodeIntForKey:kPoolUserId];
    self.leaderboard = [aDecoder decodeObjectForKey:kPoolLeaderboard];
    self.joined = [aDecoder decodeBoolForKey:kPoolJoined];
    self.totalUsers = [aDecoder decodeIntForKey:kPoolTotalUsers];
    self.creator = [aDecoder decodeObjectForKey:kPoolCreator];
    self.leader = [aDecoder decodeObjectForKey:kPoolLeader];
    self.me = [aDecoder decodeObjectForKey:kPoolMe];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeDouble:_poolIdentifier forKey:kPoolId];
    [aCoder encodeObject:_poolType forKey:kPoolPoolType];
    [aCoder encodeObject:_title forKey:kPoolTitle];
    [aCoder encodeObject:_Shareable forKey:kPoolShareable];
    [aCoder encodeObject:_landingPage forKey:kPoollanding_page];
    [aCoder encodeDouble:_poolTypeId forKey:kPoolPoolTypeId];
    [aCoder encodeObject:_image forKey:kPoolImage];
    [aCoder encodeDouble:_userId forKey:kPoolUserId];
    [aCoder encodeObject:_leaderboard forKey:kPoolLeaderboard];
    [aCoder encodeBool:_joined forKey:kPoolJoined];
    [aCoder encodeInt:_totalUsers forKey:kPoolTotalUsers];
    [aCoder encodeObject:_creator forKey:kPoolCreator];
    [aCoder encodeObject:_leader forKey:kPoolLeader];
    [aCoder encodeObject:_me forKey:kPoolMe];
}


@end
