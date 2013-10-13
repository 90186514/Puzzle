//
//  TileItemView.m
//  Puzzle
//
//  Created by Kira on 10/12/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "TileItemView.h"
#import "ImageManager.h"

@implementation TileItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.tilePrefix = nil;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureSelector:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        [tap release];
        
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapGestureSelector:)];
        [self addGestureRecognizer:longTap];
        longTap.minimumPressDuration = 0.8;
        longTap.allowableMovement = 15.0;
        [longTap release];
    }
    return self;
}

- (void)tapGestureSelector:(UIGestureRecognizer *)ges
{
    if (_delegate && [_delegate respondsToSelector:@selector(didPickTileImage:)]) {
        [_delegate didPickTileImage:self];
    }
}

- (void)longTapGestureSelector:(UIGestureRecognizer *)longtap
{
    if (longtap.state == UIGestureRecognizerStateBegan) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteImageAlert", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:@"YES", nil];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self deleteThisImage];
    }
}

- (void)deleteThisImage
{
    NSString *bigPicPath = [[ImageManager shareInterface] bigPicPathForPrefix:_tilePrefix];
    NSString *tilePicPath = [[ImageManager shareInterface] tilePathForPrefix:_tilePrefix];
    assert([[NSFileManager defaultManager] removeItemAtPath:bigPicPath error:nil]);
    assert([[NSFileManager defaultManager] removeItemAtPath:tilePicPath error:nil]);
    if (_delegate && [_delegate respondsToSelector:@selector(didDeleteTileImage:)]) {
        [_delegate didDeleteTileImage:self];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (_tilePrefix == nil) {
        return;
    }
    NSString *tPath = [[ImageManager shareInterface] tilePathForPrefix:_tilePrefix];
    UIImage *tileImage = [UIImage imageWithContentsOfFile:tPath];
    [tileImage drawInRect:self.bounds];
}


- (void)dealloc
{
    self.tilePrefix = nil;
    [super dealloc];
}


- (void)setTilePrefix:(NSString *)tilePrefix
{
    if (_tilePrefix == tilePrefix || [_tilePrefix isEqualToString:tilePrefix]) {
        return;
    }
    [_tilePrefix release];
    _tilePrefix = [tilePrefix retain];
    [self setNeedsDisplay];
}

@end
