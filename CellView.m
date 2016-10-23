//
//  CellView.m
//  PocketMinesweeper
//
//  Created by 钟立 on 16/8/20.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "CellView.h"

@implementation CellView

@synthesize marked, detected, pressing, exploded, judgeRight, value;

- (instancetype)initWithFrame:(CGRect)frame value:(int)newValue {
    self = [super initWithFrame:frame];
    
    if (self) {
        //value为9时，代表这个格子就是雷
        self.value = newValue;
        
        marked = NO;
        detected = NO;
        pressing = NO;
        exploded = NO;
        judgeRight = YES;
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)mark {
    if (marked == YES && detected == NO) {
        marked = NO;
    } else if (marked == NO && detected == NO) {
        marked = YES;
    }
    pressing = NO;
    [self setNeedsDisplay];
}

- (void)detect {
    if (marked == NO && detected == NO) {
        detected = YES;
        if (value == 9) {
            exploded = YES;
        }
        [self setNeedsDisplay];
    }
}

- (void)reveal {
    if (value == 9 && detected == NO && marked == NO ) {
        detected = YES;
    } else if (detected == NO && marked == YES && value != 9) {
        detected = YES;
        judgeRight = NO;
    }
    [self setNeedsDisplay];
}

- (void)pressDown {
    if (marked == NO && detected == NO) {
        pressing = YES;
        
        [self setNeedsDisplay];
    }
}

- (void)restore {
    pressing = NO;
    [self setNeedsDisplay];
}

- (void)reset {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    marked = NO;
    detected = NO;
    pressing = NO;
    exploded = NO;
    judgeRight = YES;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat side = viewWidth;
    
    if (detected == NO) {
        //第一部分，当格子处在没有被按下的状态时，绘制它的形状
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, viewWidth, viewHeight)];
        
        UIColor *middleColor = [UIColor colorWithWhite:0.8 alpha:1];
        UIColor *leftColor = [UIColor colorWithWhite:0.9 alpha:1];
        UIColor *topColor = [UIColor colorWithWhite:0.95 alpha:1];
        UIColor *rightColor = [UIColor colorWithWhite:0.55 alpha:1];
        UIColor *bottomColor = [UIColor colorWithWhite:0.5 alpha:1];
        
        if (pressing == YES) {
            //当格子正处在按压的状态之中时，各部分颜色稍微有点变化
            middleColor = [UIColor colorWithWhite:0.7 alpha:1];
            leftColor = [UIColor colorWithWhite:0.55 alpha:1];
            topColor = [UIColor colorWithWhite:0.5 alpha:1];
            rightColor = [UIColor colorWithWhite:0.9 alpha:1];
            bottomColor = [UIColor colorWithWhite:0.95 alpha:1];
        }
        
        [middleColor setFill];
        [path fill];
        
        UIBezierPath* trapezoidPath = [UIBezierPath bezierPath];
        [trapezoidPath moveToPoint:CGPointMake(0, 0)];
        [trapezoidPath addLineToPoint:CGPointMake(side, 0)];
        [trapezoidPath addLineToPoint:CGPointMake(0.9 * side, 0.1 * side)];
        [trapezoidPath addLineToPoint:CGPointMake(0.1 * side, 0.1 * side)];
        [trapezoidPath addLineToPoint:CGPointMake(0, 0)];
        [trapezoidPath closePath];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSaveGState(context);
        
        [topColor setFill];
        [trapezoidPath fill];
        
        CGContextTranslateCTM(context, side, 0);
        CGContextRotateCTM(context, M_PI/2);
        [rightColor setFill];
        [trapezoidPath fill];
        
        CGContextTranslateCTM(context, side, 0);
        CGContextRotateCTM(context, M_PI/2);
        [bottomColor setFill];
        [trapezoidPath fill];
        
        CGContextTranslateCTM(context, side, 0);
        CGContextRotateCTM(context, M_PI/2);
        [leftColor setFill];
        [trapezoidPath fill];
        
        CGContextTranslateCTM(context, side, 0);
        CGContextRotateCTM(context, M_PI/2);
//        CGContextRestoreGState(context);
        
        if (marked == YES) {
            UIBezierPath *stickPath = [UIBezierPath bezierPath];
            [stickPath moveToPoint:CGPointMake(0.3*side, 0.8*side)];
            [stickPath addLineToPoint:CGPointMake(0.7*side, 0.8*side)];
            [stickPath moveToPoint:CGPointMake(0.35*side, 0.75*side)];
            [stickPath addLineToPoint:CGPointMake(0.65*side, 0.75*side)];
            [stickPath moveToPoint:CGPointMake(0.5*side, 0.75*side)];
            [stickPath addLineToPoint:CGPointMake(0.5*side, 0.2*side)];
            stickPath.lineWidth = 0.05*side;
            [stickPath stroke];
            
            UIBezierPath *flagPath = [UIBezierPath bezierPath];
            [flagPath moveToPoint:CGPointMake(0.525*side, 0.175*side)];
            [flagPath addLineToPoint:CGPointMake(0.2*side, 0.35*side)];
            [flagPath addLineToPoint:CGPointMake(0.525*side, 0.5*side)];
            [flagPath closePath];
            [[UIColor redColor] setFill];
            [flagPath fill];
        }
        
    } else {
        //第二部分，当格子已经被按下之后，不再具有立体形状。
        UIColor *fillColor = [UIColor colorWithWhite:0.75 alpha:1];
        [fillColor setFill];
        CGRect grayRect = CGRectMake(0.04*side, 0.04*side, 0.96*side, 0.96*side);
        UIBezierPath* framePath = [UIBezierPath bezierPathWithRect:grayRect];
        [framePath fill];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        [path moveToPoint:CGPointMake(side, 0.02 * side)];
        [path addLineToPoint:CGPointMake(0.02 * side, 0.02 * side)];
        [path addLineToPoint:CGPointMake(0.02 * side, side)];
        
        CGContextRef contextShadow = UIGraphicsGetCurrentContext();
        CGColorRef shadowColor = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
        CGContextSetShadowWithColor(contextShadow, CGSizeMake(1, 1), 1, shadowColor);
        
        path.lineWidth = 0.04 * side;
        UIColor *strokeColor = [UIColor colorWithWhite:0.55 alpha:1];
        [strokeColor set];
        [path stroke];
        
        
        UIImageView* mineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.1*side, 0.1*side, 0.8*side, 0.8*side)];
        mineImageView.image = [UIImage imageNamed:@"Bomb.png"];
        
        if (value == 9 && exploded == NO) {
            //[self drawMineWithAlpha:1];
            [self addSubview:mineImageView];
            
        } else if (judgeRight == NO) {
            //这个格子不是雷，但是被标上了旗子，在游戏因踩雷而结束时，会被打上一个叉
            
            mineImageView.alpha = 0.5;
            [self addSubview:mineImageView];
            //[self drawMineWithAlpha:0.5];
            
            UIBezierPath* crossPath = [UIBezierPath bezierPath];
            [crossPath moveToPoint:CGPointMake(0, 0)];
            [crossPath addLineToPoint:CGPointMake(side, side)];
            [crossPath moveToPoint:CGPointMake(side, 0)];
            [crossPath addLineToPoint:CGPointMake(0, side)];
            
            crossPath.lineWidth = 0.1
            * side;
            [[UIColor colorWithRed:0.99 green:0.15 blue:0.15 alpha:1] set];
            [crossPath stroke];
            
        } else if (value == 9 && exploded == YES) {
            //这个格子是雷，而且被引爆，则背景改成红色
            
            fillColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1];
            [fillColor setFill];
            UIBezierPath* redFramePath = [UIBezierPath bezierPathWithRect:CGRectMake(0.04*side+1, 0.04*side+1, 0.96*side-1, 0.96*side-1)];
            [redFramePath fill];
            
            [self addSubview:mineImageView];
            //[self drawMineWithAlpha:1];
            
