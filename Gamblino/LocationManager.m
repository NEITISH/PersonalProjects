//
//  LocationManager.m
//  Gamblino
//
//  Created by JP Hribovsek on 1/10/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

static LocationManager *sharedInstance = nil;

+ (LocationManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter=100;
        self.locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters;
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentLocation=[locations lastObject];
}

@end
