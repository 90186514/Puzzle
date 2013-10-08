//
//  ImageCutterView.h
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageCutterMaskView;

@class ImageCutterView;

@protocol ImageCutterViewProtocol <NSObject>

- (void)imageCutterView:(ImageCutterView *)cutter didCutImage:(UIImage *)img;
- (void)imageCutterView:(ImageCutterView *)cutter savePlayWithImage:(UIImage *)img;
- (void)imageCutterView:(ImageCutterView *)cutter playWithImage:(UIImage *)img;

@end

@interface ImageCutterView : UIView
{
    UIScrollView *imageScrollView;
    UIImageView *imageView;
    UIImage *imageCutting;
    ImageCutterMaskView *maskView;
}

@property (nonatomic, assign)id<ImageCutterViewProtocol> delegate;

- (void)setImage:(UIImage *)img;
- (UIImage *)imageCutted;

@end


@interface ImageCutterMaskView : UIView {
@private
    CGRect  _cropRect;
}

- (void)setCropSize:(CGSize)size;
- (CGRect)cropRect;
@end