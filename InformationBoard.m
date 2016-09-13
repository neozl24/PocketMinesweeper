//
//  InformationBoard.m
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/1.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "InformationBoard.h"

@implementation InformationBoard

@synthesize delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        height = frame.size.height;
        delegate = self.superview;
        
        restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [restartButton setFrame:CGRectMake(width/2 - 0.3*height, 0.2*height, 0.6*height, 0.6*height)];
        restartButton.layer.borderWidth = 1;
        restartButton.layer.borderColor = [[UIColor colorWithWhite:0.3 alpha:1] CGColor];
    
        [restartButton setImage:[UIImage imageNamed:@"normal.png"] forState:UIControlStateNormal];
        [restartButton setImage:[UIImage imageNamed:@"cautious.png"] forState:UIControlStateHighlighted];
        restartButton.adjustsImageWhenHighlighted = YES;
        
        [restartButton addTarget:delegate action:@selector(getReadyForNewGame) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:restartButton];
        
        CGRect rectLeft = CGRectMake(width/2 - 1.4*height, 0.25*height, height, 0.5*height);
        minesNumView = [[DigitView alloc] initWithFrame:rectLeft];
        [self addSubview:minesNumView];
        
        CGRect rectRight = CGRectMake(width/2 + 0.4*height, 0.25*height, height, 0.5*height);
        secondsView = [[DigitView alloc] initWithFrame:rectRight];
        [self addSubview:secondsView];
        
        showListButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [showListButton setFrame:CGRectMake(width - 0.55*height, 0.3*height, 0.4*height, 0.4*height)];
        showListButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [showListButton setTitle:@"❂" forState:UIControlStateNormal];
        [showListButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        showListButton.titleLabel.font = [UIFont systemFontOfSize:(int)(0.45*height)];
        [showListButton addTarget:delegate action:@selector(showTopList) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:showListButton];
        
        //只有在ios8.0以上的ipad上才添加重置界面的按钮(只有ipad的屏幕才能旋转)
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0
            && [UIScreen mainScreen].bounds.size.width >= 768) {
            reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [reloadButton setFrame:CGRectMake(-height, 0.3*height, 0.4*height, 0.4*height)];
            reloadButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [reloadButton setTitle:@"↻" forState:UIControlStateNormal];
            [reloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            reloadButton.titleLabel.font = [UIFont systemFontOfSize:(int)(0.45*height)];
            [reloadButton addTarget:delegate action:@selector(askIfReload) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:reloadButton];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showReloadButton) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        }
        
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    float border = height/20;
    
    UIColor *middleColor = [UIColor colorWithWhite:0.8 alpha:1];
    UIColor *leftColor = [UIColor colorWithWhite:0.9 alpha:1];
    UIColor *topColor = [UIColor colorWithWhite:0.95 alpha:1];
    UIColor *rightColor = [UIColor colorWithWhite:0.55 alpha:1];
    UIColor *bottomColor = [UIColor colorWithWhite:0.5 alpha:1];
    
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

- (void)setMinesNum:(int)num {
    [minesNumView setDigit:num];
}

- (void)setSeconds:(int)seconds {
    [secondsView setDigit:seconds];
}

- (void)setRestartButtonHightlighted:(BOOL)state {
    restartButton.highlighted = state;
}

- (void)setRestartButtonImageForNormal {
    [restartButton setImage:[UIImage imageNamed:@"normal.png"] forState:UIControlStateNormal];
}

- (void)setRestartButtonImageForWinning {
    [restartButton setImage:[UIImage imageNamed:@"win.png"] forState:UIControlStateNormal];
}

- (void)setRestartButtonImageForFailure {
    [restartButton setImage:[UIImage imageNamed:@"fail.png"] forState:UIControlStateNormal];
}


- (void)showReloadButton {
    [UIView animateWithDuration:2.0 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [reloadButton setFrame:CGRectMake(0.15*height, 0.3*height, 0.4*height, 0.4*height)];
    } completion:nil];

}


@end
