//
//  DownloadCell.m
//  Puzzle
//
//  Created by Kira on 10/8/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "DownloadCell.h"
#import "ImageManager.h"
#import "def.h"

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
    self.dataDic = nil;
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
    if ([[_dataDic objectForKey:@"categaryid"] integerValue] == 1) {
        [[ImageManager shareInterface] loadBigImageWithDataDic:_dataDic];
    } else {
        NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"coincount"];
        if (count >= 10) {
            [[ImageManager shareInterface] loadBigImageWithDataDic:_dataDic];
        } else {
            //金币太少了，提醒购买
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"needMoreCoin", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"BuyIt", nil), nil];
            [alert show];
            [alert release];
        }
    }
}

- (void)showPayStyle
{
    [_donwButton setTitle:NSLocalizedString(@"cost10coin", nil) forState:UIControlStateNormal];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiNameNeedMoreCoin object:nil];
    }
}

@end
