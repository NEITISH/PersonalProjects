//
//  Feed.h
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, Contest, Pool;

@interface Feed : NSObject <NSCoding>

@property (nonatomic, strong) User *owner;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *internalBaseClassIdentifier;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, assign) double order;
@property (nonatomic, strong) Contest *contest;
@property (nonatomic, strong) NSString *context;
@property (nonatomic, assign) double userId;
@property (nonatomic, assign) double contextId;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) Pool *pool;

+ (Feed *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
