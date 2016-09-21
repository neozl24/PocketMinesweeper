//
//  self.m
//  PocketMineSweeper
//
//  Created by 钟立 on 16/9/13.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "GameView.h"
#import "RecordList.h"
#import "PlayerModel.h"
#import "Record.h"

@implementation GameView

@synthesize delegateToShow, delegateToControl;
@synthesize rowNum, colNum, totalMines, timeUsed, side;
@synthesize gameTimer;

- (instancetype)initWithFrame:(CGRect)frame rowNum:(int)rows colNum:(int)columns side:(CGFloat)sideLength {
    self = [super initWithFrame:frame];
    if (self) {
        rowNum = rows;
        colNum = columns;
        side = sideLength;
    }
    
    [self createCells];
    [self addGestureRecognizers];
    return self;
}

- (void)getReadyForNewGame {
    hasBegun = NO;
    hasEnded = NO;
    success = NO;
    
    totalMines = colNum * rowNum / 6.4;
    numOfCellsOpened = 0;
    timeUsed = 0;
    minesLeftToMark = totalMines;
    
    pressedPointSet = [[NSMutableSet alloc] init];
    minePointSet = [[NSMutableSet alloc] init];
    markedPointSet = [[NSMutableSet alloc] init];
    
    //如果在上一局没有结束的情况下按了restart键，则需要手动结束上一局的gameTimer
    [gameTimer invalidate];
    
    [self setUserInteractionEnabled:YES];
    
    for (int i = 0; i < rowNum; i++) {
        for (int j = 0; j < colNum; j++) {
            [matrix[i][j] reset];
        }
    }
    
    [delegateToShow setRestartButtonImageForNormal];
    [delegateToShow setMinesNum:minesLeftToMark];
    [delegateToShow setSeconds:(int)timeUsed];
    
}

- (void)addGestureRecognizers{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer* longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longTap.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longTap];
    
    UISwipeGestureRecognizer* swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUp];
}

- (void)handleTap:(UITapGestureRecognizer*)sender {
    IntPoint cellPoint = [self transformToIntPointFromViewPoint:[sender locationInView:self]];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (hasBegun == NO && ((CellView*)matrix[cellPoint.y][cellPoint.x]).marked == NO) {
            //若此次点击是首次点击，则重新绘制棋盘，并开始计时
            [self recreateCellsWithStartPoint:cellPoint];
            hasBegun = YES;
            
            gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        }
        [self openCellOfRow:cellPoint.y column:cellPoint.x];
    }
    
    [delegateToShow setRestartButtonHightlighted:NO];
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)sender {
    IntPoint cellPoint = [self transformToIntPointFromViewPoint:[sender locationInView:self]];
    CellView* doubleTapCell = matrix[cellPoint.y][cellPoint.x];
    if (doubleTapCell.detected == YES && doubleTapCell.value > 0 && doubleTapCell.value < 9) {
        [self doubleClickOpenRow:cellPoint.y column:cellPoint.x];
    }
    
    [delegateToShow setRestartButtonHightlighted:NO];
}

