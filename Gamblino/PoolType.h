//
//  PoolType.h
//
//  Created by   on 3/15/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface PoolType : NSObject <NSCoding>

@property (nonatomic, assign) int poolTypeIdentifier;
@property (nonatomic, strong) NSArray *leagues;
@property (nonatomic, strong) NSString *poolTypeDescription;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *startAt;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, assign) int maxWager;
@property (nonatomic, assign) int order;
@property (nonatomic, strong) NSString *activeAt;
@property (nonatomic, strong) NSString *imageIcon;
@property (nonatomic, strong) NSString *endsAt;
@property (nonatomic, assign) int startingWallet;
@property (nonatomic, strong) NSString *background_image;

+ (PoolType *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
