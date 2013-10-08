//
//  PuzzleItemView.h
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PuzzleItemView;

@protocol PuzzleItemViewProtocol <NSObject>

- (void)didSelectPuzzleItem:(PuzzleItemView *)item;

@end

@interface PuzzleItemView : UIView
{
    UIImageView *itemImgView;
    BOOL isSelect;
    int positionIndex;
    CGPoint positionRightOrigin;
}

@property (nonatomic, assign) id<PuzzleItemViewProtocol> delegate;

- (id)initWithFrame:(CGRect)frame withIndex:(int)index;
- (void)setItemImage:(UIImage *)img;

- (void)setSelect;
- (void)setDiselect;
- (BOOL)isSelect;

- (BOOL)isPositionRight;

@end
