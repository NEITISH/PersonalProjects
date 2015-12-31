//
//  PoolType.m
//
//  Created by   on 3/15/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "PoolType.h"
#import "League.h"


NSString *const kPoolTypeId = @"id";
NSString *const kPoolTypeLeagues = @"leagues";
NSString *const kPoolTypeDescription = @"description";
NSString *const kPoolTypeSubtitle = @"subtitle";
NSString *const kPoolTypeTitle = @"title";
NSString *const kPoolTypeStartAt = @"start_at";
NSString *const kPoolTypeImage = @"picture_url";
NSString *const kPoolTypeMaxWager = @"max_wager";
NSString *const kPoolTypeOrder = @"order";
NSString *const kPoolTypeActiveAt = @"active_at";
NSString *const kPoolTypeImageIcon = @"image_icon";
NSString *const kPoolTypeEndsAt = @"ends_at";
NSString *const kPoolTypeStartingWallet = @"starting_wallet";
NSString *const kPoolTypeBackgroundImage = @"background_image_url";



@interface PoolType ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation PoolType

@synthesize poolTypeIdentifier = _poolTypeIdentifier;
@synthesize leagues = _leagues;
@synthesize poolTypeDescription = _poolTypeDescription;
@synthesize subtitle = _subtitle;
@synthesize title = _title;
@synthesize startAt = _startAt;
@synthesize image = _image;
@synthesize maxWager = _maxWager;
@synthesize order = _order;
@synthesize activeAt = _activeAt;
@synthesize imageIcon = _imageIcon;
@synthesize endsAt = _endsAt;
@synthesize startingWallet = _startingWallet;
@synthesize background_image = _background_image;

+ (PoolType *)modelObjectWithDictionary:(NSDictionary *)dict
{
    PoolType *instance = [[PoolType alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.poolTypeIdentifier = [[self objectOrNilForKey:kPoolTypeId fromDictionary:dict] intValue];
    NSObject *receivedLeagues = [dict objectForKey:kPoolTypeLeagues];
    NSMutableArray *parsedLeagues = [NSMutableArray array];
    if ([receivedLeagues isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedLeagues) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedLeagues addObject:[League modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedLeagues isKindOfClass:[NSDictionary class]]) {
       [parsedLeagues addObject:[League modelObjectWithDictionary:(NSDictionary *)receivedLeagues]];
    }

    self.leagues = [NSArray arrayWithArray:parsedLeagues];
            self.poolTypeDescription = [self objectOrNilForKey:kPoolTypeDescription fromDictionary:dict];
            self.subtitle = [self objectOrNilForKey:kPoolTypeSubtitle fromDictionary:dict];
            self.title = [self objectOrNilForKey:kPoolTypeTitle fromDictionary:dict];
            self.startAt = [self objectOrNilForKey:kPoolTypeStartAt fromDictionary:dict];
            self.image = [self objectOrNilForKey:kPoolTypeImage fromDictionary:dict];
            self.maxWager = [[self objectOrNilForKey:kPoolTypeMaxWager fromDictionary:dict] intValue];
            self.order = [[self objectOrNilForKey:kPoolTypeOrder fromDictionary:dict] intValue];
            self.activeAt = [self objectOrNilForKey:kPoolTypeActiveAt fromDictionary:dict];
            self.imageIcon = [self objectOrNilForKey:kPoolTypeImageIcon fromDictionary:dict];
            self.endsAt = [self objectOrNilForKey:kPoolTypeEndsAt fromDictionary:dict];
            self.startingWallet = [[self objectOrNilForKey:kPoolTypeStartingWallet fromDictionary:dict] intValue];
            self.background_image = [self objectOrNilForKey:kPoolTypeBackgroundImage fromDictionary:dict];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithInt:self.poolTypeIdentifier] forKey:kPoolTypeId];
NSMutableArray *tempArrayForLeagues = [NSMutableArray array];
    for (NSObject *subArrayObject in self.leagues) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLeagues addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLeagues addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLeagues] forKey:@"kPoolTypeLeagues"];
    [mutableDict setValue:self.poolTypeDescription forKey:kPoolTypeDescription];
    [mutableDict setValue:self.subtitle forKey:kPoolTypeSubtitle];
    [mutableDict setValue:self.title forKey:kPoolTypeTitle];
    [mutableDict setValue:self.startAt forKey:kPoolTypeStartAt];
    [mutableDict setValue:self.image forKey:kPoolTypeImage];
    [mutableDict setValue:[NSNumber numberWithInt:self.maxWager] forKey:kPoolTypeMaxWager];
    [mutableDict setValue:[NSNumber numberWithInt:self.order] forKey:kPoolTypeOrder];
    [mutableDict setValue:self.activeAt forKey:kPoolTypeActiveAt];
    [mutableDict setValue:self.imageIcon forKey:kPoolTypeImageIcon];
    [mutableDict setValue:self.endsAt forKey:kPoolTypeEndsAt];
    [mutableDict setValue:[NSNumber numberWithInt:self.startingWallet] forKey:kPoolTypeStartingWallet];
    [mutableDict setValue:self.background_image forKey:kPoolTypeBackgroundImage];

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

    self.poolTypeIdentifier = [aDecoder decodeIntForKey:kPoolTypeId];
    self.leagues = [aDecoder decodeObjectForKey:kPoolTypeLeagues];
    self.poolTypeDescription = [aDecoder decodeObjectForKey:kPoolTypeDescription];
    self.subtitle = [aDecoder decodeObjectForKey:kPoolTypeSubtitle];
    self.title = [aDecoder decodeObjectForKey:kPoolTypeTitle];
    self.startAt = [aDecoder decodeObjectForKey:kPoolTypeStartAt];
    self.image = [aDecoder decodeObjectForKey:kPoolTypeImage];
    self.maxWager = [aDecoder decodeIntForKey:kPoolTypeMaxWager];
    self.order = [aDecoder decodeIntForKey:kPoolTypeOrder];
    self.activeAt = [aDecoder decodeObjectForKey:kPoolTypeActiveAt];
    self.imageIcon = [aDecoder decodeObjectForKey:kPoolTypeImageIcon];
    self.endsAt = [aDecoder decodeObjectForKey:kPoolTypeEndsAt];
    self.background_image = [aDecoder decodeObjectForKey:kPoolTypeBackgroundImage];
    self.startingWallet = [aDecoder decodeIntForKey:kPoolTypeStartingWallet];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeInt:_poolTypeIdentifier forKey:kPoolTypeId];
    [aCoder encodeObject:_leagues forKey:kPoolTypeLeagues];
    [aCoder encodeObject:_poolTypeDescription forKey:kPoolTypeDescription];
    [aCoder encodeObject:_subtitle forKey:kPoolTypeSubtitle];
    [aCoder encodeObject:_title forKey:kPoolTypeTitle];
    [aCoder encodeObject:_startAt forKey:kPoolTypeStartAt];
    [aCoder encodeObject:_image forKey:kPoolTypeImage];
    [aCoder encodeInt:_maxWager forKey:kPoolTypeMaxWager];
    [aCoder encodeInt:_order forKey:kPoolTypeOrder];
    [aCoder encodeObject:_activeAt forKey:kPoolTypeActiveAt];
    [aCoder encodeObject:_imageIcon forKey:kPoolTypeImageIcon];
    [aCoder encodeObject:_endsAt forKey:kPoolTypeEndsAt];
    [aCoder encodeObject:_background_image forKey:kPoolTypeBackgroundImage];
    [aCoder encodeInt:_startingWallet forKey:kPoolTypeStartingWallet];
}


@end
