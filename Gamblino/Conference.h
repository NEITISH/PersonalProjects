//
//  Conference.h
//
//  Created by   on 12/14/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Conference : NSObject <NSCoding>

@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, assign) int conferenceId;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int leagueId;

+ (Conference *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
