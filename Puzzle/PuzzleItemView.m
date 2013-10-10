//
//  PuzzleItemView.m
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "PuzzleItemView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PuzzleItemView

- (id)initWithFrame:(CGRect)frame withIndex:(int)index
{
    self = [super initWithFrame:frame];
    if (self) {
        positionRightOrigin = frame.origin;
        positionIndex = index;
        // Initialization code
        isSelect = NO;
        itemImgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:itemImgView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTap:)];
        [self addGestureRecognizer:tap];
        [tap release];
    }
    return self;
}

- (void)itemTap:(UIGestureRecognizer *)ges
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectPuzzleItem:)]) {
        [_delegate didSelectPuzzleItem:self];
    }
}

- (void)setItemImage:(UIImage *)img
{
    [itemImgView setImage:img];
}

- (void)dealloc
{
    self.delegate = nil;
    [itemImgView release];
    [super dealloc];
}

- (void)setSelect
{
    isSelect = YES;
    self.layer.shadowColor = [UIColor purpleColor].CGColor;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowOffset = CGSizeMake(3, 6);
    self.layer.shadowRadius = 10.0;
    [[self superview] bringSubviewToFront:self];
}

- (void)setDiselect
{
    self.layer.shadowOpacity = 0.0;
    isSelect = NO;
}

- (BOOL)isSelect
{
    return isSelect;
}

- (BOOL)isPositionRight
{
    CGPoint originNow = self.frame.origin;
    if ([self distanceAtPoint:originNow point:positionRightOrigin] < 5.0) {
        return TRUE;
    }else {
        return FALSE;
    }
}

- (float)distanceAtPoint:(CGPoint)p1 point:(CGPoint)p2
{
    float disX = p1.x - p2.x;
    float disY = p1.y - p2.y;
    return sqrtf(disX * disX + disY * disY);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
