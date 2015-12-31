//
//  Users.h
//
//  Created by   on 11/4/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PointBalance, Pivot;

@interface User : NSObject <NSCoding>

@property (nonatomic, assign) int usersIdentifier;
@property (nonatomic, strong) PointBalance *points;
@property (nonatomic, assign) id passwordReset;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, assign) id passwordResetAt;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *unsubscribeCode;
@property (nonatomic, strong) NSString *friendship;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) Pivot *pivot;
@property (nonatomic, assign) int wins;
@property (nonatomic, assign) int loss;
@property (nonatomic, assign) int ties;
@property (nonatomic, assign) int place;
@property (nonatomic, strong) User *user;

+ (User *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
