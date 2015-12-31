//
//  NetworkManager.m
//  Gamblino
//
//  Created by JP Hribovsek on 11/4/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "NetworkManager.h"
#import "Constants.h"
#import <AFNetworking/AFURLResponseSerialization.h>
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"
#import "AnalyticsManager.h"

@implementation NetworkManager

static NetworkManager *sharedInstance = nil;

+ (NetworkManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.requestOperationManager=[[GMBHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURL]];
        
        self.requestOperationManager.requestSerializer=[AFJSONRequestSerializer serializer];
        NSString *authToken=[[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultsAccessTokenKey];
        [self.requestOperationManager.requestSerializer setValue:authToken forHTTPHeaderField:@"Authorization"];
        
        self.requestOperationManager.responseSerializer=[AFJSONResponseSerializer serializer];
        
        self.authenticationOperationManager=[[GMBHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kAuthenticationURL]];
        self.authenticationOperationManager.responseSerializer=[AFJSONResponseSerializer serializer];
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

- (NSString *)getDeviceTokenFromUserDefaults
{
    NSData *webDeviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    if(webDeviceToken){
        NSString *deviceToken = [[webDeviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        return deviceToken;
    }
    else{
        return nil;
    }
}

-(void)authenticateWithUsername:(NSString*)username password:(NSString*)password firstName:(NSString*)firstName lastName:(NSString*)lastName facebookToken:(NSString*)facebookToken successBlock:(void (^)(NSString *username,NSString *authenticationToken))successBlock failureBlock:(void (^)(NSError *error))failureBlock{
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(facebookToken){
        [parameters addEntriesFromDictionary:@{@"client_id":kClientId,@"client_secret":kClientSecret,@"account_type":@"facebook",@"grant_type":@"GamblinoGrant",@"access_token":facebookToken}];
    }
    else{
        [parameters addEntriesFromDictionary:@{@"client_id":kClientId,@"client_secret":kClientSecret,@"account_type":@"email",@"grant_type":@"password",@"username":username,@"password":password}];
        if(firstName&&lastName){
            [parameters addEntriesFromDictionary:@{@"first_name":firstName,@"last_name":lastName}];
            [parameters setValue:@"GamblinoGrant" forKey:@"grant_type"];
        }
    }
    if([self getDeviceTokenFromUserDefaults]){
        [parameters setValue:[self getDeviceTokenFromUserDefaults] forKey:@"device_token"];
    }
    
    [self.authenticationOperationManager POST:@"/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if([responseObject isKindOfClass:[NSDictionary class]]&&[[(NSDictionary*)responseObject allKeys] containsObject:@"access_token"]){
            NSString *accessToken=[responseObject valueForKey:@"access_token"];
            [self.requestOperationManager.requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
            [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:kUserDefaultsAccessTokenKey];
            if([responseObject isKindOfClass:[NSDictionary class]]&&[[(NSDictionary*)responseObject allKeys] containsObject:@"user"]){
                NSDictionary *userDic=[responseObject valueForKey:@"user"];
                User *myUser=[[User alloc] initWithDictionary:userDic];
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:myUser.usersIdentifier] forKey:kUserId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(username,accessToken);
                });
            }
            else{
                failureBlock(nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        failureBlock(error);
    }];
}

- (void)performFacebookAuthenticationWithSuccessBlock:(void (^)(NSString *username,NSString *authenticationToken))successBlock failureBlock:(void (^)(NSError *error))failureBlock{
    if (![FBSession activeSession] || ![[FBSession activeSession] isOpen] ) {
        NSArray *readPermissions = @[@"email",@"user_location"];
        
        [FBSession openActiveSessionWithReadPermissions:readPermissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (session.isOpen) {
                [self authenticateWithUsername:nil password:nil firstName:nil lastName:nil facebookToken:session.accessToken successBlock:successBlock failureBlock:failureBlock];
            }
            else if (error){
                NSLog(@"%@",error.description);
            }
            
        }];
    } else {
        [self authenticateWithUsername:nil password:nil firstName:nil lastName:nil facebookToken:[FBSession activeSession].accessToken successBlock:^(NSString *username,NSString *authenticationToken){
            NSLog(@"success facebook 2");
        }failureBlock:^(NSError *error){
            NSLog(@"failure facebook");
        }];
    }
}

- (void)performFacebookOnlyAuthenticationWithSuccessBlock:(void (^)(NSString *username,NSString *authenticationToken))successBlock failureBlock:(void (^)(NSError *error))failureBlock{
    if (![FBSession activeSession] || ![[FBSession activeSession] isOpen] ) {
        NSArray *readPermissions = @[@"email",@"user_location"];
        [FBSession openActiveSessionWithReadPermissions:readPermissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (session.isOpen) {
                successBlock(nil,nil);
            }
            else if (error){
                failureBlock(nil);
                NSLog(@"%@",error.description);
            }
            
        }];
    }
    else{
        successBlock(nil,nil);
    }
}

-(void)GET:(NSString*)path withParameters:(NSDictionary*)parameters successBlock:(void (^)(NSDictionary* rootDictionary))successBlock failureBlock:(void (^)(NSError *error))failureBlock{
    [[NetworkManager sharedInstance].requestOperationManager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSInteger statusCode = operation.response.statusCode;
        
        if(statusCode==404){
            NSString *Message=[operation.responseObject objectForKey:@"error"];
            failureBlock((NSError *)Message);
        }
        if(statusCode==401){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification401Error" object:nil];
            });
        }
        if(statusCode==500){
            [Flurry logEvent:[NSString stringWithFormat:@"HTTP 500 error on GET path=%@",path]];
        }
        failureBlock(error);
    }];
}

