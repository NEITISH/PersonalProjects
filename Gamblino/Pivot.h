//
//  Pivot.h
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Pivot : NSObject <NSCoding>

@property (nonatomic, assign) double userId;
@property (nonatomic, assign) double leagueId;
@property (nonatomic, assign) double contestId;

+ (Pivot *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
