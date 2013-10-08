//
//  DownloadViewController.m
//  Puzzle
//
//  Created by Kira on 10/8/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "DownloadViewController.h"
#import "def.h"
#import "DownloadCell.h"


@interface DownloadViewController ()

@end

@implementation DownloadViewController

- (id)initWithPhotoList:(NSArray *)list
{
    NSString *nibName = (isPad) ? @"DownloadViewController_pad" : @"DownloadViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        self.photoListArray = list;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.photoTable = nil;
    self.photoListArray = nil;
    [super dealloc];
}

#pragma mark - Table View 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"downloadCell";
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        NSString *cellNibName = (isPad) ? @"DownloadCell" : @"DownloadCell_pad";
        cell = [[[NSBundle mainBundle] loadNibNamed:cellNibName owner:self options:nil] objectAtIndex:0];
    }
    
    return cell;
}

@end
