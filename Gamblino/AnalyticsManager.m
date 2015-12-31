//
//  AnalyticsManager.m
//  Gamblino
//
//  Created by JP Hribovsek on 3/18/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "AnalyticsManager.h"

@implementation AnalyticsManager

static AnalyticsManager *sharedInstance = nil;

+ (AnalyticsManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [Flurry startSession:@"HGC6Z5P9HKC3ZQ7YSD9G"];
    }
    return self;
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
