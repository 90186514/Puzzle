//
//  ImagePickViewController.h
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCutterView.h"
#import "def.h"
#import "ImageManager.h"

@interface ImagePickViewController : UIViewController <UIImagePickerControllerDelegate, ImageCutterViewProtocol, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *picsTableView;
@property (nonatomic, retain) NSMutableArray *imagePrefixsArray;

@property (nonatomic, retain) UIPopoverController *mypopoverController;

@end
