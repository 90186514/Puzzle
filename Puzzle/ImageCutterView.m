//
//  ImageCutterView.m
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "ImageCutterView.h"
#import "def.h"


@implementation ImageCutterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        // Initialization code
        imageScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:imageScrollView];
        
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imageScrollView addSubview:imageView];
        
        maskView = [[ImageCutterMaskView alloc] initWithFrame:self.bounds];
        [maskView setCropSize:((isPad) ? CutterSizePad : CutterSize)];
        [self addSubview:maskView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
        [btn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnPlayTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnSave setBackgroundImage:[UIImage imageNamed:@"btnSavePlay.png"] forState:UIControlStateNormal];
        [btnSave setTitle:NSLocalizedString(@"Save & Play", nil) forState:UIControlStateNormal];
        
        
        [btnSave addTarget:self action:@selector(btnSaveAndPlayTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnSave];
        
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"btnSavePlay.png"] forState:UIControlStateNormal];
        [btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(btnCancelTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnCancel];
        
        if (isPad) {
            //pad
            [btnCancel setFrame:CGRectMake(264, 30, 240, 72)];
            [btn setFrame:CGRectMake(100, 900, 240, 72)];
            [btnSave setFrame:CGRectMake(420, 900, 240, 72)];
        } else {
            [btnCancel setFrame:CGRectMake(100, 20, 120, 36)];
            if (UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM() && [[UIScreen mainScreen] bounds].size.height > 481.0) {
                [btnSave setFrame:CGRectMake(170, 450, 120, 36)];
                [btn setFrame:CGRectMake(30, 450, 120, 36)];
            } else {
                [btnSave setFrame:CGRectMake(170, 400, 120, 36)];
                [btn setFrame:CGRectMake(30, 400, 120, 36)];
            }
        }
    }
    return self;
}

- (void)btnCancelTap:(id)sender
{
    [self removeFromSuperview];
}

- (CGRect)cuttingRect
{
    CGPoint offset = imageScrollView.contentOffset;
    CGRect cutRect = CGRectOffset([maskView cropRect], offset.x, offset.y);
    CGPoint ori = imageView.frame.origin;
    cutRect = CGRectOffset(cutRect, -ori.x, -ori.y);
    if (!isPad) {
        CGPoint ori = cutRect.origin;
        CGSize size = cutRect.size;
        float scale = 720.0 / 300;
        cutRect = CGRectMake(ori.x * scale, ori.y * scale, size.width * scale, size.height * scale);
    }
    return cutRect;
}

- (void)btnDoneTap:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(imageCutterView:didCutImage:)]) {
        [_delegate imageCutterView:self didCutImage:[self imageCutted]];
    }
}

- (void)btnPlayTap:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(imageCutterView:playWithImage:)]) {
        [_delegate imageCutterView:self playWithImage:[self imageCutted]];
    }
}

- (void)btnSaveAndPlayTap:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(imageCutterView:savePlayWithImage:)]) {
        [_delegate imageCutterView:self savePlayWithImage:[self imageCutted]];
    }
}

- (void)dealloc
{
    [imageScrollView release];
    [imageCutting release];
    [imageView release];
    [maskView release];
    self.delegate = nil;
    [super dealloc];
}

- (void)setImage:(UIImage *)img
{
    if (imageCutting != img) {
        [imageCutting release];
        imageCutting = nil;
        imageCutting = [img retain];
    }
    [self layoutUpdate];
}

- (void)layoutUpdate
{
    CGFloat width = imageCutting.size.width * (300 / 720.0);
    CGFloat height = imageCutting.size.height * (300 / 720.0);
    
    CGSize ms = (isPad) ? CutterSizePad : CutterSize;
    imageScrollView.contentSize = CGSizeMake(width + (self.bounds.size.width - ms.width), height + (self.bounds.size.height - ms.height));
    imageView.frame = CGRectMake(0, 0, width, height);
    [imageView setImage:imageCutting];
    imageView.center = CGPointMake(imageScrollView.contentSize.width/2.0, imageScrollView.contentSize.height/2.0);
}

- (UIImage *)imageCutted
{
    CGRect cutRect = [self cuttingRect];
    CGImageRef cuttedImage = CGImageCreateWithImageInRect(imageCutting.CGImage, cutRect);
    UIImage *img = [UIImage imageWithCGImage:cuttedImage];
    return img;
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




@implementation ImageCutterMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

- (void)setCropSize:(CGSize)size {
    CGFloat x = (CGRectGetWidth(self.bounds) - size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - size.height) / 2;
    _cropRect = CGRectMake(x, y, size.width, size.height);
    
    [self setNeedsDisplay];
}

- (CGRect)cropRect {
    return _cropRect;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 1, 1, 1, .6);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor purpleColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, _cropRect, kMaskViewBorderWidth);
    
    CGContextClearRect(ctx, _cropRect);
    
    CGContextMoveToPoint(ctx, _cropRect.origin.x + _cropRect.size.width/3.0, _cropRect.origin.y);
    CGContextAddLineToPoint(ctx, _cropRect.origin.x + _cropRect.size.width/3.0, _cropRect.origin.y + _cropRect.size.height);
    
    CGContextMoveToPoint(ctx, _cropRect.origin.x + _cropRect.size.width/3.0*2, _cropRect.origin.y);
    CGContextAddLineToPoint(ctx, _cropRect.origin.x + _cropRect.size.width/3.0*2, _cropRect.origin.y + _cropRect.size.height);
    
    CGContextMoveToPoint(ctx, _cropRect.origin.x, _cropRect.origin.y + _cropRect.size.height /3.0);
    CGContextAddLineToPoint(ctx, _cropRect.origin.x + _cropRect.size.width, _cropRect.origin.y + _cropRect.size.height /3.0);
    
    CGContextMoveToPoint(ctx, _cropRect.origin.x, _cropRect.origin.y + _cropRect.size.height /3.0*2);
    CGContextAddLineToPoint(ctx, _cropRect.origin.x + _cropRect.size.width, _cropRect.origin.y + _cropRect.size.height /3.0*2);
    
    CGContextStrokePath(ctx);
}
@end

