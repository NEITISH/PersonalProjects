//
//  LocationManager.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/10/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject<CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *currentLocation;

+ (LocationManager *)sharedInstance;

@end
