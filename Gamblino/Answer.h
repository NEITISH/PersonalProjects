//
//  Answer.h
//
//  Created by   on 1/18/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Answer : NSObject <NSCoding>

@property (nonatomic, assign) int answerIdentifier;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, assign) double value;
@property (nonatomic, strong) NSString *updatedAt;

+ (Answer *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
