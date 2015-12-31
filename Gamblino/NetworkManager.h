//
//  NetworkManager.h
//  Gamblino
//
//  Created by JP Hribovsek on 11/4/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMBHTTPRequestOperationManager.h"

@interface NetworkManager : NSObject

@property(nonatomic,strong) GMBHTTPRequestOperationManager *requestOperationManager;
@property(nonatomic,strong) GMBHTTPRequestOperationManager *authenticationOperationManager;

+ (NetworkManager *)sharedInstance;
-(void)authenticateWithUsername:(NSString*)username password:(NSString*)password firstName:(NSString*)firstName lastName:(NSString*)lastName facebookToken:(NSString*)facebookToken successBlock:(void (^)(NSString *username,NSString *authenticationToken))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)performFacebookAuthenticationWithSuccessBlock:(void (^)(NSString *username,NSString *authenticationToken))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)performFacebookOnlyAuthenticationWithSuccessBlock:(void (^)(NSString *username,NSString *authenticationToken))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)GET:(NSString*)path withParameters:(NSDictionary*)parameters successBlock:(void (^)(NSDictionary* rootDictionary))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)PUT:(NSString*)path withParameters:(NSDictionary*)parameters successBlock:(void (^)(NSDictionary* rootDictionary))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)DELETE:(NSString*)path withParameters:(NSDictionary*)parameters successBlock:(void (^)(NSDictionary* rootDictionary))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)POST:(NSString*)path withParameters:(NSDictionary*)parameters successBlock:(void (^)(NSDictionary* rootDictionary))successBlock failureBlock:(void (^)(NSError *error))failureBlock;

@end
