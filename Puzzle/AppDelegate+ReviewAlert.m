//
//  AppDelegate+ReviewAlert.m
//  Puzzle
//
//  Created by Kira on 9/16/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "AppDelegate+ReviewAlert.h"
#import "WeiboShareManager.h"



#define kAPPID @"702671084"

#define kCountActiveKey @"kCountActiveKey"

#define kCountActiveAlertWouldShow 1

@implementation AppDelegate (ReviewAlert)

- (void)reviewInApp
{
    NSString *url = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",kAPPID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)scheduleAlert
{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:kCountActiveKey];
    if (count < 0) {
        return;
    }
    count ++;
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:kCountActiveKey];
    if (count != 0 && (count % kCountActiveAlertWouldShow == 0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Review And Share" message:@"Your support is my biggest power!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Review", @"Share on Weibo", @"Share on Twitter", @"Buy It", nil];
        [alert show];
        [alert release];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self reviewInApp];
    }
    else if (buttonIndex == 2) {
        [WeiboShareManager LoginAndShareSina];
    }
    else if (buttonIndex == 3) {
        [WeiboShareManager LoginAndShareTwitter];
    } else if (buttonIndex == 4) {
        [IOSHelper buyNoIad];
    }
}

@end
