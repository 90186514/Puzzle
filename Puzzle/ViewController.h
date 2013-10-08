//
//  ViewController.h
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzleView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GADBannerView.h"
#import "IOSHelper.h"


@interface ViewController : UIViewController <UIAlertViewDelegate, PuzzleViewProtocol, GADBannerViewDelegate>
{
    IBOutlet UIButton *btnSelectImage;
    IBOutlet PuzzleView *puzzleView;
    IBOutlet UIProgressView *progressView;
    IBOutlet UILabel *curSecondsLabel;
    IBOutlet UILabel *curStepTitle;
    IBOutlet UILabel *curStepLabel;
    IBOutlet UILabel *minStepTitle;
    IBOutlet UILabel *minStepLabel;
    
    int maxSeconds;
    int currentLevel;
    
    GADBannerView *admobView;
    
    IBOutlet UIButton *btnBut;
    
    IBOutlet UILabel *passLabelPad;
}



@property (nonatomic, retain) UIImage *imagePlaying;
@property (nonatomic, retain) NSTimer *progressTimer;

@end
