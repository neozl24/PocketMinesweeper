//
//  ViewController.h
//  Minesweeper
//
//  Created by 钟立 on 16/8/20.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameDelegate.h"


@class InformationBoard, GameView;

@interface ViewController : UIViewController <UITextFieldDelegate, GameControlDelegate> {
    
    GameView* gameView;
    InformationBoard* boardView;
    NSString* name;
}

- (void)loadGame;
- (void)reloadGame;

@end






