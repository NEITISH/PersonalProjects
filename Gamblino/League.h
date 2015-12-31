//
//  Leagues.h
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Pivot;

@interface League : NSObject <NSCoding>

@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, assign) int leaguesIdentifier;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL custom;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Pivot *pivot;

+ (League *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
