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

@interface ImagePickViewController : UIViewController <UIImagePickerControllerDelegate, ImageCutterViewProtocol>
{
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *picsScrollView;
@property (nonatomic, retain) NSMutableArray *imagePathsArray;

@property (nonatomic, retain) UIPopoverController *mypopoverController;

@end
