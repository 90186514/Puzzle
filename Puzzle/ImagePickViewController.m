//
//  ImagePickViewController.m
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "ImagePickViewController.h"

#import "CategaryViewController.h"

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
        [self.view insertSubview:[back autorelease] atIndex:0];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GoldBack.jpg"]];
    }
    
    [self layoutPicsShow];
}

- (void)picsScrollViewCleanup
{
    for (id ojb in [picsScrollView subviews]) {
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
    picsScrollView.contentSize = CGSizeMake(picsScrollView.bounds.size.width, (row+1) * picWidth);
    
    for (int i = 0; i < [_imagePathsArray count]; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        int row = i / 2;
        int line = i % 2;
        [btn setFrame:CGRectMake(line * picWidth, row * picWidth, picWidth, picWidth)];
        UIImage *img = [UIImage imageWithContentsOfFile:[_imagePathsArray objectAtIndex:i]];
        [btn setImage:img forState:UIControlStateNormal];
        [btn setTag:i];
        [btn addTarget:self action:@selector(btnPicTap:) forControlEvents:UIControlEventTouchUpInside];
        [picsScrollView addSubview:btn];
    }
}

- (void)dealloc
{
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
        [imgPic autorelease];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    ImageCutterView *cutter = [[ImageCutterView alloc] initWithFrame:self.view.bounds];
    [cutter setImage:img];
    cutter.delegate = self;
    [self.view addSubview:[cutter autorelease]];
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
    /*直接以此图片开始游戏
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiNameDidPickerImageToPlay object:img];
    [self dismissModalViewControllerAnimated:YES];
     */
    NSData *data = UIImagePNGRepresentation(img);
    NSString *name = [[[NSDate date] description] stringByAppendingFormat:@".png"];
    [data writeToFile:[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), name] atomically:YES];
    [cutter removeFromSuperview];
    [self layoutPicsShow];
}

- (void)imageCutterView:(ImageCutterView *)cutter savePlayWithImage:(UIImage *)img
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiNameDidPickerImageToPlay object:img];
    NSData *data = UIImagePNGRepresentation(img);
    NSString *name = [[[NSDate date] description] stringByAppendingFormat:@".png"];
    [data writeToFile:[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), name] atomically:YES];
    [self dismissModalViewControllerAnimated:YES];
}

@end
