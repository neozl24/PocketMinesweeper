//
//  ListViewController.h
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/6.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GameDelegate.h"
#import "Record.h"

@interface ListViewController : UITableViewController <GKGameCenterControllerDelegate>

@property (nonatomic, weak) id <GameControlDelegate> delegate;

@end
