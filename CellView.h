//
//  CellView.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/8/20.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellView : UIView

- (instancetype)initWithFrame:(CGRect)frame value:(int)newValue;

@property (nonatomic) BOOL marked;
@property (nonatomic) BOOL pressing;
@property (nonatomic) BOOL detected;
@property (nonatomic) BOOL exploded;
@property (nonatomic) BOOL judgeRight;
@property (nonatomic) int value;

- (void)mark;
- (void)detect;
- (void)reveal;

- (void)pressDown;
- (void)restore;
- (void)reset;

@end
