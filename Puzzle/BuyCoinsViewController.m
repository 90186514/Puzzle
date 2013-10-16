//
//  BuyCoinsViewController.m
//  Puzzle
//
//  Created by Kira on 10/16/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "BuyCoinsViewController.h"
#import "def.h"
#import "IOSHelper.h"

@interface BuyCoinsViewController ()

@end

@implementation BuyCoinsViewController

- (id)init
{
    NSString *nibName = (isPad) ? @"BuyCoinsViewController_pad" : @"BuyCoinsViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        paymentArray = [[NSArray alloc] initWithObjects:
                        [NSDictionary dictionaryWithObjectsAndKeys:@"$0.99", @"pay", NSLocalizedString(@"65Coins", nil), @"coin",@"com.puzzlepro.coin65", @"productid", nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:@"$1.99", @"pay", NSLocalizedString(@"150Coins", nil), @"coin",@"com.puzzlepro.coin150", @"productid", nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:@"$3.99", @"pay", NSLocalizedString(@"325Coins", nil), @"coin",@"com.puzzlepro.coin325", @"productid", nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:@"$5.99", @"pay", NSLocalizedString(@"530Coins", nil), @"coin",@"com.puzzlepro.coin530", @"productid", nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:@"$9.99", @"pay", NSLocalizedString(@"1000Coins", nil), @"coin",@"com.puzzlepro.coin1000", @"productid", nil],
                        nil];
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
}

- (void)dealloc
{
    [paymentArray release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [paymentArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"payCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(210, 7, 90, 30.0);
        [button setBackgroundImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
        button.tag = 107;
        [button addTarget:self action:@selector(btnBuyCoinTap:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    }
    NSDictionary *dic = [paymentArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"coin"];
    
    UIButton *btn = (UIButton *)[cell viewWithTag:107];
    [btn setTitle:[dic objectForKey:@"pay"] forState:UIControlStateNormal];
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)btnBuyCoinTap:(UIButton *)sender
{
    NSIndexPath *index = [_payTableView indexPathForCell:(UITableViewCell *)[sender superview]];
    NSDictionary *dic = [paymentArray objectAtIndex:index.row];
    NSString *productid = [dic objectForKey:@"productid"];
    [[IOSHelper shareInterface] payProductID:productid];
}

@end
