//
//  AppDelegate.m
//  PocketMinesweeper
//
//  Created by 钟立 on 16/8/28.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "AppDelegate.h"
#import "GameView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window;
@synthesize currentPlayerID, gameCenterAuthenticationComplete;

BOOL isGameCenterAPIAvailable()
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));

    return (gcClass != nil);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mainViewController = [[ViewController alloc] init];
    window.rootViewController = mainViewController;
    [window makeKeyAndVisible];
    
    gameCenterAuthenticationComplete = NO;
    
    if (isGameCenterAPIAvailable() == NO) {
        gameCenterAuthenticationComplete = NO;
    } else {
        [self authenticateLocalPlayer];
    }
        
    return YES;
}


- (void)authenticateLocalPlayer {
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController* viewController, NSError* error) {
        if (viewController != nil) {
            [mainViewController presentViewController:viewController animated:YES completion:nil];
        } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            gameCenterAuthenticationComplete = YES;
            
            if (! currentPlayerID || ! [currentPlayerID isEqualToString:localPlayer.playerID]) {
                currentPlayerID = localPlayer.playerID;
            }
            
        } else {
            gameCenterAuthenticationComplete = NO;
        }
        NSLog(@"Error description: %@", error.localizedDescription);
    };
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //timer暂停
    [mainViewController pauseGame];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    gameCenterAuthenticationComplete = NO;

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //timer继续
    [mainViewController continueGame];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
