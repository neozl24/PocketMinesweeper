//
//  AppDelegate.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/8/28.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    ViewController* mainViewController;
}

@property (nonatomic, strong) UIWindow *window;

@property NSString* currentPlayerID;
@property BOOL gameCenterAuthenticationComplete;

@end

