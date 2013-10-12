//
//  AppDelegate.m
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "def.h"
#import "BWStatusBarOverlay.h"
#import "AppDelegate+ReviewAlert.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:hasSetupData]) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kMinStepRecord];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hasSetupData];
        [self copyFreeToDoc];
    }
    [BWStatusBarOverlay setAnimation:BWStatusBarOverlayAnimationTypeFromTop];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    } else {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_pad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)copyFreeToDoc
{
    NSString *resFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"free"];
    NSArray *subitems = [[NSFileManager defaultManager] subpathsAtPath:resFolder];
    for (int i = 0; i < [subitems count]; i ++) {
        NSString * itemPath = [resFolder stringByAppendingPathComponent:[subitems objectAtIndex:i]];
        NSString *docPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[subitems objectAtIndex:i]];
        [[NSFileManager defaultManager] copyItemAtPath:itemPath toPath:docPath error:nil];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self scheduleAlert];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
