//
//  TileItemView.h
//  Puzzle
//
//  Created by Kira on 10/12/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileItemView : UIView

@property (nonatomic, retain) NSString *tilePrefix;

- (void)setTilePrefix:(NSString *)tilePrefix;

@end
