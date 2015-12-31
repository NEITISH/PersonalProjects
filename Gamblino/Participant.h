//
//  Participants.h
//
//  Created by   on 12/12/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Participant : NSObject <NSCoding>

@property (nonatomic, assign) int amount;
@property (nonatomic, assign) id result;
@property (nonatomic, assign) int points;
@property (nonatomic, assign) int participantsIdentifier;
@property (nonatomic, assign) int eventId;
@property (nonatomic, assign) int line;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) User *user;

+ (Participant *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
