//
//  HudController.m
//  HygienePigCustomer
//
//  Created by cd-micleli on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HudController.h"
#import "AppDelegate.h"

static HudController *shareHudController = nil;


@implementation HudController


+ (HudController *)shareHudController {
    
    if (!shareHudController) {
        shareHudController = [[HudController alloc] init];
    }
    
    return shareHudController;
}


- (id)init {
    
    [super init];
    if (self) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma 
#pragma mark Hud View Function

- (void)myTask {
	// Do something usefull in here instead of sleeping ...
	sleep(1);
}

- (void)showWithLabel:(NSString *)text {
    
    HUD = [[MBProgressHUD alloc] initWithView: window];
	HUD.animationType = MBProgressHUDAnimationZoom;
	[HUD show:YES];    
    HUD.labelText = text;
    [window addSubview:HUD];
}

- (void)showWithLabelDissmiss {
    HUD = [[MBProgressHUD alloc] initWithView: window];
	HUD.delegate = self;
	
	[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    [window addSubview:HUD];
}

- (void)showWithLabelDissmiss:(NSString *)text
{
    HUD = [[MBProgressHUD alloc] initWithView: window];
	HUD.delegate = self;
	HUD.labelText = text;
	
	[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    [window addSubview:HUD];
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}


@end
