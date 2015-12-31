//
//  Pool.h
//
//  Created by   on 3/15/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PoolType,User;

@interface Pool : NSObject <NSCoding>

@property (nonatomic, assign) int poolIdentifier;
@property (nonatomic, strong) PoolType *poolType;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) int poolTypeId;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, assign) int userId;
@property (nonatomic, strong) NSArray *leaderboard;
@property (nonatomic, assign) BOOL joined;
@property (nonatomic, assign) int totalUsers;
@property (nonatomic, strong) User *creator;
@property (nonatomic, strong) User *leader;
@property (nonatomic, strong) User *me;
@property (nonatomic, strong) NSString *landingpage;
@property (nonatomic ,strong) NSString *Shareable;


+ (Pool *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
