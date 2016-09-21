//
//  PlayerModel.h
//  PocketMineSweeper
//
//  Created by 钟立 on 16/9/18.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Record.h"

@interface PlayerModel : NSObject {
    NSLock *writeLock;
}
@property (readonly, nonatomic) NSString *storedRecordsFilename;
@property (readonly, nonatomic) NSMutableArray * storedRecords;

// Store score for submission at a later time.
- (void)storeRecord:(Record *)record;

// Submit stored scores and remove from stored scores array.
- (void)resubmitStoredRecords;

// Save store on disk.
- (void)writeStoredRecord;

// Load stored scores from disk.
- (void)loadStoredRecords;

// Try to submit score, store on failure.
- (void)submitRecord:(Record *)record ;

@end
