//
//  HudController.h
//  HygienePigCustomer
//
//  Created by cd-micleli on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface HudController : NSObject <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    UIWindow *window;
}


+ (HudController *)shareHudController;

- (void)hudWasHidden;
- (void)showWithLabel:(NSString *)text;
- (void)showWithLabelDissmiss;
- (void)showWithLabelDissmiss:(NSString *)text;


@end
