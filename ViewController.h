//
//  ViewController.h
//  Minesweeper
//
//  Created by 钟立 on 16/8/20.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameDelegate.h"

struct IntPoint {
    int x;
    int y;
};
typedef struct IntPoint IntPoint;


@class InformationBoard;

@interface ViewController : UIViewController <UITextFieldDelegate> {
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
    
    UIView* gameView;
    InformationBoard* boardView;
    
    NSTimer* gameTimer;

    NSString* name;
    
}

- (void)loadGame;
- (void)reloadGame;

- (void)addGestureRecognizers;
- (void)prepareGameView;
- (void)prepareBoardView;

- (void)getReadyForNewGame;
- (void)endGame;

- (IntPoint)transformFromViewPoint:(CGPoint)viewPoint;

- (void)openCellOfRow:(int)i column:(int)j;
- (void)doubleClickOpenRow:(int)i column:(int)j;
- (void)spreadAroundOfRow:(int)i column:(int)j;

- (NSArray*)arrayOfSurroundingPointsOfRow:(int)i column:(int)j;

- (void)updateTimer;
- (void)amend;

- (void)getPlayerName;

@end

