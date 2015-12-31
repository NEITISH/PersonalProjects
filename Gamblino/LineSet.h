//
//  LineSet.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/22/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Line.h"

@interface LineSet : NSObject

@property (nonatomic,strong) NSString *lineTitle;
@property (nonatomic,strong) Line *awayLine;
@property (nonatomic,strong) Line *homeLine;
@property (nonatomic,strong) Line *underLine;
@property (nonatomic,strong) Line *overLine;

@end
