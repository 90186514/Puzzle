//
//  PuzzleView.m
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "PuzzleView.h"

#import <QuartzCore/QuartzCore.h>
#import "def.h"

@implementation PuzzleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor purpleColor].CGColor;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor purpleColor].CGColor;
}

- (void)dealloc
{
    self.puzzleItemArray = nil;
    self.tempSelectItem = nil;
    self.delegate = nil;
    self.oriImage = nil;
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)cleanUp
{
    steps = 0;
    self.tempSelectItem = nil;
    for (UIView *sub in [self subviews]) {
        [sub removeFromSuperview];
    }
}

- (void)playWithImage:(UIImage *)image
{
    [self cleanUp];
    if (image != nil) {
        self.oriImage = nil;
        self.oriImage = image;
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < kCountItemsPerLine * kCountItemsPerLine; i ++) {
        //把View的size和image的size分开计算,再由PuzzleItemView自动等比拉伸
        float itemViewWidth = self.bounds.size.width / kCountItemsPerLine;
        float itemImageWidth = _oriImage.size.width / kCountItemsPerLine;
        int row = i / kCountItemsPerLine;
        int line = i % kCountItemsPerLine;
        CGRect r = CGRectMake(0, 0, itemViewWidth, itemViewWidth);
        CGRect rImage = CGRectMake(0, 0, itemImageWidth, itemImageWidth);
        CGRect rItem = CGRectOffset(r, row * itemViewWidth, line * itemViewWidth);
        CGRect rImageItem = CGRectOffset(rImage, row * itemImageWidth, line * itemImageWidth);
        
        CGImageRef imgRef = CGImageCreateWithImageInRect(_oriImage.CGImage, rImageItem);
        UIImage *img = [UIImage imageWithCGImage:imgRef];
        CGImageRelease(imgRef);
        
        PuzzleItemView *item = [[PuzzleItemView alloc] initWithFrame:rItem withIndex:i];
        item.delegate = self;
        [item setItemImage:img];
        [tempArr addObject:item];
        [item release];
    }
    [self randItemsArray:tempArr];
}

- (void)randItemsArray:(NSArray *)arr
{
    srand(time(NULL));
    //产生一个0~72的随机序列数组
    int randIndex[9] = {0};
    int temp[9] = {0};
    for (int i = 0; i < 9; i++) {
        temp[i] = i;
    }
    
    int l = 8;
    for (int i = 0; i < 9; i ++) {
        int t = rand() % (9 - i);
        randIndex[i] = temp[t];
        temp[t] = temp[l];
        l --;
    }
    
    for (int i = 0; i < kCountItemsPerLine * kCountItemsPerLine; i ++) {
        int index = randIndex[i];
        PuzzleItemView *item = [arr objectAtIndex:index];
        int itemWidth = self.bounds.size.width / kCountItemsPerLine;
        int row = i / kCountItemsPerLine;
        int line = i % kCountItemsPerLine;
        CGRect r = CGRectMake(0, 0, itemWidth, itemWidth);
        CGRect rItem = CGRectOffset(r, row * itemWidth, line * itemWidth);
        item.frame = rItem;
        [self addSubview:item];
    }
}

- (CGRect)rectForIndex:(int)index
{
    int itemWidth = self.bounds.size.width / kCountItemsPerLine;
    int row = index / kCountItemsPerLine;
    int line = index % kCountItemsPerLine;
    CGRect r = CGRectMake(0, 0, itemWidth, itemWidth);
    CGRect rItem = CGRectOffset(r, row * itemWidth, line * itemWidth);
    return rItem;
}

- (void)didSelectPuzzleItem:(PuzzleItemView *)item
{
    [self playSelectMusic];
    if (_tempSelectItem == nil) {
        self.tempSelectItem = item;
        [_tempSelectItem setSelect];
    } else {
        if (_tempSelectItem == item) {
            [_tempSelectItem setDiselect];
            self.tempSelectItem = nil;
        } else {
            float dis = [self distanceOfPoint:_tempSelectItem.center point:item.center];
            if (fabsf(dis - (self.bounds.size.width/kCountItemsPerLine)) < 5.0) {//相邻，交换位置
                [self swapItem:_tempSelectItem item:item];
                [_tempSelectItem setDiselect];
                self.tempSelectItem = nil;
                steps ++;
                if (_delegate && [_delegate respondsToSelector:@selector(puzzleViewGame:progressWithStep:)]) {
                    [_delegate puzzleViewGame:self progressWithStep:steps];
                }
                if ([self isPosotionRight]) {
                    //闯关成功
                    [self playGameOverMusic];
                    if (_delegate && [_delegate respondsToSelector:@selector(puzzleViewGameOver:withSteps:)]) {
                        [_delegate puzzleViewGameOver:self withSteps:steps];
                    }
                }
                
            } else {//不相邻，不能交换位置
                [_tempSelectItem setDiselect];
                self.tempSelectItem = item;
                [_tempSelectItem setSelect];
            }
        }
    }
}

- (void)swapItem:(PuzzleItemView *)item1 item:(PuzzleItemView *)item2
{
    [UIView beginAnimations:nil context:nil];
    CGPoint c = item1.center;
    item1.center = item2.center;
    item2.center = c;
    [UIView commitAnimations];
}

- (float)distanceOfPoint:(CGPoint)p1 point:(CGPoint)p2
{
    float dx = p1.x - p2.x;
    float dy = p1.y - p2.y;
    float dis = sqrtf(dx * dx + dy * dy);
    return dis;
}

- (BOOL)isPosotionRight
{
    NSArray *subs = [self subviews];
    for (PuzzleItemView *item in subs) {
        if (![item isPositionRight]) {
            return FALSE;
        }
    }
    return TRUE;
}

- (void)playSelectMusic
{
    if (self.gameEffectPlayer != nil) {
        self.gameEffectPlayer = nil;
    }
    NSString *rs = [[NSBundle mainBundle] pathForResource:@"select" ofType:@"mp3"];
    NSURL *url = [[[NSURL alloc] initFileURLWithPath:rs] autorelease];
    AVAudioPlayer *pl = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.gameEffectPlayer = pl;
    self.gameEffectPlayer.numberOfLoops = 1;
    [pl release];
    
    [self.gameEffectPlayer prepareToPlay];
    [self.gameEffectPlayer play];
}

- (void)playGameOverMusic
{
    if (self.gameEffectPlayer != nil) {
        self.gameEffectPlayer = nil;
    }
    NSString *rs = [[NSBundle mainBundle] pathForResource:@"gameover" ofType:@"mp3"];
    NSURL *url = [[[NSURL alloc] initFileURLWithPath:rs] autorelease];
    AVAudioPlayer *pl = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.gameEffectPlayer = pl;
    self.gameEffectPlayer.numberOfLoops = 1;
    [self.gameEffectPlayer prepareToPlay];
    [self.gameEffectPlayer play];
    [pl release];
}


@end
