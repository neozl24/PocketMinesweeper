//
//  BasicView.m
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/2.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "DigitView.h"

@implementation DigitView

@synthesize digit;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        height = frame.size.height;
        digit = 0;
        
        CGRect labelRect = CGRectMake(0.1*height, 0.1*height, width-0.2*height, 0.8*height);
        digitLabel = [[UILabel alloc] initWithFrame:labelRect];
        digitLabel.textColor = [UIColor redColor];
        digitLabel.text = @"000";
        digitLabel.textAlignment = NSTextAlignmentCenter;
        int textSize = height * 0.75;
        digitLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:textSize];
        
        [self addSubview:digitLabel];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    float border = height/15;
    
    UIColor *middleColor = [UIColor colorWithWhite:0.15 alpha:1];
    UIColor *leftColor = [UIColor colorWithWhite:0.55 alpha:1];
    UIColor *topColor = [UIColor colorWithWhite:0.5 alpha:1];
    UIColor *rightColor = [UIColor colorWithWhite:0.9 alpha:1];
    UIColor *bottomColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSaveGState(context);
    
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:rect];
    [middleColor setFill];
    [path fill];
    
    UIBezierPath* topPath = [[UIBezierPath alloc] init];
    [topPath moveToPoint:CGPointMake(0, 0)];
    [topPath addLineToPoint:CGPointMake(width, 0)];
    [topPath addLineToPoint:CGPointMake(width-border, border)];
    [topPath addLineToPoint:CGPointMake(border, border)];
    [topPath closePath];
    
    UIBezierPath* rightPath = [[UIBezierPath alloc] init];
    [rightPath moveToPoint:CGPointMake(width, 0)];
    [rightPath addLineToPoint:CGPointMake(width, height)];
    [rightPath addLineToPoint:CGPointMake(width-border, height-border)];
    [rightPath addLineToPoint:CGPointMake(width-border, border)];
    [rightPath closePath];
    
    [topColor setFill];
    [topPath fill];
    
    [rightColor setFill];
    [rightPath fill];
    
    CGContextTranslateCTM(context, width, height);
    CGContextRotateCTM(context, M_PI);
    
    [bottomColor setFill];
    [topPath fill];
    
    [leftColor setFill];
    [rightPath fill];
}

- (void)setDigit:(int)newDigit {
    digit = newDigit;
    digitLabel.text = [NSString stringWithFormat:@"%i",digit];
    if (digit > 999) {
        digitLabel.text = [NSString stringWithFormat:@"999"];
        digitLabel.textColor = [UIColor redColor];
    } else if (digit > 99) {
        digitLabel.text = [NSString stringWithFormat:@"%i",digit];
        digitLabel.textColor = [UIColor redColor];
    } else if (digit > 9) {
        digitLabel.text = [NSString stringWithFormat:@"0%i",digit];
        digitLabel.textColor = [UIColor redColor];
    } else if (digit >= 0) {
        digitLabel.text = [NSString stringWithFormat:@"00%i",digit];
        digitLabel.textColor = [UIColor redColor];
    } else if (digit > -10) {
        digitLabel.text = [NSString stringWithFormat:@"00%i", -digit];
        digitLabel.textColor = [UIColor yellowColor];
    } else if (digit > -100) {
        digitLabel.text = [NSString stringWithFormat:@"0%i", -digit];
        digitLabel.textColor = [UIColor yellowColor];
    } else if (digit > -1000) {
        digitLabel.text = [NSString stringWithFormat:@"%i", -digit];
        digitLabel.textColor = [UIColor yellowColor];
    } else {
        digitLabel.text = [NSString stringWithFormat:@"999"];
        digitLabel.textColor = [UIColor yellowColor];
    }    
}

@end
