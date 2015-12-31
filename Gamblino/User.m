//
//  Users.m
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "PointBalance.h"
#import "Pivot.h"


NSString *const kUsersId = @"id";
NSString *const kUsersPoints = @"points";
NSString *const kUsersPasswordReset = @"password_reset";
NSString *const kUsersPicture = @"picture";
NSString *const kUsersPasswordResetAt = @"password_reset_at";
NSString *const kUsersLocation = @"location";
NSString *const kUsersDeviceToken = @"device_token";
NSString *const kUsersFirstName = @"first_name";
NSString *const kUsersLastName = @"last_name";
NSString *const kUsersEmail = @"email";
NSString *const kUsersUnsubscribeCode = @"unsubscribe_code";
NSString *const kUsersFriendship = @"friendship";
NSString *const kUsersCreateAt = @"created_at";
NSString *const kUsersPivot = @"pivot";
NSString *const kUsersWins = @"wins";
NSString *const kUsersLoss = @"loss";
NSString *const kUsersTies = @"ties";
NSString *const kUsersPlace = @"place";
NSString *const kUsersUser = @"user";

@interface User ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation User

@synthesize usersIdentifier = _usersIdentifier;
@synthesize points = _points;
@synthesize passwordReset = _passwordReset;
@synthesize picture = _picture;
@synthesize passwordResetAt = _passwordResetAt;
@synthesize location = _location;
@synthesize deviceToken = _deviceToken;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize email = _email;
@synthesize unsubscribeCode = _unsubscribeCode;
@synthesize friendship = _friendship;
@synthesize createdAt = _createdAt;
@synthesize pivot = _pivot;
@synthesize wins = _wins;
@synthesize loss = _loss;
@synthesize ties = _ties;
@synthesize place = _place;
@synthesize user = _user;

