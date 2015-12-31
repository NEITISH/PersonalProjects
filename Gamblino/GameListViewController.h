//
//  GameListViewController.h
//  Gamblino
//
//  Created by JP Hribovsek on 12/12/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "League.h"
#import "ConferencesViewController.h"
#import "GameListCell.h"

@interface GameListViewController : UIViewController<ConferencesViewControllerDelegate,GameListCellDelegate>

@property(nonatomic,strong) League *league;

@end
