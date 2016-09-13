//
//  RecordList.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/7.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Record;

@interface RecordList : NSObject

@property (nonatomic, readonly) NSArray* allRecords;

+ (instancetype)sharedList;

- (BOOL)checkNeedToUpdateWithTime:(double)newTime;

- (void)updateTopListWithName:(NSString*)name time:(double)time rowNum:(int)rowNum colNum:(int)colNum mineNum:(int)totalMines;

@end
