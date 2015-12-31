//
//  Notification.m
//
//  Created by   on 1/21/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "Notification.h"
#import "User.h"
#import "Prize.h"
#import "Contest.h"
#import "Pool.h"

NSString *const kNotificationAction = @"action";
NSString *const kNotificationFriend = @"friend";
NSString *const kNotificationPrize = @"prize";
NSString *const kNotificationId = @"id";
NSString *const kNotificationCreatedAt = @"created_at";
NSString *const kNotificationContext = @"context";
NSString *const kNotificationContest = @"contest";
NSString *const kNotificationPool = @"pool";
NSString *const kNotificationRead = @"read";
NSString *const kNotificationUserId = @"user_id";
NSString *const kNotificationContextId = @"context_id";
NSString *const kNotificationMessage = @"message";


@interface Notification ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Notification

@synthesize action = _action;
@synthesize friend = _friend;
@synthesize prize = _prize;
@synthesize notificationIdentifier = _notificationIdentifier;
@synthesize createdAt = _createdAt;
@synthesize context = _context;
@synthesize contest = _contest;
@synthesize pool = _pool;
@synthesize read = _read;
@synthesize userId = _userId;
@synthesize contextId = _contextId;
@synthesize message = _message;


+ (Notification *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Notification *instance = [[Notification alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.action = [self objectOrNilForKey:kNotificationAction fromDictionary:dict];
            self.friend = [User modelObjectWithDictionary:[dict objectForKey:kNotificationFriend]];
            self.prize = [Prize modelObjectWithDictionary:[dict objectForKey:kNotificationPrize]];
            self.notificationIdentifier = [[self objectOrNilForKey:kNotificationId fromDictionary:dict] intValue];
            self.createdAt = [self objectOrNilForKey:kNotificationCreatedAt fromDictionary:dict];
            self.context = [self objectOrNilForKey:kNotificationContext fromDictionary:dict];
            self.contest = [Contest modelObjectWithDictionary:[dict objectForKey:kNotificationContest]];
        self.pool = [Pool modelObjectWithDictionary:[dict objectForKey:kNotificationPool]];
            self.read = [[self objectOrNilForKey:kNotificationRead fromDictionary:dict] boolValue];
            self.userId = [[self objectOrNilForKey:kNotificationUserId fromDictionary:dict] intValue];
            self.contextId = [[self objectOrNilForKey:kNotificationContextId fromDictionary:dict] intValue];
            self.message = [self objectOrNilForKey:kNotificationMessage fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.action forKey:kNotificationAction];
    [mutableDict setValue:[self.friend dictionaryRepresentation] forKey:kNotificationFriend];
    [mutableDict setValue:[self.prize dictionaryRepresentation] forKey:kNotificationPrize];
    [mutableDict setValue:[NSNumber numberWithInt:self.notificationIdentifier] forKey:kNotificationId];
    [mutableDict setValue:self.createdAt forKey:kNotificationCreatedAt];
    [mutableDict setValue:self.context forKey:kNotificationContext];
    [mutableDict setValue:[self.contest dictionaryRepresentation] forKey:kNotificationContest];
    [mutableDict setValue:[self.pool dictionaryRepresentation] forKey:kNotificationPool];
    [mutableDict setValue:[NSNumber numberWithBool:self.read] forKey:kNotificationRead];
    [mutableDict setValue:[NSNumber numberWithInt:self.userId] forKey:kNotificationUserId];
    [mutableDict setValue:[NSNumber numberWithInt:self.contextId] forKey:kNotificationContextId];
    [mutableDict setValue:self.message forKey:kNotificationMessage];

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

    self.action = [aDecoder decodeObjectForKey:kNotificationAction];
    self.friend = [aDecoder decodeObjectForKey:kNotificationFriend];
    self.prize = [aDecoder decodeObjectForKey:kNotificationPrize];
    self.notificationIdentifier = [aDecoder decodeIntForKey:kNotificationId];
    self.createdAt = [aDecoder decodeObjectForKey:kNotificationCreatedAt];
    self.context = [aDecoder decodeObjectForKey:kNotificationContext];
    self.contest = [aDecoder decodeObjectForKey:kNotificationContest];
    self.pool = [aDecoder decodeObjectForKey:kNotificationPool];
    self.read = [aDecoder decodeBoolForKey:kNotificationRead];
    self.userId = [aDecoder decodeIntForKey:kNotificationUserId];
    self.contextId = [aDecoder decodeIntForKey:kNotificationContextId];
    self.message = [aDecoder decodeObjectForKey:kNotificationMessage];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_action forKey:kNotificationAction];
    [aCoder encodeObject:_friend forKey:kNotificationFriend];
    [aCoder encodeObject:_prize forKey:kNotificationPrize];
    [aCoder encodeInt:_notificationIdentifier forKey:kNotificationId];
    [aCoder encodeObject:_createdAt forKey:kNotificationCreatedAt];
    [aCoder encodeObject:_context forKey:kNotificationContext];
    [aCoder encodeObject:_contest forKey:kNotificationContest];
    [aCoder encodeObject:_pool forKey:kNotificationPool];
    [aCoder encodeBool:_read forKey:kNotificationRead];
    [aCoder encodeInt:_userId forKey:kNotificationUserId];
    [aCoder encodeInt:_contextId forKey:kNotificationContextId];
    [aCoder encodeObject:_message forKey:kNotificationMessage];
}


@end
