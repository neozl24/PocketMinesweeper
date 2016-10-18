//
//  BasicView.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/2.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DigitView : UIView {
    float width;
    float height;
    UILabel* digitLabel;
}

@property (nonatomic) NSInteger digit;

- (void)setDigit:(NSInteger)newDigit;

@end
