//
//  PuzzleView.h
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzleItemView.h"
#import <AVFoundation/AVFoundation.h>

@class PuzzleView;

@protocol PuzzleViewProtocol <NSObject>

- (void)puzzleViewGameOver:(PuzzleView *)pView withSteps:(int)steps;
- (void)puzzleViewGame:(PuzzleView *)pView progressWithStep:(int)step;

@end

@interface PuzzleView : UIView <PuzzleItemViewProtocol>
{
    int steps;
}

@property (nonatomic, assign) id<PuzzleViewProtocol> delegate;
@property (nonatomic, retain) UIImage *oriImage;
@property (nonatomic, retain) NSMutableArray *puzzleItemArray;
@property (nonatomic, retain) PuzzleItemView *tempSelectItem;

@property (nonatomic, retain) AVAudioPlayer *gameEffectPlayer;

- (void)playWithImage:(UIImage *)image;

@end