- (void)handleLongPress:(UISwipeGestureRecognizer*)sender {
    
    //这里加上条件判断，确保长按时间之内，mark方法不会重复调用，只会调用一次
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self handleSwipe:sender];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer*)sender {
    IntPoint cellPoint = [self transformToIntPointFromViewPoint:[sender locationInView:self]];
    CellView* swipeCell = matrix[cellPoint.y][cellPoint.x];
    if (swipeCell.marked == NO && swipeCell.detected == NO) {
        minesLeftToMark -= 1;
        [markedPointSet addObject:[NSValue valueWithCGPoint:CGPointMake(cellPoint.x, cellPoint.y)]];
    } else if (swipeCell.marked == YES) {
        minesLeftToMark += 1;
        [markedPointSet removeObject:[NSValue valueWithCGPoint:CGPointMake(cellPoint.x, cellPoint.y)]];
    }
    [swipeCell mark];
    
    [delegateToShow setMinesNum:minesLeftToMark];
    [delegateToShow setRestartButtonHightlighted:NO];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    for (UITouch* t in touches) {
        CGPoint locationPoint = [t locationInView:self];
        
        IntPoint cellPoint = [self transformToIntPointFromViewPoint:locationPoint];
        
        //注意cellPoint的坐标值如果是(2,3)，则它在矩阵中的含义是第3排第2个，不是第2排第3个！
        [matrix[cellPoint.y][cellPoint.x] pressDown];
        
        //处于按压状态的格子保存到集合中，在手指离开屏幕时再还原这些格子
        [pressedPointSet addObject:[NSValue valueWithCGPoint:locationPoint]];
        if (hasEnded == NO) {
            [delegateToShow setRestartButtonHightlighted:YES];
        }
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //某些gesture没法被处理，因此，有的格子被touchesBegan处理后就一直处于pressing的状态，只有这些没有被处理的手势才会送到这个touchesEnded里面来
    while (pressedPointSet.count > 0) {
        NSValue* element = [pressedPointSet anyObject];
        IntPoint cellPoint = [self transformToIntPointFromViewPoint:[element CGPointValue]];
        [matrix[cellPoint.y][cellPoint.x] restore];
        [pressedPointSet removeObject:element];
    }
    
    [delegateToShow setRestartButtonHightlighted:NO];
}

- (IntPoint)transformToIntPointFromViewPoint:(CGPoint)viewPoint {
    IntPoint cellPoint;
    cellPoint.x = (int)(viewPoint.x/side);
    cellPoint.y = (int)(viewPoint.y/side);
    return cellPoint;
}

- (void)createCells {
    matrix = [[NSMutableArray alloc] init];
    for (int i = 0; i < rowNum; i++) {
        NSMutableArray *cellRow = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < colNum; j++) {
            CGRect frame = CGRectMake(j * side, i * side, side, side);
            
            CellView* cell = [[CellView alloc] initWithFrame:frame value:0];
            [cellRow addObject:cell];
            [self addSubview:cell];
        }
        [matrix addObject:cellRow];
    }
}

- (void)recreateCellsWithStartPoint:(IntPoint)cellPoint {
    
    //先用一个一维数组，来表示所有的格子，并在其中随机生成雷
    NSMutableArray *mineIndexArray = [NSMutableArray arrayWithCapacity:totalMines];
    //要保证按下的第一个格子不能是雷
    int safeIndex = cellPoint.x + cellPoint.y * colNum;
    int index;
    for (int i = 0; i < totalMines; i++) {
        index = arc4random()%(rowNum*colNum);
        if ([mineIndexArray containsObject:@(index)]) {
            i -= 1;
        } else if (index == safeIndex) {
            i -= 1;
        } else {
            [mineIndexArray addObject:@(index)];
        }
    }
    
    //先把有雷的格子设置出来
    for (int i = 0; i < rowNum; i++) {
        for (int j = 0; j < colNum; j++) {
            int value = 0;
            if ([mineIndexArray containsObject:@(i * colNum + j)] == YES) {
                value = 9;
                [minePointSet addObject:[NSValue valueWithCGPoint:CGPointMake(j, i)]];
            }
            ((CellView*)matrix[i][j]).value = value;
        }
    }
    
    //再根据有雷的格子把会显示数字的格子设置出来
    for (int i = 0; i < rowNum; i++) {
        for (int j = 0; j < colNum; j++) {
            
            if (((CellView*)matrix[i][j]).value == 0) {
                NSArray* surroundingPoints = [self arrayOfSurroundingPointsOfRow:i column:j];
                for (NSValue* element in surroundingPoints) {
                    CGPoint point = [element CGPointValue];
                    int pi = point.y;
                    int pj = point.x;
                    
                    //有雷的格子value值是9，除以9之后会得到1，而其他任何格子的value除以8后都只能得到0
                    ((CellView*)matrix[i][j]).value += ( (CellView*)matrix[pi][pj] ).value/9;
                }
            }
        }
    }
}

- (void)updateTimer {
    timeUsed += 0.01;
    [delegateToShow setSeconds:(int)timeUsed];
}

