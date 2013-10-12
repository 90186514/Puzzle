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
    }
    return self;
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
