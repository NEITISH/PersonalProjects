//
//  Contest.m
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Contest.h"
#import "User.h"
#import "Sponsor.h"
#import "League.h"

NSString *const kContestStartAt = @"start_at";
NSString *const kContestStatus = @"status";
NSString *const kContestPicturePath = @"picture_path";
NSString *const kContestTitle = @"title";
NSString *const kContestSponsorId = @"sponsor_id";
NSString *const kContestPicture = @"picture";
NSString *const kContestMaxWager = @"max_wager";
NSString *const kContestSponsorLongitude = @"sponsor_longitude";
NSString *const kContestRules = @"rules";
NSString *const kContestEndsAt = @"ends_at";
NSString *const kContestPictureUrl = @"picture_url";
NSString *const kContestType = @"type";
NSString *const kContestStartingWallet = @"starting_wallet";
NSString *const kContestId = @"id";
NSString *const kContestActiveAt = @"active_at";
NSString *const kContestBigPictureUrl = @"big_picture_url";
NSString *const kContestSubtitle = @"subtitle";
NSString *const kContestSponsorLatitude = @"sponsor_latitude";
NSString *const kContestFeedAdded = @"feed_added";
NSString *const kContestWinnerId = @"winner_id";
NSString *const kContestLeaderboard = @"leaderboard";
NSString *const kContestSponsor = @"sponsor";
NSString *const kContestBigPicture = @"big_picture";
NSString *const kContestCreatedAt = @"created_at";
NSString *const kContestOrder = @"order";
NSString *const kContestHeadline = @"headline";
NSString *const kContestLeagues = @"leagues";
NSString *const kContestDescription = @"description";
NSString *const kContestMe = @"me";
NSString *const kJoined = @"joined";
NSString *const kContestTotalUsers = @"total_users";
NSString *const kContestlanding_page=@"landing_page";

@interface Contest ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Contest

@synthesize startAt = _startAt;
@synthesize status = _status;
@synthesize picturePath = _picturePath;
@synthesize title = _title;
@synthesize sponsorId = _sponsorId;
@synthesize picture = _picture;
@synthesize maxWager = _maxWager;
@synthesize sponsorLongitude = _sponsorLongitude;
@synthesize rules = _rules;
@synthesize endsAt = _endsAt;
@synthesize pictureUrl = _pictureUrl;
@synthesize type = _type;
@synthesize startingWallet = _startingWallet;
@synthesize contestIdentifier = _contestIdentifier;
@synthesize activeAt = _activeAt;
@synthesize bigPictureUrl = _bigPictureUrl;
@synthesize subtitle = _subtitle;
@synthesize sponsorLatitude = _sponsorLatitude;
@synthesize feedAdded = _feedAdded;
@synthesize winnerId = _winnerId;
@synthesize leaderboard = _leaderboard;
@synthesize sponsor = _sponsor;
@synthesize bigPicture = _bigPicture;
@synthesize createdAt = _createdAt;
@synthesize order = _order;
@synthesize headline = _headline;
@synthesize leagues = _leagues;
@synthesize contestDescription = _contestDescription;
@synthesize me = _me;
@synthesize joined = _joined;
@synthesize totalUsers = _totalUsers;
@synthesize landingpage = _landingPage;

