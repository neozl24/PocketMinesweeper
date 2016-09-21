//
//  PlayerModel.m
//  PocketMineSweeper
//
//  Created by 钟立 on 16/9/18.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "PlayerModel.h"

@implementation PlayerModel

@synthesize storedRecords, storedRecordsFilename;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        storedRecordsFilename = [[NSString alloc] initWithFormat:@"%@/%@.storedRecords.plist",path,[GKLocalPlayer localPlayer].playerID];
        [self loadStoredRecords];
        writeLock = [[NSLock alloc] init];
    }
    return self;
}


// Attempt to resubmit the scores.
- (void)resubmitStoredRecords
{
    if (storedRecords) {
        // Keeping an index prevents new entries to be added when the network is down
        NSInteger index = [storedRecords count] - 1;
        while( index >= 0 ) {
            Record* record = [storedRecords objectAtIndex:index];
            [self submitRecord:record];
            [storedRecords removeObjectAtIndex:index];
            index--;
        }
        [self writeStoredRecord];
    }
}

// Load stored scores from disk.
- (void)loadStoredRecords
{
    NSArray* unarchivedObj = [NSKeyedUnarchiver unarchiveObjectWithFile:storedRecordsFilename];
    
    if (unarchivedObj) {
        storedRecords = [[NSMutableArray alloc] initWithArray:unarchivedObj];
        [self resubmitStoredRecords];
    } else {
        storedRecords = [[NSMutableArray alloc] init];
    }
}


// Save stored scores to file.
- (void)writeStoredRecord
{
//    [writeLock lock];
//    NSData * archivedScore = [NSKeyedArchiver archivedDataWithRootObject:storedRecords];
//    NSError * error;
//    [archivedScore writeToFile:storedRecordsFilename options:NSDataWritingFileProtectionNone error:&error];
//    if (error) {
//        //  Error saving file, handle accordingly
//    }
//    [writeLock unlock];
    
    [NSKeyedArchiver archiveRootObject:storedRecords toFile:storedRecordsFilename];
}

// Store score for submission at a later time.
- (void)storeRecord:(Record *)record
{
    [storedRecords addObject:record];
    [self writeStoredRecord];
}

// Attempt to submit a score. On an error store it for a later time.
- (void)submitRecord:(Record *)record
{
    NSString* identifier = [NSString stringWithFormat:@"%i_%i_%i", record.rowNum, record.colNum, record.totalMines];
    GKScore* score = [[GKScore alloc] initWithLeaderboardIdentifier:identifier player:[GKLocalPlayer localPlayer]];
    [score setValue:(100 * record.time)];
    if ([GKLocalPlayer localPlayer].authenticated) {
        if (!score.value) {
            // Unable to validate data.
            return;
        }
        
        // Store the scores if there is an error.
        [GKScore reportScores:[NSArray arrayWithObject:score] withCompletionHandler: ^(NSError *error){
            if (!error || (![error code] && ![error domain])) {
                // Score submitted correctly. Resubmit others
                [self resubmitStoredRecords];
                NSLog(@"提交成功，再提交其它的");
            } else {
                // Store score for next authentication.
                [self storeRecord:record];
                NSLog(@"提交失败，先存起来");
            }
        }];
    }
}

@end
