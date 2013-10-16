//
//  IOSHelper.m
//  MaJiong
//
//  Created by HalloWorld on 13-1-4.
//
//

#import "IOSHelper.h"

//针对pro
#define kBoolIsPuzzlePro 1

#ifndef kBoolIsPuzzlePro

#define kBundleIDRemoveIAd @"com.puzzle.iad"

#else

#define kBundleIDRemoveIAd @"com.puzzlepro.iad"

#endif
//////

#define kCountActiveKey @"kCountActiveKey"

static IOSHelper *helperInterface = nil;

@implementation IOSHelper
- (id)init
{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

+ (id)shareInterface
{
    if (helperInterface == nil) {
        helperInterface = [[IOSHelper alloc] init];
    }
    return helperInterface;
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [super dealloc];
}

- (void)getProductInfo {
    NSSet * set = [NSSet setWithArray:@[kBundleIDRemoveIAd]];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
    [request release];
}

- (void)payProductID:(NSString *)proID
{
    NSSet * set = [NSSet setWithArray:@[proID]];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
    [request release];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"buyFail", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    SKPayment * payment = [SKPayment paymentWithProduct:[myProduct objectAtIndex:0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"商品添加进列表");
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    // Your application should implement these two methods.
    NSString * productIdentifier = transaction.payment.productIdentifier;
//    NSString * receipt = [transaction.transactionReceipt base64EncodedString];
    
    [self finishPayProductID:productIdentifier];
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)finishPayProductID:(NSString *)prodctID
{
    if ([prodctID rangeOfString:@"coin"].location != NSNotFound) {
        //购买的金币
        NSString *numberStr = [[prodctID componentsSeparatedByString:@"coin"] lastObject];
        NSInteger coins = [numberStr integerValue];
        NSInteger cur = [[NSUserDefaults standardUserDefaults] integerForKey:@"coincount"];
        [[NSUserDefaults standardUserDefaults] setInteger:cur + coins forKey:@"coincount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        //购买去广告
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noiad"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noiad" object:nil];
        [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:kCountActiveKey];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"%@ 购买失败 %@", transaction.payment.productIdentifier,transaction.error);
    } else {
        NSLog(@"用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 对于已购商品，处理恢复购买的逻辑
    NSString * productIdentifier = transaction.payment.productIdentifier;
    [self finishPayProductID:productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[IOSHelper shareInterface] getProductInfo];
    } else if (buttonIndex == 2){
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

#pragma mark - Actions
+(void)buyNoIad
{
    if ([SKPaymentQueue canMakePayments]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to buy 'Iad off'? If you have bought, please tap 'Restore'" delegate:[IOSHelper shareInterface] cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", @"Restore", nil];
        [alert show];
        [alert release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"buyDisable", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

@end
