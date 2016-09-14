//
//  InformationBoard.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/1.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameDelegate.h"
#import "DigitView.h"

@interface InformationBoard : UIView <GameViewDelegate> {
    float width;
    float height;
    DigitView* minesNumView;
    DigitView* secondsView;
    UIButton* restartButton;
    UIButton* showListButton;
    UIButton* reloadButton;
}

@property (nonatomic, weak) id <GameControlDelegate> delegate;

@end
