//
//  ViewController.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/8/20.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameDelegate.h"


@class InformationView, GameView;

@interface ViewController : UIViewController <UITextFieldDelegate, GameControlDelegate> {

    UIImageView* backgroundImageView;
    GameView* gameView;
    InformationView* boardView;
}

- (void)loadGame;
- (void)reloadGame;
- (void)continueGame;

@end






