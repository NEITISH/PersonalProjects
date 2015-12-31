//
//  GradientView.m
//  Gamblino
//
//  Created by JP Hribovsek on 12/22/13.
//  Copyright (c) 2013 Gamblino. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    CGFloat leftRedComponent;
    CGFloat leftGreenComponent;
    CGFloat leftBlueComponent;
    CGFloat leftAlphaComponent;
    CGFloat rightRedComponent;
    CGFloat rightGreenComponent;
    CGFloat rightBlueComponent;
    CGFloat rightAlphaComponent;
    
    [self.leftColor getRed:&leftRedComponent green:&leftGreenComponent blue:&leftBlueComponent alpha:&leftAlphaComponent];
    [self.rightColor getRed:&rightRedComponent green:&rightGreenComponent blue:&rightBlueComponent alpha:&rightAlphaComponent];
    
    CGFloat components[8] = { leftRedComponent, leftGreenComponent, leftBlueComponent, leftAlphaComponent,  // Start color
        rightRedComponent, rightGreenComponent, rightBlueComponent, rightAlphaComponent }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint leftCenter = CGPointMake(0, CGRectGetMidY(currentBounds));
    CGPoint rightCenter = CGPointMake(currentBounds.size.width, CGRectGetMidY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, leftCenter, rightCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

@end
