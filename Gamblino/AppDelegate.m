//
//  AppDelegate.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/4/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "Constants.h"
#import "WelcomeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Crashlytics/Crashlytics.h>
#import "Branch.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        // params are the deep linked params associated with the link that the user clicked before showing up.
        NSLog(@"deep link data: %@", [params description]);
        if([[params allKeys] containsObject:@"pool"]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:params forKey:USER_DEFAULTS_POOLS_TO_JOIN];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissModalAndOpenFeed" object:nil];
        }
    }];
    
    [Crashlytics startWithAPIKey:@"bf1f1dd48378932e52e002a86162a1e7d4340848"];

    // Setup Analytics manager
    self.analyticsManager=[AnalyticsManager sharedInstance];
    
    // Setup network Manager
    self.networkManager=[NetworkManager sharedInstance];
    
    //Setup location Manager
    self.locationManager=[LocationManager sharedInstance];
    
    //Register for push
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    // Setup home screen
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    HomeViewController *homeViewController=[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    UINavigationController *mainNavigationController=[[UINavigationController alloc] initWithRootViewController:homeViewController];
    self.window.rootViewController=mainNavigationController;
    [self.window makeKeyAndVisible];
    if(![[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultsAccessTokenKey]){
        WelcomeViewController *welcomeViewController=[[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
        UINavigationController *loginNavigationViewController=[[UINavigationController alloc] initWithRootViewController:welcomeViewController];
        [mainNavigationController presentViewController:loginNavigationViewController animated:NO completion:^{}];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    return handledByBranch;
}



#pragma mark - Facebook Callback delegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if([url.absoluteString hasPrefix:@"gamblino"]) {
        return YES;
    }
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceToken forKey:@"deviceToken"];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{

}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}


@end
