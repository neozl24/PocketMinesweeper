//
//  GameDelegate.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/1.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameDelegate <NSObject>

- (void)getReadyForNewGame;
- (void)showTopList;
- (void)askIfReload;

@end
