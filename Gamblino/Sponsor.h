//
//  Sponsor.h
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Sponsor : NSObject <NSCoding>

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double sponsorIdentifier;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, assign) double latitude;
@property (nonatomic, strong) NSString *pictureUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *state;

+ (Sponsor *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
