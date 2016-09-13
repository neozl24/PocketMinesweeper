//
//  Record.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/3.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* date;
@property (nonatomic, assign) double time;
@property (nonatomic, assign) int rowNum, colNum, totalMines;

- (instancetype)initWithName:(NSString*)name date:(NSString*)date time:(double)time rowNum:(int)rowNum colNum:(int)colNum mineNum:(int)totalMines;

@end
