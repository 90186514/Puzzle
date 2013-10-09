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
    NSLog(@"%s -> ", __FUNCTION__);
    hasFinishLoad = NO;
    _donwButton.hidden = !hasFinishLoad;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showLoading
{
    _loadingView.hidden = NO;
    [_loadingView startAnimating];
}

- (void)hideLoading
{
    _loadingView.hidden = YES;
}

- (void)resetViewStatus
{
    if (hasFinishLoad) {
        [self hideLoading];
    } else {
        [self showLoading];
    }
}

- (void)finishLoadImage:(UIImage *)img
{
    hasFinishLoad = YES;
    [self resetViewStatus];
    _donwButton.hidden = NO;
}

@end
