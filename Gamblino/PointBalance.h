//
//  Points.h
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface PointBalance : NSObject <NSCoding>

@property (nonatomic, strong) NSString *pointsIdentifier;
@property (nonatomic, assign) double userId;
@property (nonatomic, assign) double contestId;
@property (nonatomic, assign) double balance;
@property (nonatomic, assign) double available;

+ (PointBalance *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
