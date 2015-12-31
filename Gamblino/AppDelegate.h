//
//  AppDelegate.h
//  Gamblino
//
//  Created by JP Hribovsek on 11/4/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"
#import "LocationManager.h"
#import "AnalyticsManager.h"

#define USER_DEFAULTS_POOLS_TO_JOIN @"USER_DEFAULTS_POOLS_TO_JOIN"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NetworkManager *networkManager;
@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, strong) AnalyticsManager *analyticsManager;

@end