+ (Contest *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Contest *instance = [[Contest alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.startAt = [self objectOrNilForKey:kContestStartAt fromDictionary:dict];
            self.status = [self objectOrNilForKey:kContestStatus fromDictionary:dict];
            self.picturePath = [self objectOrNilForKey:kContestPicturePath fromDictionary:dict];
            self.title = [self objectOrNilForKey:kContestTitle fromDictionary:dict];
            self.sponsorId = [[self objectOrNilForKey:kContestSponsorId fromDictionary:dict] doubleValue];
            self.picture = [self objectOrNilForKey:kContestPicture fromDictionary:dict];
            self.maxWager = [[self objectOrNilForKey:kContestMaxWager fromDictionary:dict] doubleValue];
            self.sponsorLongitude = [[self objectOrNilForKey:kContestSponsorLongitude fromDictionary:dict] doubleValue];
          self.landingpage = [self objectOrNilForKey:kContestlanding_page fromDictionary:dict];
            self.rules = [self objectOrNilForKey:kContestRules fromDictionary:dict];
            self.endsAt = [self objectOrNilForKey:kContestEndsAt fromDictionary:dict];
            self.pictureUrl = [self objectOrNilForKey:kContestPictureUrl fromDictionary:dict];
            self.type = [self objectOrNilForKey:kContestType fromDictionary:dict];
            self.startingWallet = [[self objectOrNilForKey:kContestStartingWallet fromDictionary:dict] doubleValue];
            self.contestIdentifier = [[self objectOrNilForKey:kContestId fromDictionary:dict] intValue];
            self.activeAt = [self objectOrNilForKey:kContestActiveAt fromDictionary:dict];
            self.bigPictureUrl = [self objectOrNilForKey:kContestBigPictureUrl fromDictionary:dict];
            self.subtitle = [self objectOrNilForKey:kContestSubtitle fromDictionary:dict];
            self.sponsorLatitude = [[self objectOrNilForKey:kContestSponsorLatitude fromDictionary:dict] doubleValue];
            self.feedAdded = [[self objectOrNilForKey:kContestFeedAdded fromDictionary:dict] doubleValue];
            self.winnerId = [[self objectOrNilForKey:kContestWinnerId fromDictionary:dict] doubleValue];
        self.joined = [[self objectOrNilForKey:kJoined fromDictionary:dict] boolValue];
        self.totalUsers = [[self objectOrNilForKey:kContestTotalUsers fromDictionary:dict] intValue];
    NSObject *receivedUsers = [dict objectForKey:kContestLeaderboard];
    NSMutableArray *parsedUsers = [NSMutableArray array];
    if ([receivedUsers isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedUsers) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedUsers addObject:[User modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedUsers isKindOfClass:[NSDictionary class]]) {
       [parsedUsers addObject:[User modelObjectWithDictionary:(NSDictionary *)receivedUsers]];
    }

    self.leaderboard = [NSArray arrayWithArray:parsedUsers];
            self.sponsor = [Sponsor modelObjectWithDictionary:[dict objectForKey:kContestSponsor]];
            self.me = [User modelObjectWithDictionary:[dict objectForKey:kContestMe]];
            self.bigPicture = [self objectOrNilForKey:kContestBigPicture fromDictionary:dict];
            self.createdAt = [self objectOrNilForKey:kContestCreatedAt fromDictionary:dict];
            self.order = [[self objectOrNilForKey:kContestOrder fromDictionary:dict] doubleValue];
            self.headline = [self objectOrNilForKey:kContestHeadline fromDictionary:dict];
    NSObject *receivedLeagues = [dict objectForKey:kContestLeagues];
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
            self.contestDescription = [self objectOrNilForKey:kContestDescription fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.startAt forKey:kContestStartAt];
    [mutableDict setValue:self.status forKey:kContestStatus];
    [mutableDict setValue:self.landingpage forKey:kContestlanding_page];
    [mutableDict setValue:self.picturePath forKey:kContestPicturePath];
    [mutableDict setValue:self.title forKey:kContestTitle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.sponsorId] forKey:kContestSponsorId];
    [mutableDict setValue:self.picture forKey:kContestPicture];
    [mutableDict setValue:[NSNumber numberWithDouble:self.maxWager] forKey:kContestMaxWager];
    [mutableDict setValue:[NSNumber numberWithDouble:self.sponsorLongitude] forKey:kContestSponsorLongitude];
    [mutableDict setValue:self.rules forKey:kContestRules];
    [mutableDict setValue:self.endsAt forKey:kContestEndsAt];
    [mutableDict setValue:self.pictureUrl forKey:kContestPictureUrl];
    [mutableDict setValue:self.type forKey:kContestType];
    [mutableDict setValue:[NSNumber numberWithDouble:self.startingWallet] forKey:kContestStartingWallet];
    [mutableDict setValue:[NSNumber numberWithInt:self.contestIdentifier] forKey:kContestId];
    [mutableDict setValue:self.activeAt forKey:kContestActiveAt];
    [mutableDict setValue:self.bigPictureUrl forKey:kContestBigPictureUrl];
    [mutableDict setValue:self.subtitle forKey:kContestSubtitle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.sponsorLatitude] forKey:kContestSponsorLatitude];
    [mutableDict setValue:[NSNumber numberWithDouble:self.feedAdded] forKey:kContestFeedAdded];
    [mutableDict setValue:[NSNumber numberWithDouble:self.winnerId] forKey:kContestWinnerId];
NSMutableArray *tempArrayForUsers = [NSMutableArray array];
    for (NSObject *subArrayObject in self.leaderboard) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForUsers addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForUsers addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForUsers] forKey:kContestLeaderboard];
    [mutableDict setValue:[self.sponsor dictionaryRepresentation] forKey:kContestSponsor];
    [mutableDict setValue:[self.me dictionaryRepresentation] forKey:kContestMe];
    [mutableDict setValue:self.bigPicture forKey:kContestBigPicture];
    [mutableDict setValue:self.createdAt forKey:kContestCreatedAt];
    [mutableDict setValue:[NSNumber numberWithDouble:self.order] forKey:kContestOrder];
    [mutableDict setValue:self.headline forKey:kContestHeadline];
    [mutableDict setValue:[NSNumber numberWithBool:self.joined] forKey:kJoined];
    [mutableDict setValue:[NSNumber numberWithInt:self.totalUsers] forKey:kContestTotalUsers];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLeagues] forKey:kContestLeagues];
    [mutableDict setValue:self.contestDescription forKey:kContestDescription];

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

    self.startAt = [aDecoder decodeObjectForKey:kContestStartAt];
    self.status = [aDecoder decodeObjectForKey:kContestStatus];
    self.picturePath = [aDecoder decodeObjectForKey:kContestPicturePath];
    self.title = [aDecoder decodeObjectForKey:kContestTitle];
    self.landingpage = [aDecoder decodeObjectForKey:kContestlanding_page];
    self.sponsorId = [aDecoder decodeDoubleForKey:kContestSponsorId];
    self.picture = [aDecoder decodeObjectForKey:kContestPicture];
    self.maxWager = [aDecoder decodeDoubleForKey:kContestMaxWager];
    self.sponsorLongitude = [aDecoder decodeDoubleForKey:kContestSponsorLongitude];
    self.rules = [aDecoder decodeObjectForKey:kContestRules];
    self.endsAt = [aDecoder decodeObjectForKey:kContestEndsAt];
    self.pictureUrl = [aDecoder decodeObjectForKey:kContestPictureUrl];
    self.type = [aDecoder decodeObjectForKey:kContestType];
    self.startingWallet = [aDecoder decodeDoubleForKey:kContestStartingWallet];
    self.contestIdentifier = [aDecoder decodeIntForKey:kContestId];
    self.activeAt = [aDecoder decodeObjectForKey:kContestActiveAt];
    self.bigPictureUrl = [aDecoder decodeObjectForKey:kContestBigPictureUrl];
    self.subtitle = [aDecoder decodeObjectForKey:kContestSubtitle];
    self.sponsorLatitude = [aDecoder decodeDoubleForKey:kContestSponsorLatitude];
    self.feedAdded = [aDecoder decodeDoubleForKey:kContestFeedAdded];
    self.winnerId = [aDecoder decodeDoubleForKey:kContestWinnerId];
    self.leaderboard = [aDecoder decodeObjectForKey:kContestLeaderboard];
    self.sponsor = [aDecoder decodeObjectForKey:kContestSponsor];
    self.me = [aDecoder decodeObjectForKey:kContestMe];
    self.bigPicture = [aDecoder decodeObjectForKey:kContestBigPicture];
    self.createdAt = [aDecoder decodeObjectForKey:kContestCreatedAt];
    self.order = [aDecoder decodeDoubleForKey:kContestOrder];
    self.headline = [aDecoder decodeObjectForKey:kContestHeadline];
    self.leagues = [aDecoder decodeObjectForKey:kContestLeagues];
    self.contestDescription = [aDecoder decodeObjectForKey:kContestDescription];
    self.joined = [aDecoder decodeBoolForKey:kJoined];
    self.totalUsers = [aDecoder decodeIntForKey:kContestTotalUsers];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_startAt forKey:kContestStartAt];
    [aCoder encodeObject:_status forKey:kContestStatus];
    [aCoder encodeObject:_picturePath forKey:kContestPicturePath];
    [aCoder encodeObject:_title forKey:kContestTitle];
    [aCoder encodeDouble:_sponsorId forKey:kContestSponsorId];
    [aCoder encodeObject:_picture forKey:kContestPicture];
    [aCoder encodeObject:_landingPage forKey:kContestlanding_page];
    [aCoder encodeDouble:_maxWager forKey:kContestMaxWager];
    [aCoder encodeDouble:_sponsorLongitude forKey:kContestSponsorLongitude];
    [aCoder encodeObject:_rules forKey:kContestRules];
    [aCoder encodeObject:_endsAt forKey:kContestEndsAt];
    [aCoder encodeObject:_pictureUrl forKey:kContestPictureUrl];
    [aCoder encodeObject:_type forKey:kContestType];
    [aCoder encodeDouble:_startingWallet forKey:kContestStartingWallet];
    [aCoder encodeInt:_contestIdentifier forKey:kContestId];
    [aCoder encodeObject:_activeAt forKey:kContestActiveAt];
    [aCoder encodeObject:_bigPictureUrl forKey:kContestBigPictureUrl];
    [aCoder encodeObject:_subtitle forKey:kContestSubtitle];
    [aCoder encodeDouble:_sponsorLatitude forKey:kContestSponsorLatitude];
    [aCoder encodeDouble:_feedAdded forKey:kContestFeedAdded];
    [aCoder encodeDouble:_winnerId forKey:kContestWinnerId];
    [aCoder encodeObject:_leaderboard forKey:kContestLeaderboard];
    [aCoder encodeObject:_sponsor forKey:kContestSponsor];
    [aCoder encodeObject:_me forKey:kContestMe];
    [aCoder encodeObject:_bigPicture forKey:kContestBigPicture];
    [aCoder encodeObject:_createdAt forKey:kContestCreatedAt];
    [aCoder encodeDouble:_order forKey:kContestOrder];
    [aCoder encodeObject:_headline forKey:kContestHeadline];
    [aCoder encodeObject:_leagues forKey:kContestLeagues];
    [aCoder encodeObject:_contestDescription forKey:kContestDescription];
    [aCoder encodeBool:_joined forKey:kJoined];
    [aCoder encodeInt:_totalUsers forKey:kContestTotalUsers];
}


@end
