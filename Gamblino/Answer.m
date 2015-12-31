//
//  Answer.m
//
//  Created by   on 1/18/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "Answer.h"


NSString *const kAnswerId = @"id";
NSString *const kAnswerCreatedAt = @"created_at";
NSString *const kAnswerTitle = @"title";
NSString *const kAnswerPicture = @"picture";
NSString *const kAnswerEventId = @"event_id";
NSString *const kAnswerValue = @"value";
NSString *const kAnswerUpdatedAt = @"updated_at";


@interface Answer ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Answer

@synthesize answerIdentifier = _answerIdentifier;
@synthesize createdAt = _createdAt;
@synthesize title = _title;
@synthesize picture = _picture;
@synthesize eventId = _eventId;
@synthesize value = _value;
@synthesize updatedAt = _updatedAt;


+ (Answer *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Answer *instance = [[Answer alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.answerIdentifier = [[self objectOrNilForKey:kAnswerId fromDictionary:dict] intValue];
            self.createdAt = [self objectOrNilForKey:kAnswerCreatedAt fromDictionary:dict];
            self.title = [self objectOrNilForKey:kAnswerTitle fromDictionary:dict];
            self.picture = [self objectOrNilForKey:kAnswerPicture fromDictionary:dict];
            self.eventId = [self objectOrNilForKey:kAnswerEventId fromDictionary:dict];
            self.value = [[self objectOrNilForKey:kAnswerValue fromDictionary:dict] doubleValue];
            self.updatedAt = [self objectOrNilForKey:kAnswerUpdatedAt fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithInt:self.answerIdentifier] forKey:kAnswerId];
    [mutableDict setValue:self.createdAt forKey:kAnswerCreatedAt];
    [mutableDict setValue:self.title forKey:kAnswerTitle];
    [mutableDict setValue:self.picture forKey:kAnswerPicture];
    [mutableDict setValue:self.eventId forKey:kAnswerEventId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.value] forKey:kAnswerValue];
    [mutableDict setValue:self.updatedAt forKey:kAnswerUpdatedAt];

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

    self.answerIdentifier = [aDecoder decodeIntForKey:kAnswerId];
    self.createdAt = [aDecoder decodeObjectForKey:kAnswerCreatedAt];
    self.title = [aDecoder decodeObjectForKey:kAnswerTitle];
    self.picture = [aDecoder decodeObjectForKey:kAnswerPicture];
    self.eventId = [aDecoder decodeObjectForKey:kAnswerEventId];
    self.value = [aDecoder decodeDoubleForKey:kAnswerValue];
    self.updatedAt = [aDecoder decodeObjectForKey:kAnswerUpdatedAt];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeInt:_answerIdentifier forKey:kAnswerId];
    [aCoder encodeObject:_createdAt forKey:kAnswerCreatedAt];
    [aCoder encodeObject:_title forKey:kAnswerTitle];
    [aCoder encodeObject:_picture forKey:kAnswerPicture];
    [aCoder encodeObject:_eventId forKey:kAnswerEventId];
    [aCoder encodeDouble:_value forKey:kAnswerValue];
    [aCoder encodeObject:_updatedAt forKey:kAnswerUpdatedAt];
}


@end
