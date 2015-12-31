//
//  Lines.h
//
//  Created by   on 12/12/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Line : NSObject <NSCoding>

@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign) int linesIdentifier;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, assign) int teamId;
@property (nonatomic, assign) int eventId;
@property (nonatomic, assign) double line;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *updatedAt;

+ (Line *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
