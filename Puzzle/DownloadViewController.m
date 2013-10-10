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
        [[ImageManager shareInterface] partAllTileList:list];
        [[ImageManager shareInterface] loadTiltImages];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadTileImage:) name:kNotiNameDidLoadTileImage object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(btnBackTap:)];
    backBtn.tintColor = [UIColor purpleColor];
    self.navigationItem.leftBarButtonItem = [backBtn autorelease];
    if (isPad) {
        UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GreenBack.jpg"]];
        back.frame = self.view.bounds;
        [self.view insertSubview:[back autorelease] atIndex:0];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GreenBack.jpg"]];
    }
}

- (void)btnBackTap:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.photoTable = nil;
    self.photoListArray = nil;
    [super dealloc];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ImageManager shareInterface] localTileImagesArray] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"downloadCell";
    static NSString *identifierPad = @"downloadCell_pad";
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier: ((isPad) ? identifierPad : identifier)];
    if (!cell) {
        NSString *cellNibName = (isPad) ? @"DownloadCell_pad" : @"DownloadCell";
        cell = [[[NSBundle mainBundle] loadNibNamed:cellNibName owner:self options:nil] objectAtIndex:0];
    }
    NSString *tilename = [[[[ImageManager shareInterface] localTileImagesArray] objectAtIndex:indexPath.row] objectForKey:@"path"];
    NSString *tilePath = [[ImageManager shareInterface] tilePathForName:tilename];
    UIImage *img = [UIImage imageWithContentsOfFile:tilePath];
    [cell finishLoadImage:img];
    return cell;
}

- (void)didLoadTileImage:(NSNotification *)noti
{
    [self.photoTable reloadData];
}

@end
