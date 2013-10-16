//
//  BuyCoinsViewController.h
//  Puzzle
//
//  Created by Kira on 10/16/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyCoinsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *paymentArray;
}

@property (nonatomic, retain) IBOutlet UITableView *payTableView;

@end
