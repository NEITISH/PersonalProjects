//
//  NationalContestCell.h
//  Gamblino
//
//  Created by JP Hribovsek on 1/8/14.
//  Copyright (c) 2014 Gamblino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NationalContestCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic,weak) IBOutlet UILabel *nationalContestHeaderLabel;

@end
