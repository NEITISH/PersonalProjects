//
//  Wager.h
//
//  Created by   on 1/5/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Contest, Event, Team, User, Answer, Pool;

@interface Wager : NSObject <NSCoding>

@property (nonatomic, assign) int wagerIdentifier;
@property (nonatomic, assign) int points;
@property (nonatomic, strong) Contest *contest;
@property (nonatomic, assign) int amount;
@property (nonatomic, assign) id opponent;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) Event *customEvent;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, assign) double line;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Answer *answer;
@property (nonatomic, strong) Pool *pool;

+ (Wager *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
