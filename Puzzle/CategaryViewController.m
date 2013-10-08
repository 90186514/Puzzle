//
//  CategaryViewController.m
//  Puzzle
//
//  Created by HalloWorld on 13-10-7.
//  Copyright (c) 2013年 Kira. All rights reserved.
//

#import "CategaryViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _categaryRequest.delegate = nil;
    self.categaryArray = nil;
    [super dealloc];
}

#pragma mark - Table View Delegate

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
    static NSString *identi = @"cateCell";
    UITableViewCell *cel = [tableView dequeueReusableCellWithIdentifier:identi];
    if (!cel) {
        cel = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi] autorelease];
    }
    
    cel.textLabel.text = @"categary";
    cel.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cel;
}

#pragma mark - Request

- (void)requestCategary
{
    NSString *cateUrl = [NSString stringWithFormat:@"%@/categary.php",domin];
    _categaryRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:cateUrl]];
    _categaryRequest.delegate = self;
    [_categaryRequest setDidFinishSelector:@selector(didFinishCateSelector:)];
    [_categaryRequest setDidFailSelector:@selector(didFailCateSelector:)];
    [_categaryRequest startAsynchronous];
}

- (void)didFinishCateSelector:(ASIHTTPRequest *)request
{
}

- (void)didFailCateSelector:(ASIHTTPRequest *)request
{
}

@end
