//
//  CategaryViewController.h
//  Puzzle
//
//  Created by HalloWorld on 13-10-7.
//  Copyright (c) 2013年 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "def.h"
@interface CategaryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSArray *categaryArray;
@property (nonatomic, retain) IBOutlet UITableView *categaryTable;
@property (nonatomic, retain) ASIHTTPRequest *categaryRequest;
@property (nonatomic, retain) ASIHTTPRequest *photoListRequest;
@property (nonatomic, copy) NSString *tempCategaryID;

@end
