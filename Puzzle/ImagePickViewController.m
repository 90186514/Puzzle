//
//  ImagePickViewController.m
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "ImagePickViewController.h"

#import "CategaryViewController.h"

#import <QuartzCore/QuartzCore.h>

#define kFloatPicWidth 140.0

#define kFloatPicWidthPad 350.0


@implementation ImagePickViewController

- (id)init
{
    NSString *nibName = (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) ? @"ImagePickViewController_pad" : @"ImagePickViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (isPad) {
        UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GoldBack.jpg"]];
        back.frame = self.view.bounds;
        [self.view insertSubview:back atIndex:0];
        [back release];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GoldBack.jpg"]];
    }
    
    [self layoutPicsShow];
}

- (void)picsScrollViewCleanup
{
    for (id ojb in [_picsScrollView subviews]) {
        if ([ojb isKindOfClass:[UIButton class]]) {
            [ojb removeFromSuperview];
        }
    }
}

- (void)layoutPicsShow
{
    //init images array
    
    float picWidth = (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) ? kFloatPicWidthPad : kFloatPicWidth;
    [self picsScrollViewCleanup];
    self.imagePathsArray = [ImageManager AllPlayImagePaths];
    
    int row = [_imagePathsArray count] /2;
    _picsScrollView.contentSize = CGSizeMake(_picsScrollView.bounds.size.width, (row+1) * picWidth);
    
    for (int i = 0; i < [_imagePathsArray count]; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        int row = i / 2;
        int line = i % 2;
        [btn setFrame:CGRectMake(line * picWidth, row * picWidth, picWidth, picWidth)];
        UIImage *img = [UIImage imageWithContentsOfFile:[_imagePathsArray objectAtIndex:i]];
        [btn setImage:img forState:UIControlStateNormal];
        [btn setTag:i];
        [btn addTarget:self action:@selector(btnPicTap:) forControlEvents:UIControlEventTouchUpInside];
        [_picsScrollView addSubview:btn];
    }
}

- (void)dealloc
{
    [self picsScrollViewCleanup];
    self.picsScrollView = nil;
    self.mypopoverController = nil;
    self.imagePathsArray = nil;
    [super dealloc];
}

- (void)btnPicTap:(UIButton *)sender
{
    NSString *path = [_imagePathsArray objectAtIndex:sender.tag];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiNameDidPickerImageToPlay object:img];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)btnMoreTap:(id)sender
{
    CategaryViewController *cate = [[CategaryViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cate];
    [nav.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    if ([nav.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"head"] forBarMetrics:UIBarMetricsDefault];
        nav.navigationBar.layer.masksToBounds = NO;
        //设置阴影的高度
        nav.navigationBar.layer.shadowOffset = CGSizeMake(0, 3);
        //设置透明度
        nav.navigationBar.layer.shadowOpacity = 0.6;
        nav.navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:nav.navigationBar.bounds].CGPath;
    }
    [self presentModalViewController:nav animated:YES];
    [cate release];
    [nav release];
}


- (IBAction)btnAlbumTap:(id)sender
{
    if (isPad) {
        UIImagePickerController *m_imagePicker = [[UIImagePickerController alloc] init];
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypePhotoLibrary]) {
            m_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            m_imagePicker.delegate = self;
            [m_imagePicker setAllowsEditing:NO];
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:m_imagePicker];
            self.mypopoverController = popover;
            //popoverController.delegate = self;
            
            [self.mypopoverController presentPopoverFromRect:CGRectMake(0, 0, 300, 300) inView:(UIView *)sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            
            //[self presentModalViewController:m_imagePicker animated:YES];
            [popover release];
            [m_imagePicker release];
        }else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Error accessing photo library!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    } else {
        UIImagePickerController *imgPic = [[UIImagePickerController alloc] init];
        imgPic.delegate = self;
        [self presentModalViewController:imgPic animated:YES];
        [imgPic release];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    ImageCutterView *cutter = [[ImageCutterView alloc] initWithFrame:self.view.bounds];
    [cutter setImage:img];
    cutter.delegate = self;
    [self.view addSubview:cutter];
    [cutter release];
    [picker dismissModalViewControllerAnimated:YES];
    if (isPad) {
        [self.mypopoverController dismissPopoverAnimated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}


- (void)imageCutterView:(ImageCutterView *)cutter playWithImage:(UIImage *)img
{
    //保存图片，继续添加其他图片
    [self saveToDocImage:img];
    [cutter removeFromSuperview];
    [self layoutPicsShow];
}

- (void)imageCutterView:(ImageCutterView *)cutter savePlayWithImage:(UIImage *)img
{
    //直接开始游戏
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiNameDidPickerImageToPlay object:img];
    [self saveToDocImage:img];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)saveToDocImage:(UIImage *)img
{
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    NSString *name = [[[NSDate date] description] stringByAppendingFormat:@".jpg"];
    [data writeToFile:[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), name] atomically:YES];
}

@end
