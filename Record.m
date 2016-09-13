//
//  Record.m
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/3.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "Record.h"

@implementation Record


+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _date = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"date"];
        _time = [aDecoder decodeDoubleForKey:@"time"];
        _rowNum = [aDecoder decodeIntForKey:@"row number"];
        _colNum = [aDecoder decodeIntForKey:@"column number"];
        _totalMines = [aDecoder decodeIntForKey:@"mine number"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_date forKey:@"date"];
    [aCoder encodeDouble:_time forKey:@"time"];
    [aCoder encodeInt:_rowNum forKey:@"row number"];
    [aCoder encodeInt:_colNum forKey:@"column number"];
    [aCoder encodeInt:_totalMines forKey:@"mine number"];
}

- (instancetype)initWithName:(NSString*)name date:(NSString*)date time:(double)time rowNum:(int)rowNum colNum:(int)colNum mineNum:(int)totalMines {
    self = [super init];
    if (self) {
        _name = name;
        _date = date;
        _time = time;
        _rowNum = rowNum;
        _colNum = colNum;
        _totalMines = totalMines;
    }
    return self;
}

@end
