//
//  Sponsor.m
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Sponsor.h"


NSString *const kSponsorAddress = @"address";
NSString *const kSponsorCity = @"city";
NSString *const kSponsorLongitude = @"longitude";
NSString *const kSponsorId = @"id";
NSString *const kSponsorZipcode = @"zipcode";
NSString *const kSponsorPicture = @"picture";
NSString *const kSponsorLatitude = @"latitude";
NSString *const kSponsorPictureUrl = @"picture_url";
NSString *const kSponsorName = @"name";
NSString *const kSponsorState = @"state";


@interface Sponsor ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Sponsor

@synthesize address = _address;
@synthesize city = _city;
@synthesize longitude = _longitude;
@synthesize sponsorIdentifier = _sponsorIdentifier;
@synthesize zipcode = _zipcode;
@synthesize picture = _picture;
@synthesize latitude = _latitude;
@synthesize pictureUrl = _pictureUrl;
@synthesize name = _name;
@synthesize state = _state;


+ (Sponsor *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Sponsor *instance = [[Sponsor alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.address = [self objectOrNilForKey:kSponsorAddress fromDictionary:dict];
            self.city = [self objectOrNilForKey:kSponsorCity fromDictionary:dict];
            self.longitude = [[self objectOrNilForKey:kSponsorLongitude fromDictionary:dict] doubleValue];
            self.sponsorIdentifier = [[self objectOrNilForKey:kSponsorId fromDictionary:dict] doubleValue];
            self.zipcode = [self objectOrNilForKey:kSponsorZipcode fromDictionary:dict];
            self.picture = [self objectOrNilForKey:kSponsorPicture fromDictionary:dict];
            self.latitude = [[self objectOrNilForKey:kSponsorLatitude fromDictionary:dict] doubleValue];
            self.pictureUrl = [self objectOrNilForKey:kSponsorPictureUrl fromDictionary:dict];
            self.name = [self objectOrNilForKey:kSponsorName fromDictionary:dict];
            self.state = [self objectOrNilForKey:kSponsorState fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.address forKey:kSponsorAddress];
    [mutableDict setValue:self.city forKey:kSponsorCity];
    [mutableDict setValue:[NSNumber numberWithDouble:self.longitude] forKey:kSponsorLongitude];
    [mutableDict setValue:[NSNumber numberWithDouble:self.sponsorIdentifier] forKey:kSponsorId];
    [mutableDict setValue:self.zipcode forKey:kSponsorZipcode];
    [mutableDict setValue:self.picture forKey:kSponsorPicture];
    [mutableDict setValue:[NSNumber numberWithDouble:self.latitude] forKey:kSponsorLatitude];
    [mutableDict setValue:self.pictureUrl forKey:kSponsorPictureUrl];
    [mutableDict setValue:self.name forKey:kSponsorName];
    [mutableDict setValue:self.state forKey:kSponsorState];

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

    self.address = [aDecoder decodeObjectForKey:kSponsorAddress];
    self.city = [aDecoder decodeObjectForKey:kSponsorCity];
    self.longitude = [aDecoder decodeDoubleForKey:kSponsorLongitude];
    self.sponsorIdentifier = [aDecoder decodeDoubleForKey:kSponsorId];
    self.zipcode = [aDecoder decodeObjectForKey:kSponsorZipcode];
    self.picture = [aDecoder decodeObjectForKey:kSponsorPicture];
    self.latitude = [aDecoder decodeDoubleForKey:kSponsorLatitude];
    self.pictureUrl = [aDecoder decodeObjectForKey:kSponsorPictureUrl];
    self.name = [aDecoder decodeObjectForKey:kSponsorName];
    self.state = [aDecoder decodeObjectForKey:kSponsorState];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_address forKey:kSponsorAddress];
    [aCoder encodeObject:_city forKey:kSponsorCity];
    [aCoder encodeDouble:_longitude forKey:kSponsorLongitude];
    [aCoder encodeDouble:_sponsorIdentifier forKey:kSponsorId];
    [aCoder encodeObject:_zipcode forKey:kSponsorZipcode];
    [aCoder encodeObject:_picture forKey:kSponsorPicture];
    [aCoder encodeDouble:_latitude forKey:kSponsorLatitude];
    [aCoder encodeObject:_pictureUrl forKey:kSponsorPictureUrl];
    [aCoder encodeObject:_name forKey:kSponsorName];
    [aCoder encodeObject:_state forKey:kSponsorState];
}


@end
