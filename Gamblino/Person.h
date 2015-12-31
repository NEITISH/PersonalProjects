//
//  Person.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/2/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property(nonatomic,strong) NSString *firstName;
@property(nonatomic,strong) NSString *lastName;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *hometown;
@property(nonatomic,strong) UIImage *avatarImage;
@property(nonatomic,strong) NSString *thumbnailURL;
@property(nonatomic,strong) NSString *facebookID;
@property(nonatomic,assign) int gamblinoId;

@end
