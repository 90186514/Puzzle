//
//  ViewController.m
//  Puzzle
//
//  Created by Kira on 8/30/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "ViewController.h"
#import "ImageCutterView.h"
#import "ImagePickViewController.h"
#import "ImageManager.h"
#import <QuartzCore/QuartzCore.h>
#import "BWStatusBarOverlay.h"
#import "GCHelper.h"


//Mj a151ff3b64d2b1b
//PP a1527af25b1d5a0
#define MY_BANNER_UNIT_ID @"a1527af25b1d5a0"   

#define playableMaxSeconds 33

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    admobView = nil;
    currentLevel = 0;
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiDidPickImageToPlay:) name:kNotiNameDidPickerImageToPlay object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasBuyIad:) name:@"noiad" object:nil];
    
    puzzleView.delegate = self;
    curSecondsLabel.text = [NSString stringWithFormat:@"%dS", playableMaxSeconds];
    
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        [self layoutViewPad];
    } else {
        [self layoutViewPhone];
    }
}

- (void)layoutViewPhone
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GreenBack.jpg"]];
    self.progressTimer = nil;
    minStepLabel.text = [NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:kMinStepRecord]];
    minStepTitle.text = NSLocalizedString(@"minStepTitle", nil);
    curStepTitle.text = NSLocalizedString(@"curStepTitle", nil);
}

- (void)layoutViewPad
{
    UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GreenBack.jpg"]];
    back.frame = self.view.bounds;
    [self.view insertSubview:[back autorelease] atIndex:0];
    self.progressTimer = nil;
    minStepLabel.text = [NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:kMinStepRecord]];
    minStepTitle.text = NSLocalizedString(@"minStepTitle", nil);
    curStepTitle.text = NSLocalizedString(@"curStepTitle", nil);
}

- (void)hasBuyIad:(NSNotification *)noti
{
    [btnBut removeFromSuperview];
    admobView.delegate = nil;
    [admobView removeFromSuperview];
    [admobView release];
    admobView = nil;
}

- (void)didBecomeActive
{
    if ([btnSelectImage imageForState:UIControlStateNormal] != nil) {
        [self restartRandomImage];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"noiad"]) {
        [self loadAdmobView];
    } else {
        btnBut.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [puzzleView release];
    [super dealloc];
}

#pragma mark - Action

- (IBAction)btnSelectImageTap:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    if ([sender imageForState:UIControlStateNormal] == nil) {
        [self showImagePicker];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"restart", nil) delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        [alert release];
    }
}


- (void)showImagePicker
{
    ImagePickViewController *picker = [[ImagePickViewController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //NO
    } else if (buttonIndex == 1) {
        if ([_progressTimer isValid]) {
            [_progressTimer invalidate];
        }
        self.progressTimer = nil;
        [self showImagePicker];
    }
}


- (void)notiDidPickImageToPlay:(NSNotification *)noti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    UIImage *imageToPlay = [noti object];
    [self playWithImage:imageToPlay];
}

- (void)playWithImage:(UIImage *)img
{
    [btnSelectImage setImage:img forState:UIControlStateNormal];
    [puzzleView playWithImage:img];
    //schedule
    maxSeconds = playableMaxSeconds;
    [self updateProgerssView];
    if (_progressTimer != nil && [_progressTimer isValid]) {
        [_progressTimer invalidate];
    }
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(progressTimerSchedule:) userInfo:nil repeats:YES];
}

- (void)restartRandomImage
{
    srand(time(NULL));
    NSMutableArray *arr = [ImageManager AllPlayImagePrefix];
    int ran = random() % [arr count];
    NSString *path = [[ImageManager shareInterface] bigPicPathForPrefix:[arr objectAtIndex:ran]];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    [self playWithImage:img];
    [self animationPuzzleView];
}

- (void)showMessagePad:(NSString *)msg
{
    passLabelPad.hidden = NO;
    passLabelPad.alpha = 1.0;
    passLabelPad.text = msg;
    [self hideMessagePad];
}

- (void)hideMessagePad
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:2.0];
    [UIView setAnimationDuration:2.5];
    [UIView setAnimationRepeatCount:3.0];
    passLabelPad.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)puzzleViewGameOver:(PuzzleView *)pView withSteps:(int)steps
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"levelSuccess", nil) duration:5.0 animated:YES];
    if (isPad) {
        [self showMessagePad:NSLocalizedString(@"levelSuccess", nil)];
    }
    currentLevel ++;
    [self performSelector:@selector(restartRandomImage) withObject:nil afterDelay:2.0];
    [self updateLevel];
    if ([_progressTimer isValid]) {
        [_progressTimer invalidate];
        self.progressTimer = nil;
    }
}

- (void)updateLevel
{
    curStepLabel.text = [NSString stringWithFormat:@"%d", currentLevel];
    int record = [[NSUserDefaults standardUserDefaults] integerForKey:kMinStepRecord];
    if (currentLevel > record) {
        [[NSUserDefaults standardUserDefaults] setInteger:currentLevel forKey:kMinStepRecord];
        minStepLabel.text = [NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:kMinStepRecord]];
        [[GCHelper shareInterface] reportTopLevelScore:currentLevel];
    }
}



