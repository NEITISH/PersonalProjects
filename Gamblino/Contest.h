//
//  Contest.h
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sponsor,User;

@interface Contest : NSObject <NSCoding>

@property (nonatomic, strong) NSString *startAt;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *picturePath;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) double sponsorId;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, assign) double maxWager;
@property (nonatomic, assign) double sponsorLongitude;
@property (nonatomic, strong) NSString *rules;
@property (nonatomic, strong) NSString *endsAt;
@property (nonatomic, strong) NSString *pictureUrl;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) double startingWallet;
@property (nonatomic, assign) int contestIdentifier;
@property (nonatomic, strong) NSString *activeAt;
@property (nonatomic, strong) NSString *bigPictureUrl;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, assign) double sponsorLatitude;
@property (nonatomic, assign) double feedAdded;
@property (nonatomic, assign) double winnerId;
@property (nonatomic, strong) NSArray *leaderboard;
@property (nonatomic, strong) Sponsor *sponsor;
@property (nonatomic, strong) NSString *bigPicture;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, assign) double order;
@property (nonatomic, strong) NSString *headline;
@property (nonatomic, strong) NSArray *leagues;
@property (nonatomic, strong) NSString *contestDescription;
@property (nonatomic, strong) User *me;
@property (nonatomic, assign) BOOL joined;
@property (nonatomic, assign) int totalUsers;
@property (nonatomic, strong) NSString *landingpage;


+ (Contest *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