+ (User *)modelObjectWithDictionary:(NSDictionary *)dict
{
    User *instance = [[User alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.usersIdentifier = [[self objectOrNilForKey:kUsersId fromDictionary:dict] intValue];
            self.points = [PointBalance modelObjectWithDictionary:[dict objectForKey:kUsersPoints]];
            self.passwordReset = [self objectOrNilForKey:kUsersPasswordReset fromDictionary:dict];
            self.picture = [self objectOrNilForKey:kUsersPicture fromDictionary:dict];
            self.passwordResetAt = [self objectOrNilForKey:kUsersPasswordResetAt fromDictionary:dict];
            self.location = [self objectOrNilForKey:kUsersLocation fromDictionary:dict];
            self.deviceToken = [self objectOrNilForKey:kUsersDeviceToken fromDictionary:dict];
            self.firstName = [self objectOrNilForKey:kUsersFirstName fromDictionary:dict];
            self.lastName = [self objectOrNilForKey:kUsersLastName fromDictionary:dict];
            self.email = [self objectOrNilForKey:kUsersEmail fromDictionary:dict];
            self.unsubscribeCode = [self objectOrNilForKey:kUsersUnsubscribeCode fromDictionary:dict];
            self.friendship = [self objectOrNilForKey:kUsersFriendship fromDictionary:dict];
            self.createdAt = [self objectOrNilForKey:kUsersCreateAt fromDictionary:dict];
            self.pivot = [Pivot modelObjectWithDictionary:[dict objectForKey:kUsersPivot]];
        self.wins = [[self objectOrNilForKey:kUsersWins fromDictionary:dict] intValue];
        self.loss = [[self objectOrNilForKey:kUsersLoss fromDictionary:dict] intValue];
        self.ties = [[self objectOrNilForKey:kUsersTies fromDictionary:dict] intValue];
        self.place = [[self objectOrNilForKey:kUsersPlace fromDictionary:dict] intValue];
        self.user = [User modelObjectWithDictionary:[dict objectForKey:kUsersUser]];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithInt:self.usersIdentifier] forKey:kUsersId];
    [mutableDict setValue:[self.points dictionaryRepresentation] forKey:kUsersPoints];
    [mutableDict setValue:self.passwordReset forKey:kUsersPasswordReset];
    [mutableDict setValue:self.picture forKey:kUsersPicture];
    [mutableDict setValue:self.passwordResetAt forKey:kUsersPasswordResetAt];
    [mutableDict setValue:self.location forKey:kUsersLocation];
    [mutableDict setValue:self.deviceToken forKey:kUsersDeviceToken];
    [mutableDict setValue:self.firstName forKey:kUsersFirstName];
    [mutableDict setValue:self.lastName forKey:kUsersLastName];
    [mutableDict setValue:self.email forKey:kUsersEmail];
    [mutableDict setValue:self.unsubscribeCode forKey:kUsersUnsubscribeCode];
    [mutableDict setValue:self.friendship forKey:kUsersFriendship];
    [mutableDict setValue:self.createdAt forKey:kUsersCreateAt];
    [mutableDict setValue:[self.pivot dictionaryRepresentation] forKey:kUsersPivot];
    [mutableDict setValue:[NSNumber numberWithInt:self.wins] forKey:kUsersWins];
    [mutableDict setValue:[NSNumber numberWithInt:self.loss] forKey:kUsersLoss];
    [mutableDict setValue:[NSNumber numberWithInt:self.ties] forKey:kUsersTies];
    [mutableDict setValue:[NSNumber numberWithInt:self.place] forKey:kUsersPlace];
    [mutableDict setValue:[self.user dictionaryRepresentation] forKey:kUsersUser];
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

    self.usersIdentifier = [aDecoder decodeIntForKey:kUsersId];
    self.points = [aDecoder decodeObjectForKey:kUsersPoints];
    self.passwordReset = [aDecoder decodeObjectForKey:kUsersPasswordReset];
    self.picture = [aDecoder decodeObjectForKey:kUsersPicture];
    self.passwordResetAt = [aDecoder decodeObjectForKey:kUsersPasswordResetAt];
    self.location = [aDecoder decodeObjectForKey:kUsersLocation];
    self.deviceToken = [aDecoder decodeObjectForKey:kUsersDeviceToken];
    self.firstName = [aDecoder decodeObjectForKey:kUsersFirstName];
    self.lastName = [aDecoder decodeObjectForKey:kUsersLastName];
    self.email = [aDecoder decodeObjectForKey:kUsersEmail];
    self.unsubscribeCode = [aDecoder decodeObjectForKey:kUsersUnsubscribeCode];
    self.friendship = [aDecoder decodeObjectForKey:kUsersFriendship];
    self.createdAt = [aDecoder decodeObjectForKey:kUsersCreateAt];
    self.pivot = [aDecoder decodeObjectForKey:kUsersPivot];
    self.wins = [aDecoder decodeIntForKey:kUsersWins];
    self.loss = [aDecoder decodeIntForKey:kUsersLoss];
    self.ties = [aDecoder decodeIntForKey:kUsersTies];
    self.place = [aDecoder decodeIntForKey:kUsersPlace];
    self.user = [aDecoder decodeObjectForKey:kUsersUser];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeInt:_usersIdentifier forKey:kUsersId];
    [aCoder encodeObject:_points forKey:kUsersPoints];
    [aCoder encodeObject:_passwordReset forKey:kUsersPasswordReset];
    [aCoder encodeObject:_picture forKey:kUsersPicture];
    [aCoder encodeObject:_passwordResetAt forKey:kUsersPasswordResetAt];
    [aCoder encodeObject:_location forKey:kUsersLocation];
    [aCoder encodeObject:_deviceToken forKey:kUsersDeviceToken];
    [aCoder encodeObject:_firstName forKey:kUsersFirstName];
    [aCoder encodeObject:_lastName forKey:kUsersLastName];
    [aCoder encodeObject:_email forKey:kUsersEmail];
    [aCoder encodeObject:_unsubscribeCode forKey:kUsersUnsubscribeCode];
    [aCoder encodeObject:_friendship forKey:kUsersFriendship];
    [aCoder encodeObject:_createdAt forKey:kUsersCreateAt];
    [aCoder encodeObject:_pivot forKey:kUsersPivot];
    [aCoder encodeInt:_wins forKey:kUsersWins];
    [aCoder encodeInt:_loss forKey:kUsersLoss];
    [aCoder encodeInt:_ties forKey:kUsersTies];
    [aCoder encodeInt:_place forKey:kUsersPlace];
    [aCoder encodeObject:_user forKey:kUsersUser];
}


@end
