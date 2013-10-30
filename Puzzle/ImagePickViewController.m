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

#import "UIImage+Expand.h"

#import "ASIFormDataRequest.h"
#import "BWStatusBarOverlay.h"
#import "HudController.h"
#define kFloatPicWidth 70.0         //tile Image width

#define kFloatPicWidthPad 70.0

#define kCountTilesOneLinePad 9
#define kCountTilesOneLine 4
#define kTagCellTileRoot 101

#define kCountActiveKey @"kCountActiveKey"

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
    [_diyButton setTitle:NSLocalizedString(@"diy", nil) forState:UIControlStateNormal];
    [_moreButton setTitle:NSLocalizedString(@"more", nil) forState:UIControlStateNormal];
    [_longTapNotiLabel setText:NSLocalizedString(@"longTapNotiLabel", nil)];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:kCountActiveKey] > 35) {
        _longTapNotiLabel.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutPicsShow];
}

- (void)layoutPicsShow
{
    //init images array
    self.imagePrefixsArray = [ImageManager AllPlayImagePrefix];
    [self.picsTableView reloadData];
}

- (void)dealloc
{
    self.picsTableView = nil;
    self.mypopoverController = nil;
    self.imagePrefixsArray = nil;
    [super dealloc];
}

- (void)didPickTileImage:(TileItemView *)tile
{
    NSString *pre = [tile tilePrefix];
    UIImage *img = [UIImage imageWithContentsOfFile:[[ImageManager shareInterface] bigPicPathForPrefix:pre]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiNameDidPickerImageToPlay object:img];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didDeleteTileImage:(TileItemView *)tile
{
    [self layoutPicsShow];
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
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];    //调整照片方向
    if (img.size.width < 720 || img.size.height < 720) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"imageSizeToSmall", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return ;
    }
    UIImage *fixOriImage = [self fixOrientation:img];
    ImageCutterView *cutter = [[ImageCutterView alloc] initWithFrame:self.view.bounds];
    [cutter setImage:fixOriImage];
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
    //保存+分享
    [self saveAndShareImage:img];
    [cutter removeFromSuperview];
    [self layoutPicsShow];
}

- (void)saveAndShareImage:(UIImage *)img
{
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    NSString *prefix = [[NSDate date] description];
    NSLog(@"%s -> %@", __FUNCTION__, prefix);
    NSString *name = [prefix stringByAppendingFormat:@".jpg"];
    NSString *tileName = [prefix stringByAppendingFormat:@"_tile.jpg"];
    [data writeToFile:[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), name] atomically:YES];
    
    UIImage *tileImage = [img imageByScalingToSize:CGSizeMake(kFloatPicWidth, kFloatPicWidth)];     //size(70.0, 70.0)
    NSData *tileData = UIImageJPEGRepresentation(tileImage, 1.0);
    [tileData writeToFile:[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), tileName] atomically:YES];
    
    //Post to the server
    [[HudController shareHudController] showWithLabel:@"Loading.."];
    NSString *urlString = [NSString stringWithFormat:@"%@/upload.php", domin];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addPostValue:@"1" forKey:@"categary"];
    [request addData:data withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"photo"];
    [request addData:tileData withFileName:@"photo_tile.jpg" andContentType:@"image/jpeg" forKey:@"photo_tile"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(postImageDidFinish:)];
    [request setDidFailSelector:@selector(postImageDidFail:)];
    [request setUserInfo:[NSDictionary dictionaryWithObject:prefix forKey:@"prefix"]];
    [request startAsynchronous];
}

- (void)postImageDidFinish:(ASIFormDataRequest *)request
{
    [[HudController shareHudController] hudWasHidden];
    NSString *serverPrefix = [request responseString];
    NSString *localPrefix = [[request userInfo] objectForKey:@"prefix"];
    NSString *name = [localPrefix stringByAppendingFormat:@".jpg"];
    NSString *tileName = [localPrefix stringByAppendingFormat:@"_tile.jpg"];
    NSString *path = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), name];
    NSString *tilePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), tileName];
    
    NSString *serverName = [serverPrefix stringByAppendingFormat:@".jpg"];
    NSString *serverTileName = [serverPrefix stringByAppendingFormat:@"_tile.jpg"];
    NSString *serverpath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), serverName];
    NSString *servertilePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), serverTileName];
    
    NSError *er = nil;
    [[NSFileManager defaultManager] moveItemAtPath:path toPath:serverpath error:&er];
    NSAssert(er == nil, [er localizedDescription]);
    [[NSFileManager defaultManager] moveItemAtPath:tilePath toPath:servertilePath error:&er];
    NSAssert(er == nil, [er localizedDescription]);
    [self layoutPicsShow];
}

- (void)postImageDidFail:(ASIFormDataRequest *)request
{
    [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"shareFail", nil) duration:2.0 animated:YES];
    [[HudController shareHudController] hudWasHidden];
}

- (void)saveToDocImage:(UIImage *)img
{
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    NSString *prefix = [[NSDate date] description];
    NSString *name = [prefix stringByAppendingFormat:@".jpg"];
    NSString *tileName = [prefix stringByAppendingFormat:@"_tile.jpg"];
    [data writeToFile:[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), name] atomically:YES];
    
    UIImage *tileImage = [img imageByScalingToSize:CGSizeMake(kFloatPicWidth, kFloatPicWidth)];     //size(70.0, 70.0)
    NSData *tileData = UIImageJPEGRepresentation(tileImage, 1.0);
    [tileData writeToFile:[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), tileName] atomically:YES];
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = (isPad) ? kCountTilesOneLinePad : kCountTilesOneLine;
    int yushu = [self.imagePrefixsArray count] % count;
    NSInteger rows = [self.imagePrefixsArray count] / count + (yushu != 0);
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"defaultcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSInteger countPerCell = (isPad) ? kCountTilesOneLinePad : kCountTilesOneLine;
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        for (UIView *sub in [cell subviews]) {
            [sub removeFromSuperview];
        }
        
        for (int i = 0; i < countPerCell; i ++) {
            TileItemView *tileItem = [[TileItemView alloc] initWithFrame:CGRectMake(i * kFloatPicWidth, 0, kFloatPicWidth, kFloatPicWidth)];
            tileItem.delegate = self;
            tileItem.tag = kTagCellTileRoot + i;
            [cell addSubview:tileItem];
            [tileItem release];
        }
    }
    
    for (int i = 0; i < countPerCell; i ++) {
        NSInteger tileIndex = indexPath.row * countPerCell + i;
        if (tileIndex < [_imagePrefixsArray count]) {
            TileItemView *tileView = (TileItemView *)[cell viewWithTag:kTagCellTileRoot + i];
            NSString *prefix = [_imagePrefixsArray objectAtIndex:tileIndex];
            [tileView setTilePrefix:prefix];
        } else {
            TileItemView *tileView = (TileItemView *)[cell viewWithTag:kTagCellTileRoot + i];
            [tileView setTilePrefix:nil];
        }
    }
    
    
    return cell;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
