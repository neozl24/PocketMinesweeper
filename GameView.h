//
//  GameView.h
//  PocketMineSweeper
//
//  Created by 钟立 on 16/9/13.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellView.h"
#import "GameDelegate.h"

struct IntPoint {
    int x;
    int y;
};
typedef struct IntPoint IntPoint;

@interface GameView : UIView {
    int rowNum, colNum;
    int totalMines;
    int minesLeftToMark;
    int numOfCellsOpened;
    CGFloat side;
    double timeUsed;
    
    BOOL hasBegun;
    BOOL hasEnded;
    BOOL success;
    
    NSMutableArray* matrix;
    
    NSMutableSet* pressedPointSet;
    NSMutableSet* minePointSet;
    NSMutableSet* markedPointSet;

}

- (void)addGestureRecognizers;

- (void)getReadyForNewGame;
- (void)endGame;

- (IntPoint)transformToIntPointFromViewPoint:(CGPoint)viewPoint;

- (void)openCellOfRow:(int)i column:(int)j;
- (void)doubleClickOpenRow:(int)i column:(int)j;
- (void)spreadAroundOfRow:(int)i column:(int)j;

- (NSArray*)arrayOfSurroundingPointsOfRow:(int)i column:(int)j;

- (void)amend;


@end
