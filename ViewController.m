//
//  ViewController.m
//  Minesweeper
//
//  Created by 钟立 on 16/9/20.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "ViewController.h"
#import "ListViewController.h"
#import "Record.h"
#import "RecordList.h"
#import "CellView.h"
#import "InformationBoard.h"


@interface ViewController () {
    double version;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[NSThread sleepForTimeInterval:3.0];
    
    //这一行是为了提前初始化RecordList，以免在第一次成功完成游戏时，等待输入框弹出时间过长
    [RecordList sharedList];
    
    [self loadGame];
}

//override这个函数可以隐藏顶部statusBar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadGame {
    colNum = self.view.frame.size.width / 40.0;
    side = self.view.frame.size.width / colNum;
    rowNum = self.view.frame.size.height / side - 2.7;
    totalMines = colNum * rowNum / 6.4;
    
    version = [[UIDevice currentDevice].systemVersion doubleValue];
    
    [self prepareGameView];
    [self prepareBoardView];
    
    [self addGestureRecognizers];
    
    //准备好新开一局游戏，执行该函数后，用户的第一次点击将初始化好所有格子
    [self getReadyForNewGame];
}

- (void)reloadGame {
    [gameView removeFromSuperview];
    [boardView removeFromSuperview];
    [self loadGame];
}

- (void)prepareGameView {
    CGFloat height = self.view.frame.size.width * rowNum/colNum;
    CGRect frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height);
    CGRect frameBefore = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, height);
    gameView = [[UIView alloc] initWithFrame:frameBefore];
    [self.view addSubview:gameView];
    
    [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^(){gameView.frame = frame;} completion:nil];
    
    [self createCells];
}

- (void)prepareBoardView {
    CGRect boardFrame = CGRectMake(0, 0, self.view.frame.size.width, 2 * side);
    CGRect boardFrameBefore = CGRectMake(0, -4 * side, self.view.frame.size.width, 2 * side);
    boardView = [[InformationBoard alloc] initWithFrame:boardFrameBefore];
    [self.view addSubview:boardView];
    
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){boardView.frame = boardFrame;} completion:nil];
}

- (void)addGestureRecognizers{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [gameView addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer* longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longTap.minimumPressDuration = 0.5;
    [gameView addGestureRecognizer:longTap];
    
    UISwipeGestureRecognizer* swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [gameView addGestureRecognizer:swipeUp];
}

- (void)handleTap:(UITapGestureRecognizer*)sender {
    IntPoint cellPoint = [self transformFromViewPoint:[sender locationInView:gameView]];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (hasBegun == NO && ((CellView*)matrix[cellPoint.y][cellPoint.x]).marked == NO) {\
            //若此次点击是首次点击，则重新绘制棋盘，并开始计时
            [self recreateCellsWithStartPoint:cellPoint];
            hasBegun = YES;
            gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        }
        [self openCellOfRow:cellPoint.y column:cellPoint.x];
    }
    [self amend];
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)sender {
    IntPoint cellPoint = [self transformFromViewPoint:[sender locationInView:gameView]];
    CellView* doubleTapCell = matrix[cellPoint.y][cellPoint.x];
    if (doubleTapCell.detected == YES && doubleTapCell.value > 0 && doubleTapCell.value < 9) {
        [self doubleClickOpenRow:cellPoint.y column:cellPoint.x];
    }
    
    [self amend];
}

- (void)handleLongPress:(UISwipeGestureRecognizer*)sender {
    IntPoint cellPoint = [self transformFromViewPoint:[sender locationInView:gameView]];
    CellView* longPressCell = matrix[cellPoint.y][cellPoint.x];
    
    //这里加上条件判断，确保长按时间之内，mark方法不会重复调用，只会调用一次
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self handleSwipe:sender];
        if (longPressCell.marked == NO) {
            minesLeftToMark -= 1;
            [markedPointSet addObject:[NSValue valueWithCGPoint:CGPointMake(cellPoint.x, cellPoint.y)]];
        } else {
            minesLeftToMark += 1;
            [markedPointSet removeObject:[NSValue valueWithCGPoint:CGPointMake(cellPoint.x, cellPoint.y)]];
        }
        [longPressCell mark];
    }
    
    [self amend];
}

