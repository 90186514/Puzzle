//
//  DownloadCell.m
//  Puzzle
//
//  Created by Kira on 10/8/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "DownloadCell.h"
#import "ImageManager.h"

@implementation DownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    hasFinishLoad = NO;
    _donwButton.hidden = !hasFinishLoad;
}

- (void)dealloc
{
    self.imagePrefix = nil;
    self.itemImageView = nil;
    self.donwButton = nil;
    [super dealloc];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)resetViewImagePrefix:(NSString *)prefix
{
    self.imagePrefix = prefix;
    NSString *tilePath = [[ImageManager shareInterface] tilePathForPrefix:prefix];
    UIImage *tileimg = [UIImage imageWithContentsOfFile:tilePath];
    _itemImageView.image = tileimg;
    
    NSString *bigPath = [[ImageManager shareInterface] bigPicPathForPrefix:prefix];
    _donwButton.hidden = [[NSFileManager defaultManager] fileExistsAtPath:bigPath];
}

- (void)setFavour:(NSString *)fav
{
    if (fav == nil) {
        return ;
    }
    self.favLabel.text = fav;
}

- (IBAction)btnDownloadTap:(id)sender
{
    //Down load big pics
    [[ImageManager shareInterface] loadBigImageWithPrefix:self.imagePrefix];
}

- (void)showPayStyle
{
    [_donwButton setTitle:NSLocalizedString(@"cost10coin", nil) forState:UIControlStateNormal];
}

@end
