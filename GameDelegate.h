//
//  GameDelegate.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/1.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameViewDelegate <NSObject>

- (void)setRestartButtonHightlighted:(BOOL)hightlighted;
- (void)setRestartButtonImageForNormal;
- (void)setRestartButtonImageForWinning;
- (void)setRestartButtonImageForFailure;
- (void)setMinesNum:(int)minesNum;
- (void)setSeconds:(int)seconds;

@end


@protocol GameControlDelegate <NSObject>

- (void)getReadyForNewGame;
- (void)pauseGame;
- (void)continueGame;

- (void)getPlayerName;
- (void)showTopList;
- (void)askIfReload;

@end
