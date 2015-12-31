//
//  Notification.h
//
//  Created by   on 1/21/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, Prize, Contest, Pool;

@interface Notification : NSObject <NSCoding>

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) User *friend;
@property (nonatomic, strong) Prize *prize;
@property (nonatomic, assign) int notificationIdentifier;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *context;
@property (nonatomic, strong) Contest *contest;
@property (nonatomic, strong) Pool *pool;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int contextId;
@property (nonatomic, strong) NSString *message;

+ (Notification *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
