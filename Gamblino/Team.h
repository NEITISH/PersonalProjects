//
//  HomeTeam.h
//
//  Created by   on 12/12/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Team : NSObject <NSCoding>

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) int teamIdentifier;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *teamLargeImage;
@property (nonatomic, assign) int leagueId;
@property (nonatomic, assign) int conferenceId;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, assign) int display;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;

+ (Team *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
