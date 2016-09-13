//
//  _privateRecordList.m
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/7.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "RecordList.h"
#import "Record.h"

@interface RecordList ()

@property (nonatomic) NSMutableArray *privateRecordList;

@end

@implementation RecordList

+ (instancetype)sharedList {
    static RecordList* single;
    if (!single) {
        single = [[RecordList alloc] initPrivate];
    }
    return single;
}

// If someone calls [[RecordList alloc] init], let him know the error of his ways
- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[RecordList sharedList]" userInfo:nil];
}

// Here is the real (secret) initializer
- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        NSArray* documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* path = [documents[0] stringByAppendingPathComponent:@"top5.plist"];
        NSMutableArray* recordArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (recordArray == nil) {
            _privateRecordList = [[NSMutableArray alloc] init];
        } else {
            _privateRecordList = recordArray;
        }
    }
    return self;
}

- (NSArray*)allRecords {
    return [_privateRecordList copy];
}

- (BOOL)checkNeedToUpdateWithTime:(double)newTime {
    
    if (_privateRecordList.count < 5) {
        return YES;
    }
    
    int index = 0;
    while (index < _privateRecordList.count) {
        Record* oldRecord = _privateRecordList[index];
        if (newTime < oldRecord.time) {
            break;
        }
        index += 1;
    }
    
    if (index == 5) {
        //如果挨个比较一遍之后，已经排到了第6位，则没有必要更新records
        return NO;
    } else {
        return YES;
    }
}

- (void)updateTopListWithName:(NSString*)name time:(double)time rowNum:(int)rowNum colNum:(int)colNum mineNum:(int)totalMines{
    
    if ([self checkNeedToUpdateWithTime:time] == NO) {
        return;
    }
    
    NSDate* currentDate = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    NSString* dateString = [dateFormatter stringFromDate:currentDate];
    
    Record* newRecord = [[Record alloc] initWithName:name date:dateString time:time rowNum:rowNum colNum:colNum mineNum:totalMines];
    
    int index = 0;
    
    //checkNeedToUpdateTopList返回YES之后，可以确定一定要加入newRecord，只是看是加在最后面还是插入原有序列中
    //先考虑list不为空的情况，看是否插入新数据，如果是，再检查插入后数组长度是否超过5
    while (index < _privateRecordList.count) {
        Record* oldRecord = _privateRecordList[index];
        if (newRecord.time < oldRecord.time) {
            [_privateRecordList insertObject:newRecord atIndex:index];
            if (_privateRecordList.count == 6) {
                //如果这次插入导致数组超过5个元素，则移出最后一个元素
                [_privateRecordList removeLastObject];
            }
            break;
        }
        index += 1;
    }
    
    if (index == _privateRecordList.count) {
        //如果原records数组的数据都排在本次新数据的前面(包括数组为空的情况)，则直接在后面附加新元素
        [_privateRecordList addObject:newRecord];
    }
    
    NSArray* documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [documents[0] stringByAppendingPathComponent:@"top5.plist"];
    [NSKeyedArchiver archiveRootObject:_privateRecordList toFile:path];
}

@end