- (void)endGame {
    [self setUserInteractionEnabled:NO];
    hasEnded = YES;
    [gameTimer invalidate];
    
    //下面这个集合是所有有雷的格子和所有被标上旗子的格子的并集
    NSSet* pointsNeedToReveal = [minePointSet setByAddingObjectsFromSet:markedPointSet];
    
    for (NSValue* element in pointsNeedToReveal) {
        CGPoint cellPoint = [element CGPointValue];
        int i = cellPoint.y;
        int j = cellPoint.x;
        
        if (success == NO) {
            [matrix[i][j] reveal];
        } else if ( ((CellView*)matrix[i][j]).marked == NO) {
            [matrix[i][j] mark];
        }
        
    }
    
    if (success == YES) {
        minesLeftToMark = 0;
        [delegateToShow setMinesNum:minesLeftToMark];
        [delegateToShow setRestartButtonImageForWinning];
        
        if ([[RecordList sharedList] checkNeedToUpdateWithTime:timeUsed] == YES) {
            [delegateToControl getPlayerName];
            
            //游戏失败震一下，成功震两下，如果破本地纪录再震第三下
            [self performSelector:@selector(vibrate) withObject:nil afterDelay:1.5];
        }
        
        NSString* name = [GKLocalPlayer localPlayer].displayName;
        
        NSDate* currentDate = [NSDate date];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY/MM/dd"];
        NSString* dateString = [dateFormatter stringFromDate:currentDate];
        
        Record* recordForGameCenter = [[Record alloc] initWithName:name date:dateString time:timeUsed rowNum:rowNum colNum:colNum mineNum:totalMines];
        PlayerModel* player = [[PlayerModel alloc] init];
        
        [player submitRecord:recordForGameCenter];
        
        [self vibrate];
        [self performSelector:@selector(vibrate) withObject:nil afterDelay:0.7];
        
    } else {
        [delegateToShow setRestartButtonImageForFailure];
        
        [self vibrate];
    }
    
}


- (void)openCellOfRow:(int)i column:(int)j {
    CellView* targetCell = matrix[i][j];
    
    if (targetCell.detected == NO && targetCell.marked == NO) {
        [targetCell detect];
        
        if (targetCell.value == 9) {
            [self endGame];
            return;
        } else if (targetCell.value > 0) {
            //之所以把gesture加在这里，而不是整体的gameView里面，是因为不希望还未点开的格子就能够接收双击指令，否则有可能直接延展了某个未知格子而导致无意踩雷
            UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
            doubleTap.numberOfTapsRequired = 2;
            [targetCell addGestureRecognizer:doubleTap];
        }
        
        numOfCellsOpened += 1;
        if (numOfCellsOpened == rowNum * colNum - totalMines) {
            success = YES;
            [self endGame];
            return;
        }
        
        if(targetCell.value == 0){
            [self spreadAroundOfRow:i column:j];
        }
    }
}

- (void)doubleClickOpenRow:(int)i column:(int)j {
    
    CellView* targetCell = matrix[i][j];
    if (targetCell.detected == NO || targetCell.value == 0) {
        return;
    }
    
    int totalMarkAround = 0;
    NSArray* surroundingPoints = [self arrayOfSurroundingPointsOfRow:i column:j];
    for (NSValue* element in surroundingPoints) {
        CGPoint point = [element CGPointValue];
        int pi = point.y;
        int pj = point.x;
        if (((CellView*)matrix[pi][pj]).marked == YES) {
            totalMarkAround += 1;
        }
    }
    //数字格周围的标旗数量恰好等于自身数字时，双击才能点开周围一圈格子
    if (totalMarkAround == targetCell.value) {
        [self spreadAroundOfRow:i column:j];
        
    } else {
        NSArray* surroundingPoints = [self arrayOfSurroundingPointsOfRow:i column:j];
        for (NSValue* element in surroundingPoints) {
            CGPoint point = [element CGPointValue];
            int i = point.y;
            int j = point.x;
            CellView* cell = matrix[i][j];
            [cell pressDown];
            [cell performSelector:@selector(restore) withObject:nil afterDelay:0.15];
        }
    }
}

- (void)spreadAroundOfRow:(int)i column:(int)j {
    NSArray* surroundingPoints = [self arrayOfSurroundingPointsOfRow:i column:j];
    for (NSValue* element in surroundingPoints) {
        CGPoint point = [element CGPointValue];
        [self openCellOfRow:point.y column:point.x];
    }
}

