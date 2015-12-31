//
//  Prize.h
//
//  Created by   on 1/21/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Prize : NSObject <NSCoding>

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *redeemableUntil;
@property (nonatomic, assign) int contestId;
@property (nonatomic, assign) int prizeIdentifier;
@property (nonatomic, strong) NSString *redeemableMessage;
@property (nonatomic, strong) NSString *redeemOn;
@property (nonatomic, assign) BOOL redeemed;
@property (nonatomic, assign) BOOL redeemable;
@property (nonatomic, strong) NSString *prizeDescription;
@property (nonatomic, assign) int place;
@property (nonatomic, strong) NSString *awardAt;

+ (Prize *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
