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


@interface GameView : UIView{
    
    NSUInteger numOfCellsOpened;
    NSUInteger minesLeftToMark;
    
    BOOL hasBegun;
    BOOL hasEnded;
    BOOL success;
    
    BOOL isVibrationAvailable;
    BOOL is3DTouchAvailable;
    
    NSMutableArray* matrix;
    
    NSMutableSet* pressedPointSet;
    NSMutableSet* minePointSet;
    NSMutableSet* markedPointSet;
}

@property (nonatomic) int rowNum, colNum;
@property (nonatomic) int totalMines;
@property (nonatomic) double timeUsed;
@property (nonatomic) CGFloat side;
@property (nonatomic) NSTimer* gameTimer;

@property (nonatomic, weak) id <GameViewDelegate> delegateToShow;
@property (nonatomic, weak) id <GameControlDelegate> delegateToControl;

- (instancetype)initWithFrame:(CGRect)frame rowNum:(int)rowNum colNum:(int)colNum side:(CGFloat)side;

- (void)addGestureRecognizers;

- (void)getReadyForNewGame;
- (void)endGame;

- (void)createCells;
- (void)recreateCellsWithStartPoint:(IntPoint)cellPoint;

- (IntPoint)transformToIntPointFromViewPoint:(CGPoint)viewPoint;

- (void)openCellOfRow:(int)i column:(int)j;
- (void)doubleClickOpenRow:(int)i column:(int)j;
- (void)spreadAroundOfRow:(int)i column:(int)j;

- (NSArray*)arrayOfSurroundingPointsOfRow:(int)i column:(int)j;

- (void)updateTimer;

- (void)checkAvailability;
- (void)vibrate;

@end







