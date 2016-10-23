//
//  DragExitGestureRecognizer.m
//  PocketMineSweeper
//
//  Created by 钟立 on 16/10/22.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "DragExitGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface DragExitGestureRecognizer () {
    CGPoint startPoint;
    CGPoint lastPoint;
}

@end

@implementation DragExitGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(nonnull UIEvent *)event {
    if ([touches count] > 1) {
        [self reset];
    }
    UITouch* touch = [touches anyObject];
    if (startPoint.x == 0 && startPoint.y == 0) {
        startPoint = [touch locationInView:self.view];
        lastPoint = startPoint;
    } else {
        [self reset];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(nonnull UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    lastPoint = point;
    
    CGFloat totalDistance = [self getDistanceof:lastPoint and:startPoint];
    if (totalDistance > 40 && self.state == UIGestureRecognizerStatePossible) {
        [self.view touchesEnded:touches withEvent:event];
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self reset];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self reset];
}

- (void)reset {
    startPoint = CGPointZero;
    lastPoint = CGPointZero;
    if (self.state == UIGestureRecognizerStatePossible) {
        [self setState:UIGestureRecognizerStateFailed];
    }
}

- (CGPoint)locationInView:(UIView *)view {
    return startPoint;
}

- (CGFloat)getDistanceof:(CGPoint)pointA and:(CGPoint)pointB {
    CGFloat horizontalDistance = pointA.x - pointB.x;
    CGFloat verticalDistance = pointA.y - pointB.y;
    return sqrt(pow(horizontalDistance, 2) + pow(verticalDistance, 2));
}

@end
