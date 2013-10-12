//
//  TileItemView.h
//  Puzzle
//
//  Created by Kira on 10/12/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TileItemView;

@protocol TileItemViewProtocol <NSObject>

- (void)didPickTileImage:(TileItemView *)tile;
- (void)didDeleteTileImage:(TileItemView *)tile;

@end

@interface TileItemView : UIView <UIAlertViewDelegate>

@property (nonatomic, retain) NSString *tilePrefix;
@property (nonatomic, assign) id<TileItemViewProtocol> delegate;

- (void)setTilePrefix:(NSString *)tilePrefix;

@end