- (void)progressTimerSchedule:(NSTimer *)timer
{
    maxSeconds --;
    [curSecondsLabel setText:[NSString stringWithFormat:@"%dS", maxSeconds]];
    [self updateProgerssView];
    if (maxSeconds <= 0) {
        [_progressTimer invalidate];
        self.progressTimer = nil;
        //时间用完,游戏结束TODO...
        currentLevel = currentLevel -2;     //闯关失败倒退两关
        if (currentLevel < 0) {
            currentLevel = 0;
        }
        [self updateLevel];
        [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"levelFaild", nil) duration:5.0 animated:YES];
        if (isPad) {
            [self showMessagePad:NSLocalizedString(@"levelFaild", nil)];
        }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self restartRandomImage];
    }
}

- (void)updateProgerssView
{
    float pro = ((float)maxSeconds)/playableMaxSeconds;
    [progressView setProgress:pro animated:YES];
}

- (void)animationPuzzleView
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	//设置动画持续时间
	[UIView setAnimationDuration:1.0];
	//因为没给viewController类添加成员变量，所以用下面方法得到viewDidLoad添加的子视图
    
	UIView *parentView = puzzleView;
	//设置动画效果
//	[UIView setAnimationTransition: UIViewAnimationTransitionCurlDown forView:parentView cache:YES];  //从上向下
    
	//	[UIView setAnimationTransition: UIViewAnimationTransitionCurlUp forView:parentView cache:YES];   //从下向上
    
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:parentView cache:YES];  //从左向右
    
	//	[UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:parentView cache:YES];//从右向左
	//设置动画委托

//	[UIView setAnimationDelegate:self];
	//当动画执行结束，执行animationFinished方法
//	[UIView setAnimationDidStopSelector:@selector(animationFinished:)];
	//提交动画
    
	[UIView commitAnimations];
}

- (void)loadAdmobView
{
    if (admobView != nil) {
        return ;
    }
    // 在屏幕底部创建标准尺寸的视图。
    if (isPad) {
        admobView = [[GADBannerView alloc]
                     initWithFrame:CGRectMake(0.0,
                                              self.view.frame.size.height -
                                              GAD_SIZE_728x90.height,
                                              GAD_SIZE_728x90.width,
                                              GAD_SIZE_728x90.height)];
    } else {
        admobView = [[GADBannerView alloc]
                     initWithFrame:CGRectMake(0.0,
                                              self.view.frame.size.height -
                                              GAD_SIZE_320x50.height,
                                              GAD_SIZE_320x50.width,
                                              GAD_SIZE_320x50.height)];
    }
    
    // 指定广告的“单元标识符”，也就是您的 AdMob 发布商 ID。
    admobView.adUnitID = MY_BANNER_UNIT_ID;
    
    // 告知运行时文件，在将用户转至广告的展示位置之后恢复哪个 UIViewController
    // 并将其添加至视图层级结构。
    admobView.rootViewController = self;
    [self.view addSubview:admobView];
    
    // 启动一般性请求并在其中加载广告。
    [admobView loadRequest:[GADRequest request]];
    admobView.delegate = self;
}

#pragma mark Admob Request Lifecycle Notifications


// Sent when an ad request loaded an ad.  This is a good opportunity to add this
// view to the hierarchy if it has not yet been added.  If the ad was received
// as a part of the server-side auto refreshing, you can examine the
// hasAutoRefreshed property of the view.
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"%s -> ", __FUNCTION__);
}

// Sent when an ad request failed.  Normally this is because no network
// connection was available or no ads were available (i.e. no fill).  If the
// error was received as a part of the server-side auto refreshing, you can
// examine the hasAutoRefreshed property of the view.
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%s -> %@", __FUNCTION__, [error userInfo]);
}


// Sent just before presenting the user a full screen view, such as a browser,
// in response to clicking on an ad.  Use this opportunity to stop animations,
// time sensitive interactions, etc.
//
// Normally the user looks at the ad, dismisses it, and control returns to your
// application by calling adViewDidDismissScreen:.  However if the user hits the
// Home button or clicks on an App Store link your application will end.  On iOS
// 4.0+ the next method called will be applicationWillResignActive: of your
// UIViewController (UIApplicationWillResignActiveNotification).  Immediately
// after that adViewWillLeaveApplication: is called.
- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    NSLog(@"%s -> ", __FUNCTION__);
}

// Sent just before dismissing a full screen view.
- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
    NSLog(@"%s -> ", __FUNCTION__);
}

// Sent just after dismissing a full screen view.  Use this opportunity to
// restart anything you may have stopped as part of adViewWillPresentScreen:.
- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
    NSLog(@"%s -> ", __FUNCTION__);
}

// Sent just before the application will background or terminate because the
// user clicked on an ad that will launch another application (such as the App
// Store).  The normal UIApplicationDelegate methods, like
// applicationDidEnterBackground:, will be called immediately before this.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    NSLog(@"%s -> ", __FUNCTION__);
}

#pragma mark - NO IAD

- (IBAction)btnBuyTap:(id)sender
{
    [IOSHelper buyNoIad];
}

@end
