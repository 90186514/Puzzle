//
//  CategaryViewController.m
//  Puzzle
//
//  Created by HalloWorld on 13-10-7.
//  Copyright (c) 2013年 Kira. All rights reserved.
//

#import "CategaryViewController.h"
#import "DownloadViewController.h"
#import "JSONKit.h"
#import "BuyCoinsViewController.h"

#define kTagCategaryFailAlert 101
#define kTagPhotolistFailAlert 102


@interface CategaryViewController ()

@end

@implementation CategaryViewController

- (id)init
{
    NSString *nibName = (UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM()) ? @"CategaryViewController" : @"CategaryViewController_pad";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        [self requestCategary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Categary", nil);
    
    UIBarButtonItem *leftItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(btnBackTap:)] autorelease];
    leftItem.tintColor = [UIColor purpleColor];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"buyCar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(buyCarTap:)] autorelease];
    rightItem.tintColor = [UIColor purpleColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if (isPad) {
        UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GreenBack.jpg"]];
        back.frame = self.view.bounds;
        [self.view insertSubview:[back autorelease] atIndex:0];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GreenBack.jpg"]];
    }
}

- (void)buyCarTap:(id)sender
{
    BuyCoinsViewController *buycoins = [[BuyCoinsViewController alloc] init];
    [self.navigationController pushViewController:buycoins animated:YES];
    [buycoins release];
}

- (void)btnBackTap:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.photoListRequest.delegate = nil;
    self.photoListRequest = nil;
    self.categaryRequest.delegate = nil;
    self.categaryArray = nil;
    [super dealloc];
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_categaryArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identi = @"cateCell";
    UITableViewCell *cel = [tableView dequeueReusableCellWithIdentifier:identi];
    if (!cel) {
        cel = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi] autorelease];
    }
    
    NSString *cateName = [[_categaryArray objectAtIndex:indexPath.row] objectForKey:@"categaryname"];
    cel.textLabel.text = NSLocalizedString(cateName, nil);
    cel.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *categaryid = [[_categaryArray objectAtIndex:indexPath.row] objectForKey:@"categaryid"];
    [self requestPhotoListByCategaryid:categaryid];
}


#pragma mark - Request

- (void)requestCategary
{
    NSString *cateUrl = [NSString stringWithFormat:@"%@/categary.php",domin];
    if (self.categaryRequest != nil) {
        self.categaryRequest.delegate = nil;
        self.categaryRequest = nil;
    }
    self.categaryRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:cateUrl]] autorelease];
    _categaryRequest.delegate = self;
    [_categaryRequest setDidFinishSelector:@selector(didFinishCateSelector:)];
    [_categaryRequest setDidFailSelector:@selector(didFailCateSelector:)];
    [_categaryRequest startAsynchronous];
}

- (void)didFinishCateSelector:(ASIHTTPRequest *)request
{
    self.categaryArray = [[request responseString] objectFromJSONString];
    [[self categaryTable] reloadData];
}

- (void)didFailCateSelector:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitle", nil) message:NSLocalizedString(@"NetworkErrorMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
    [alert setTag:kTagCategaryFailAlert];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kTagCategaryFailAlert) {
        if (buttonIndex == 0) {
            [self.navigationController dismissModalViewControllerAnimated:YES];
        } else if (buttonIndex == 1) {
            [self requestCategary];
        }
    }
    
    if (alertView.tag == kTagPhotolistFailAlert) {
        if (buttonIndex == 0) {
            //do nothing
        } else if (buttonIndex == 1) {
            [self requestPhotoListByCategaryid:self.tempCategaryID];
        }
    }
}

- (void)requestPhotoListByCategaryid:(NSString *)cateid
{
    self.tempCategaryID = cateid;
    NSString *photolistUrl = [NSString stringWithFormat:@"%@/photolist.php?categaryid=%@", domin, cateid];
    if (self.photoListRequest != nil) {
        self.photoListRequest.delegate = nil;
        self.photoListRequest = nil;
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:photolistUrl]];
    self.photoListRequest = request;
    [request setDelegate:self];
    [request setTimeOutSeconds:10];
    [request setDidFinishSelector:@selector(photoListDidFinish:)];
    [request setDidFailSelector:@selector(photoListDidFail:)];
    [request startAsynchronous];
    [request autorelease];
}


- (void)photoListDidFinish:(ASIHTTPRequest *)request
{
    NSArray *photolist = [[request responseString] objectFromJSONString];
    DownloadViewController *down = [[DownloadViewController alloc] initWithPhotoList:photolist];
    [self.navigationController pushViewController:[down autorelease] animated:YES];
}

- (void)photoListDidFail:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitle", nil) message:NSLocalizedString(@"NetworkErrorMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
    [alert setTag:kTagPhotolistFailAlert];
    [alert show];
    [alert release];
}


@end
