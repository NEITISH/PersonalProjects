//
//  AddPoolDetailsViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 3/15/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoolType.h"
@interface AddPoolDetailsViewController : UIViewController <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) PoolType *poolType;

@end
