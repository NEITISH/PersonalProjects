//
//  Prize.m
//
//  Created by   on 1/21/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "Prize.h"


NSString *const kPrizeStatus = @"status";
NSString *const kPrizeRedeemableUntil = @"redeemable_until";
NSString *const kPrizeContestId = @"contest_id";
NSString *const kPrizeId = @"id";
NSString *const kPrizeRedeemableMessage = @"redeemable_message";
NSString *const kPrizeRedeemOn = @"redeem_on";
NSString *const kPrizeRedeemed = @"redeemed";
NSString *const kPrizeRedeemable = @"redeemable";
NSString *const kPrizeDescription = @"description";
NSString *const kPrizePlace = @"place";
NSString *const kPrizeAwardAt = @"award_at";


@interface Prize ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Prize

@synthesize status = _status;
@synthesize redeemableUntil = _redeemableUntil;
@synthesize contestId = _contestId;
@synthesize prizeIdentifier = _prizeIdentifier;
@synthesize redeemableMessage = _redeemableMessage;
@synthesize redeemOn = _redeemOn;
@synthesize redeemed = _redeemed;
@synthesize redeemable = _redeemable;
@synthesize prizeDescription = _prizeDescription;
@synthesize place = _place;
@synthesize awardAt = _awardAt;


+ (Prize *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Prize *instance = [[Prize alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.status = [self objectOrNilForKey:kPrizeStatus fromDictionary:dict];
            self.redeemableUntil = [self objectOrNilForKey:kPrizeRedeemableUntil fromDictionary:dict];
            self.contestId = [[self objectOrNilForKey:kPrizeContestId fromDictionary:dict] intValue];
            self.prizeIdentifier = [[self objectOrNilForKey:kPrizeId fromDictionary:dict] intValue];
            self.redeemableMessage = [self objectOrNilForKey:kPrizeRedeemableMessage fromDictionary:dict];
            self.redeemOn = [self objectOrNilForKey:kPrizeRedeemOn fromDictionary:dict];
            self.redeemed = [[self objectOrNilForKey:kPrizeRedeemed fromDictionary:dict] boolValue];
            self.redeemable = [[self objectOrNilForKey:kPrizeRedeemable fromDictionary:dict] boolValue];
            self.prizeDescription = [self objectOrNilForKey:kPrizeDescription fromDictionary:dict];
            self.place = [[self objectOrNilForKey:kPrizePlace fromDictionary:dict] intValue];
            self.awardAt = [self objectOrNilForKey:kPrizeAwardAt fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.status forKey:kPrizeStatus];
    [mutableDict setValue:self.redeemableUntil forKey:kPrizeRedeemableUntil];
    [mutableDict setValue:[NSNumber numberWithInt:self.contestId] forKey:kPrizeContestId];
    [mutableDict setValue:[NSNumber numberWithInt:self.prizeIdentifier] forKey:kPrizeId];
    [mutableDict setValue:self.redeemableMessage forKey:kPrizeRedeemableMessage];
    [mutableDict setValue:self.redeemOn forKey:kPrizeRedeemOn];
    [mutableDict setValue:[NSNumber numberWithBool:self.redeemed] forKey:kPrizeRedeemed];
    [mutableDict setValue:[NSNumber numberWithBool:self.redeemable] forKey:kPrizeRedeemable];
    [mutableDict setValue:self.prizeDescription forKey:kPrizeDescription];
    [mutableDict setValue:[NSNumber numberWithInt:self.place] forKey:kPrizePlace];
    [mutableDict setValue:self.awardAt forKey:kPrizeAwardAt];

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

    self.status = [aDecoder decodeObjectForKey:kPrizeStatus];
    self.redeemableUntil = [aDecoder decodeObjectForKey:kPrizeRedeemableUntil];
    self.contestId = [aDecoder decodeIntForKey:kPrizeContestId];
    self.prizeIdentifier = [aDecoder decodeIntForKey:kPrizeId];
    self.redeemableMessage = [aDecoder decodeObjectForKey:kPrizeRedeemableMessage];
    self.redeemOn = [aDecoder decodeObjectForKey:kPrizeRedeemOn];
    self.redeemed = [aDecoder decodeBoolForKey:kPrizeRedeemed];
    self.redeemable = [aDecoder decodeBoolForKey:kPrizeRedeemable];
    self.prizeDescription = [aDecoder decodeObjectForKey:kPrizeDescription];
    self.place = [aDecoder decodeIntForKey:kPrizePlace];
    self.awardAt = [aDecoder decodeObjectForKey:kPrizeAwardAt];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_status forKey:kPrizeStatus];
    [aCoder encodeObject:_redeemableUntil forKey:kPrizeRedeemableUntil];
    [aCoder encodeInt:_contestId forKey:kPrizeContestId];
    [aCoder encodeInt:_prizeIdentifier forKey:kPrizeId];
    [aCoder encodeObject:_redeemableMessage forKey:kPrizeRedeemableMessage];
    [aCoder encodeObject:_redeemOn forKey:kPrizeRedeemOn];
    [aCoder encodeBool:_redeemed forKey:kPrizeRedeemed];
    [aCoder encodeBool:_redeemable forKey:kPrizeRedeemable];
    [aCoder encodeObject:_prizeDescription forKey:kPrizeDescription];
    [aCoder encodeInt:_place forKey:kPrizePlace];
    [aCoder encodeObject:_awardAt forKey:kPrizeAwardAt];
}


@end
