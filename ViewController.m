//
//  ViewController.m
//  Minesweeper
//
//  Created by 钟立 on 16/9/20.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "ViewController.h"
#import "ListViewController.h"
#import "RecordList.h"
#import "InformationBoard.h"
#import "GameView.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    int colNum = width / 40.0;
    CGFloat side = width / colNum;
    int rowNum = height/ side - 2.7;
    CGFloat gameViewHeight = width * rowNum/colNum;
    CGRect frameBeforeLoading = CGRectMake(0, height, width, gameViewHeight);
    CGRect frameAfterLoading = CGRectMake(0, height - gameViewHeight, width, gameViewHeight);
    
    gameView = [[GameView alloc] initWithFrame:frameBeforeLoading rowNum:rowNum colNum:colNum side:side];
    [self.view addSubview:gameView];
    
    [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^(){gameView.frame = frameAfterLoading;} completion:nil];
    
    CGRect boardFrameAfterLoading = CGRectMake(0, 0, width, 2 * side);
    CGRect boardFrameBeforeLoading = CGRectMake(0, -4 * side, width, 2 * side);
    boardView = [[InformationBoard alloc] initWithFrame:boardFrameBeforeLoading];
    [self.view addSubview:boardView];
    
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        boardView.frame = boardFrameAfterLoading;} completion:nil];
    
    gameView.delegateToControl = self;
    gameView.delegateToShow = boardView;
    boardView.delegate = self;
    
    //准备好新开一局游戏，执行该函数后，用户的第一次点击将初始化好所有格子
    [gameView getReadyForNewGame];
}

- (void)reloadGame {
    [gameView removeFromSuperview];
    [boardView removeFromSuperview];
    [self loadGame];
}

- (void)getReadyForNewGame {
    [gameView getReadyForNewGame];
}

- (void)getPlayerName {
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"阁下尊姓大名?" message:@"恭喜你刷新了排行榜" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField){
        textField.placeholder = @"您的大名";
        textField.delegate = self;
    }];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        UITextField* nameTextField = alertController.textFields.firstObject;
        name = nameTextField.text;
        
        [[RecordList sharedList] updateTopListWithName:name time:gameView.timeUsed rowNum:gameView.rowNum colNum:gameView.colNum mineNum:gameView.totalMines];
    }];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)showTopList {
    ListViewController* listViewController = [[ListViewController alloc] init];
    [listViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:listViewController];
    navController.navigationBar.topItem.title = @"英雄榜";
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)askIfReload {
    
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