- (NSArray*)arrayOfSurroundingPointsOfRow:(int)i column:(int)j {
    NSArray* arrayOfSurroundingPoints = [[NSArray alloc] init];
    if (i == 0 && j == 0) {
        arrayOfSurroundingPoints = @[[NSValue valueWithCGPoint:CGPointMake(j+1, i)], [NSValue valueWithCGPoint:CGPointMake(j+1, i+1)], [NSValue valueWithCGPoint:CGPointMake(j, i+1)]];
    } else if (i == 0 && j == colNum-1) {
        arrayOfSurroundingPoints = @[[NSValue valueWithCGPoint:CGPointMake(j-1, i)], [NSValue valueWithCGPoint:CGPointMake(j-1, i+1)], [NSValue valueWithCGPoint:CGPointMake(j, i+1)]];
    } else if (i == rowNum-1 && j == 0) {
        arrayOfSurroundingPoints = @[[NSValue valueWithCGPoint:CGPointMake(j, i-1)], [NSValue valueWithCGPoint:CGPointMake(j+1, i-1)], [NSValue valueWithCGPoint:CGPointMake(j+1, i)]];
    } else if (i == rowNum-1 && j == colNum-1) {
        arrayOfSurroundingPoints = @[[NSValue valueWithCGPoint:CGPointMake(j, i-1)], [NSValue valueWithCGPoint:CGPointMake(j-1, i-1)], [NSValue valueWithCGPoint:CGPointMake(j-1, i)]];
        
    } else if (i == 0) {
        arrayOfSurroundingPoints = @[[NSValue valueWithCGPoint:CGPointMake(j+1, i)], [NSValue valueWithCGPoint:CGPointMake(j+1, i+1)], [NSValue valueWithCGPoint:CGPointMake(j, i+1)], [NSValue valueWithCGPoint:CGPointMake(j-1, i+1)], [NSValue valueWithCGPoint:CGPointMake(j-1, i)]];
    } else if (i == rowNum-1) {
        arrayOfSurroundingPoints = @[[NSValue valueWithCGPoint:CGPointMake(j-1, i)], [NSValue valueWithCGPoint:CGPointMake(j-1, i-1)], [NSValue valueWithCGPoint:CGPointMake(j, i-1)], [NSValue valueWithCGPoint:CGPointMake(j+1, i-1)], [NSValue valueWithCGPoint:CGPointMake(j+1, i)]];
    } else if (j == 0) {
        arrayOfSurroundingPoints = @[[NSValue valueWithCGPoint:CGPointMake(j, i-1)], [NSValue valueWithCGPoint:CGPointMake(j+1, i-1)], [NSValue valueWithCGPoint:CGPointMake(j+1, i)], [NSValue valueWithCGPoint:CGPointMake(j+1, i+1)], [NSValue valueWithCGPoint:CGPointMake(j, i+1)]];
    } else if (j == colNum-1) {
        arrayOfSurroundingPoints = @[[NSValue valueWithCGPoint:CGPointMake(j, i-1)], [NSValue valueWithCGPoint:CGPointMake(j-1, i-1)], [NSValue valueWithCGPoint:CGPointMake(j-1, i)], [NSValue valueWithCGPoint:CGPointMake(j-1, i+1)], [NSValue valueWithCGPoint:CGPointMake(j, i+1)]];
        
    } else {
        arrayOfSurroundingPoints = @[[NSValue valueWithCGPoint:CGPointMake(j, i-1)], [NSValue valueWithCGPoint:CGPointMake(j+1, i-1)], [NSValue valueWithCGPoint:CGPointMake(j+1, i)], [NSValue valueWithCGPoint:CGPointMake(j+1, i+1)], [NSValue valueWithCGPoint:CGPointMake(j, i+1)], [NSValue valueWithCGPoint:CGPointMake(j-1, i+1)], [NSValue valueWithCGPoint:CGPointMake(j-1, i)], [NSValue valueWithCGPoint:CGPointMake(j-1, i-1)]];
    }
    return arrayOfSurroundingPoints;
}

- (void)vibrate {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"forbiddenVibrate"]) {
        return;
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
