//
//  PressGestureRecognizer.m
//  PocketMineSweeper
//
//  Created by 钟立 on 16/10/23.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "PressGestureRecognizer.h"
#import "UIKit/UIGestureRecognizerSubclass.h"

@interface PressGestureRecognizer () {
    CGPoint startPoint;
}

@end

@implementation PressGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(nonnull UIEvent *)event {
    if ([touches count] > 1) {
        [self reset];
    }
    UITouch* touch = [touches anyObject];
    if (startPoint.x == 0 && startPoint.y == 0) {
        startPoint = [touch locationInView:self.view];
    } else {
        [self reset];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(nonnull UIEvent *)event {
    UITouch* touch = [touches anyObject];
    if (self.view.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        if (touch.force > 0.4 * touch.maximumPossibleForce) {
            [self.view touchesEnded:touches withEvent:event];
            self.state = UIGestureRecognizerStateEnded;
        }
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
    if (self.state == UIGestureRecognizerStatePossible) {
        [self setState:UIGestureRecognizerStateFailed];
    }
}

- (CGPoint)locationInView:(UIView *)view {
    return startPoint;
}

@end