-(void)PUT:(NSString*)path withParameters:(NSDictionary*)parameters successBlock:(void (^)(NSDictionary* rootDictionary))successBlock failureBlock:(void (^)(NSError *error))failureBlock{
    [[NetworkManager sharedInstance].requestOperationManager PUT:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        
        NSInteger statusCode = operation.response.statusCode;
        if(statusCode==401){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification401Error" object:nil];
            });
        }
        if(statusCode==500){
            [Flurry logEvent:[NSString stringWithFormat:@"HTTP 500 error on PUT path=%@",path]];
        }
        failureBlock(error);
    }];
}

- (void)DELETE:(NSString*)path withParameters:(NSDictionary*)parameters successBlock:(void (^)(NSDictionary* rootDictionary))successBlock failureBlock:(void (^)(NSError *error))failureBlock{
    [[NetworkManager sharedInstance].requestOperationManager DELETE:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSInteger statusCode = operation.response.statusCode;
        if(statusCode==401){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification401Error" object:nil];
            });
        }
        if(statusCode==409){
            dispatch_async(dispatch_get_main_queue(), ^{
                id responseObject=operation.responseObject;
                if(responseObject && [responseObject isKindOfClass:[NSDictionary class]] && [responseObject valueForKey:@"error"]){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[responseObject valueForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
                }
            });
        }
        if(statusCode==500){
            [Flurry logEvent:[NSString stringWithFormat:@"HTTP 500 error on POST path=%@",path]];
        }
        failureBlock(error);
    }];
}

- (void)POST:(NSString*)path withParameters:(NSDictionary*)parameters successBlock:(void (^)(NSDictionary* rootDictionary))successBlock failureBlock:(void (^)(NSError *error))failureBlock{
    [[NetworkManager sharedInstance].requestOperationManager POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSInteger statusCode = operation.response.statusCode;
        if(statusCode==401){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification401Error" object:nil];
            });
        }
        if(statusCode==409){
            dispatch_async(dispatch_get_main_queue(), ^{
                id responseObject=operation.responseObject;
                if(responseObject && [responseObject isKindOfClass:[NSDictionary class]] && [responseObject valueForKey:@"error"]){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[responseObject valueForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
                }
            });
        }
        if(statusCode==500){
            [Flurry logEvent:[NSString stringWithFormat:@"HTTP 500 error on POST path=%@",path]];
        }
        failureBlock(error);
    }];
}



@end