- (void)handleSwipe:(UISwipeGestureRecognizer*)sender {
    IntPoint cellPoint = [self transformFromViewPoint:[sender locationInView:gameView]];
    CellView* swipeCell = matrix[cellPoint.y][cellPoint.x];
    if (swipeCell.marked == NO) {
        minesLeftToMark -= 1;
        [markedPointSet addObject:[NSValue valueWithCGPoint:CGPointMake(cellPoint.x, cellPoint.y)]];
    } else {
        minesLeftToMark += 1;
        [markedPointSet removeObject:[NSValue valueWithCGPoint:CGPointMake(cellPoint.x, cellPoint.y)]];
    }
    [swipeCell mark];
    
    [self amend];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    for (UITouch* t in touches) {
        CGPoint locationPoint = [t locationInView:gameView];
        //touchesBegan是在整个view范围内的，要先判断点击是否落在gameView之内
        if (locationPoint.x > 0 && locationPoint.x < gameView.frame.size.width
            && locationPoint.y > 0 && locationPoint.y < gameView.frame.size.height) {
            IntPoint cellPoint = [self transformFromViewPoint:locationPoint];
            
            //注意cellPoint的坐标值如果是(2,3)，则它在矩阵中的含义是第3排第2个，不是第2排第3个！
            [matrix[cellPoint.y][cellPoint.x] pressDown];
            
            //处于按压状态的格子保存到集合中，在手指离开屏幕时再还原这些格子
            [pressedPointSet addObject:[NSValue valueWithCGPoint:locationPoint]];
            if (hasEnded == NO) {
                [boardView setRestartButtonHightlighted:YES];
            }
        }
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {    
    //某些gesture没法被处理，因此，有的格子被touchesBegan处理后就一直处于pressing的状态，只有这些没有被处理的手势才会送到这个touchesEnded里面来
    while (pressedPointSet.count > 0) {
        NSValue* element = [pressedPointSet anyObject];
        IntPoint cellPoint = [self transformFromViewPoint:[element CGPointValue]];
        [matrix[cellPoint.y][cellPoint.x] restore];
        [pressedPointSet removeObject:element];
    }
    
    [self amend];
}

- (IntPoint)transformFromViewPoint:(CGPoint)viewPoint {
    IntPoint cellPoint;
    cellPoint.x = (int)(viewPoint.x/side);
    cellPoint.y = (int)(viewPoint.y/side);
    return cellPoint;
}

- (void)getReadyForNewGame {
    hasBegun = NO;
    hasEnded = NO;
    success = NO;
    numOfCellsOpened = 0;
    timeUsed = 0;
    minesLeftToMark = totalMines;
    
    pressedPointSet = [[NSMutableSet alloc] init];
    minePointSet = [[NSMutableSet alloc] init];
    markedPointSet = [[NSMutableSet alloc] init];
    
    [gameView setUserInteractionEnabled:YES];
    
    for (int i = 0; i < rowNum; i++) {
        for (int j = 0; j < colNum; j++) {
            [matrix[i][j] reset];
        }
    }
    
    //如果在上一局没有结束的情况下按了restart键，则需要手动结束上一局的gameTimer
    [gameTimer invalidate];
    
    [boardView setRestartButtonImageForNormal];
    [boardView setMinesNum:minesLeftToMark];
    [boardView setSeconds:(int)timeUsed];
    
//    for (Record* eachRecord in [[RecordList sharedList] allRecords]) {
//        NSLog(@"%@, %f", eachRecord.name, eachRecord.time);
//    }
}

- (void)createCells {
    matrix = [[NSMutableArray alloc] init];
    for (int i = 0; i < rowNum; i++) {
        NSMutableArray *cellRow = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < colNum; j++) {
            CGRect frame = CGRectMake(j * side, i * side, side, side);

            CellView* cell = [[CellView alloc] initWithFrame:frame value:0];
            [cellRow addObject:cell];
            [gameView addSubview:cell];
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
    timeUsed += 0.1;
    [boardView setSeconds:(int)timeUsed];
}

- (void)endGame {
    [gameView setUserInteractionEnabled:NO];
    hasEnded = YES;
    [gameTimer invalidate];
    
//    for (int i = 0; i < rowNum; i++) {
//        for (int j = 0; j < colNum; j++) {
//            CellView* cell = matrix[i][j];
//            if (success == NO) {
//                [cell reveal];
//            } else if ( cell.detected == NO && cell.marked == NO) {
//                minesLeftToMark -= 1;
//                [matrix[i][j] mark];
//            }
//        }
//    }
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
        [boardView setMinesNum:minesLeftToMark];
        [boardView setRestartButtonImageForWinning];
        
        if ([[RecordList sharedList] checkNeedToUpdateWithTime:timeUsed] == YES) {
            [self getPlayerName];
        }
    } else {
        [boardView setRestartButtonImageForFailure];
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

- (void)amend {
    [boardView setMinesNum:minesLeftToMark];
    [boardView setRestartButtonHightlighted:NO];
}


- (void)getPlayerName {
    
    if (version < 8.0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"阁下尊姓大名?" message:@"恭喜你刷新了排行榜" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField* nameTextField = [alertView textFieldAtIndex:0];
        nameTextField.placeholder = @"您的大名";
        [alertView show];
        
    } else {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"阁下尊姓大名?" message:@"恭喜你刷新了排行榜" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField){
            textField.placeholder = @"您的大名";
            textField.delegate = self;
        }];
        
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            UITextField* nameTextField = alertController.textFields.firstObject;
            name = nameTextField.text;
            
            [[RecordList sharedList] updateTopListWithName:name time:timeUsed rowNum:rowNum colNum:colNum mineNum:totalMines];
        }];
        [alertController addAction:action];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

//实现委托方法，控制输入名字的长度。但是这个方法也有问题，如果我是粘贴的，就不受其限制了，而且一旦超长了，还不能删除，整个字符串都被定住了，所以我把截取字符串的工作放到了显示部分。
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    return (range.location < 20);
//}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    name = [alertView textFieldAtIndex:0].text;
    [[RecordList sharedList] updateTopListWithName:name time:timeUsed rowNum:rowNum colNum:colNum mineNum:totalMines];
}

- (void)showTopList {
    ListViewController* listViewController = [[ListViewController alloc] init];
    [listViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:listViewController];
    navController.navigationBar.topItem.title = @"英雄榜";
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)askIfReload {
    //这个函数只会在ios8.0及以上的情况下才会运行
    if (version < 8.0) {
        return;
    }
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"重新绘制界面" message:@"旋转iPad屏幕会导致界面失调，点击重置将按当前屏幕方向重新绘制界面。\n\n你也可以点击取消，并旋转回之前的屏幕方向继续游戏。" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:actionCancel];
    
    UIAlertAction* actionConfirm = [UIAlertAction actionWithTitle:@"重置" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        [self reloadGame];
    }];
    [alertController addAction:actionConfirm];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
