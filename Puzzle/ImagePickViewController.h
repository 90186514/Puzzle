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
#import "TileItemView.h"

@interface ImagePickViewController : UIViewController <UIImagePickerControllerDelegate, ImageCutterViewProtocol, UITableViewDataSource, UITableViewDelegate, TileItemViewProtocol>

@property (nonatomic, retain) IBOutlet UITableView *picsTableView;
@property (nonatomic, retain) NSMutableArray *imagePrefixsArray;
@property (nonatomic, retain) IBOutlet UIButton *diyButton;
@property (nonatomic, retain) IBOutlet UIButton *moreButton;

@property (nonatomic, retain) UIPopoverController *mypopoverController;

@end
