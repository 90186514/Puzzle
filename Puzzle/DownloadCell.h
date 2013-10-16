//
//  DownloadCell.h
//  Puzzle
//
//  Created by Kira on 10/8/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadCell : UITableViewCell
{
    BOOL hasFinishLoad;
}

@property (nonatomic, retain) IBOutlet UIImageView * itemImageView;
@property (nonatomic, retain) IBOutlet UIButton *donwButton;
@property (nonatomic, retain) IBOutlet UILabel *favLabel;
@property (nonatomic, retain) NSString *imagePrefix;

- (void)resetViewImagePrefix:(NSString *)prefix;
- (IBAction)btnDownloadTap:(id)sender;

- (void)setFavour:(NSString *)fav;
- (void)showPayStyle;

@end
