//
//  UIView+Blur.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/14/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "UIView+Blur.h"
#import "UIImage+ImageEffects.h"

@implementation UIView (Blur)

- (UIImage*)darkBlurImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyExtraDarkEffect];
    UIGraphicsEndImageContext();
    return blurredSnapshotImage;
}

- (UIImage*)lightBlurImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyBlurWithRadius:30 tintColor:[UIColor colorWithWhite:0 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
    UIGraphicsEndImageContext();
    return blurredSnapshotImage;
}

@end
