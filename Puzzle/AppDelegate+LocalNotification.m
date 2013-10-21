//
//  AppDelegate+LocalNotification.m
//  Puzzle
//
//  Created by Kira on 10/18/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "AppDelegate+LocalNotification.h"

@implementation AppDelegate (LocalNotification)

- (void)addNewLocalNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    UILocalNotification *newNotification = [[UILocalNotification alloc] init];
    
    if (newNotification) {
        newNotification.timeZone=[NSTimeZone defaultTimeZone];
        newNotification.fireDate=[[NSDate date] dateByAddingTimeInterval:24*60*60];
        newNotification.alertBody = NSLocalizedString(@"localNotification", nil);
        newNotification.soundName = UILocalNotificationDefaultSoundName;
        newNotification.repeatInterval = NSDayCalendarUnit;
        newNotification.alertAction = @"OK";
        newNotification.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
    }
    [newNotification release];
}

@end
