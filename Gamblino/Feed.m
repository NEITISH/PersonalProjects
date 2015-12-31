//
//  Feed.m
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"
#import "Contest.h"
#import "User.h"
#import "Pool.h"

NSString *const kFeedOwner = @"owner";
NSString *const kFeedUser = @"user";
NSString *const kFeedAction = @"action";
NSString *const kFeedId = @"id";
NSString *const kFeedCreatedAt = @"created_at";
NSString *const kFeedOrder = @"order";
NSString *const kFeedContest = @"contest";
NSString *const kFeedContext = @"context";
NSString *const kFeedUserId = @"user_id";
NSString *const kFeedContextId = @"context_id";
NSString *const kFeedUpdatedAt = @"updated_at";
NSString *const kFeedPool = @"pool";

@interface Feed ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Feed

@synthesize owner = _owner;
@synthesize user = _user;
@synthesize action = _action;
@synthesize internalBaseClassIdentifier = _internalBaseClassIdentifier;
@synthesize createdAt = _createdAt;
@synthesize order = _order;
@synthesize contest = _contest;
@synthesize context = _context;
@synthesize userId = _userId;
@synthesize contextId = _contextId;
@synthesize updatedAt = _updatedAt;
@synthesize pool = _pool;

+ (Feed *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Feed *instance = [[Feed alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.user = [User modelObjectWithDictionary:[dict objectForKey:kFeedUser]];
            self.owner = [User modelObjectWithDictionary:[dict objectForKey:kFeedOwner]];
            self.action = [self objectOrNilForKey:kFeedAction fromDictionary:dict];
            self.internalBaseClassIdentifier = [self objectOrNilForKey:kFeedId fromDictionary:dict];
            self.createdAt = [self objectOrNilForKey:kFeedCreatedAt fromDictionary:dict];
            self.order = [[self objectOrNilForKey:kFeedOrder fromDictionary:dict] doubleValue];
            self.contest = [Contest modelObjectWithDictionary:[dict objectForKey:kFeedContest]];
            self.context = [self objectOrNilForKey:kFeedContext fromDictionary:dict];
            self.userId = [[self objectOrNilForKey:kFeedUserId fromDictionary:dict] doubleValue];
            self.contextId = [[self objectOrNilForKey:kFeedContextId fromDictionary:dict] doubleValue];
            self.updatedAt = [self objectOrNilForKey:kFeedUpdatedAt fromDictionary:dict];
        self.pool = [Pool modelObjectWithDictionary:[dict objectForKey:kFeedPool]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.user dictionaryRepresentation] forKey:kFeedUser];
    [mutableDict setValue:[self.owner dictionaryRepresentation] forKey:kFeedOwner];
    [mutableDict setValue:self.action forKey:kFeedAction];
    [mutableDict setValue:self.internalBaseClassIdentifier forKey:kFeedId];
    [mutableDict setValue:self.createdAt forKey:kFeedCreatedAt];
    [mutableDict setValue:[NSNumber numberWithDouble:self.order] forKey:kFeedOrder];
    [mutableDict setValue:[self.contest dictionaryRepresentation] forKey:kFeedContest];
    [mutableDict setValue:self.context forKey:kFeedContext];
    [mutableDict setValue:[NSNumber numberWithDouble:self.userId] forKey:kFeedUserId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.contextId] forKey:kFeedContextId];
    [mutableDict setValue:self.updatedAt forKey:kFeedUpdatedAt];
    [mutableDict setValue:[self.pool dictionaryRepresentation] forKey:kFeedPool];

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
    self.user = [aDecoder decodeObjectForKey:kFeedUser];
    self.owner = [aDecoder decodeObjectForKey:kFeedOwner];
    self.action = [aDecoder decodeObjectForKey:kFeedAction];
    self.internalBaseClassIdentifier = [aDecoder decodeObjectForKey:kFeedId];
    self.createdAt = [aDecoder decodeObjectForKey:kFeedCreatedAt];
    self.order = [aDecoder decodeDoubleForKey:kFeedOrder];
    self.contest = [aDecoder decodeObjectForKey:kFeedContest];
    self.context = [aDecoder decodeObjectForKey:kFeedContext];
    self.userId = [aDecoder decodeDoubleForKey:kFeedUserId];
    self.contextId = [aDecoder decodeDoubleForKey:kFeedContextId];
    self.updatedAt = [aDecoder decodeObjectForKey:kFeedUpdatedAt];
    self.pool = [aDecoder decodeObjectForKey:kFeedPool];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_user forKey:kFeedUser];
    [aCoder encodeObject:_owner forKey:kFeedOwner];
    [aCoder encodeObject:_action forKey:kFeedAction];
    [aCoder encodeObject:_internalBaseClassIdentifier forKey:kFeedId];
    [aCoder encodeObject:_createdAt forKey:kFeedCreatedAt];
    [aCoder encodeDouble:_order forKey:kFeedOrder];
    [aCoder encodeObject:_contest forKey:kFeedContest];
    [aCoder encodeObject:_context forKey:kFeedContext];
    [aCoder encodeDouble:_userId forKey:kFeedUserId];
    [aCoder encodeDouble:_contextId forKey:kFeedContextId];
    [aCoder encodeObject:_updatedAt forKey:kFeedUpdatedAt];
    [aCoder encodeObject:_pool forKey:kFeedPool];
}


@end