//            CGContextRef contextShadow = UIGraphicsGetCurrentContext();
//            CGColorRef shadowColor = [UIColor yellowColor].CGColor;
//            CGContextSetShadowWithColor(contextShadow, CGSizeMake(0, 0), 7, shadowColor);
//            
//            CGPoint explosionPoint = CGPointMake(0.51*side, 0.2*side);
//            UIBezierPath *explosionPath = [UIBezierPath bezierPathWithArcCenter:explosionPoint radius:0.1*side startAngle:0 endAngle:M_PI*2 clockwise:YES];
//            UIColor *fireColor = [UIColor colorWithRed:1 green:0.9 blue:0 alpha:1];
//            [fireColor setFill];
//            [explosionPath fill];
            
        } else if (value != 0) {
            UILabel *numberLabel = [[UILabel alloc] initWithFrame:grayRect];
            numberLabel.text = [NSString stringWithFormat:@"%i", value];
            
            switch (value) {
                case 1:
                    numberLabel.textColor = [UIColor colorWithRed:0.2 green:0.45 blue:0.98 alpha:1];
                    break;
                case 2:
                    numberLabel.textColor = [UIColor colorWithRed:0.1 green:0.6 blue:0.2 alpha:1];
                    break;
                case 3:
                    numberLabel.textColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1];
                    break;
                case 4:
                    numberLabel.textColor = [UIColor colorWithRed:0 green:0.1 blue:0.5 alpha:1];
                    break;
                case 5:
                    numberLabel.textColor = [UIColor colorWithRed:0.55 green:0.2 blue:0.55 alpha:1];
                    break;
                case 6:
                    numberLabel.textColor = [UIColor colorWithRed:0.1 green:0.6 blue:0.6 alpha:1];
                    break;
                case 7:
                    numberLabel.textColor = [UIColor colorWithRed:0.9 green:0.4 blue:0 alpha:1];
                    break;
                case 8:
                    numberLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
                    break;
                    
                default:
                    break;
            }
            numberLabel.font = [UIFont boldSystemFontOfSize: 0.6 * side];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:numberLabel];
        }
        
    }
}

//- (void)drawMineWithAlpha:(CGFloat)alpha {
//    CGFloat side = self.bounds.size.width;
//    
//    UIBezierPath *minePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.25*side, 0.4*side, 0.5*side, 0.45*side)];
//    [[UIColor colorWithWhite:0 alpha:alpha] setFill];
//    
//    [minePath fill];
//    
//    minePath = [UIBezierPath bezierPathWithRect:CGRectMake(0.45*side, 0.35*side, 0.1*side, 0.2*side)];
//    [minePath fill];
//    
//    [minePath moveToPoint:CGPointMake(0.5*side, 0.35*side)];
//    CGPoint arcCenter = CGPointMake(0.5*side+0.7*side, 0.35*side);
//    minePath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:0.7*side startAngle:M_PI endAngle:M_PI*1.08 clockwise:YES];
//    UIColor *strokeColor = [UIColor colorWithWhite:1 alpha:alpha];
//    [strokeColor set];
//    minePath.lineWidth = 0.05*side;
//    [minePath stroke];
//}


@end














