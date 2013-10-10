//
//  DownloadCell.m
//  Puzzle
//
//  Created by Kira on 10/8/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "DownloadCell.h"

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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)finishLoadImage:(UIImage *)img
{
    hasFinishLoad = YES;
    _donwButton.hidden = NO;
    _itemImageView.image = img;
}

@end
