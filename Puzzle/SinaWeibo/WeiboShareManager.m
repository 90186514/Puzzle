//
//  WeiboShareManager.m
//  MaJiong
//
//  Created by Kira on 8/1/13.
//
//


#define kShareContent @"上帝拼图，绝对高端大气上档次~，您随心所欲编辑您的照片，让它出现在您的游戏中，游戏本身附带大量精美图片可玩，还在等什么？赶紧下载吧:https://itunes.apple.com/us/app/god-puzzle/id702671084?ls=1&mt=8"

#import "WeiboShareManager.h"
#import "SinaWeibo.h"
#import <Twitter/Twitter.h>
#import "def.h"
#import <Accounts/Accounts.h>

@implementation WeiboShareManager

static WeiboShareManager *manager = nil;

- (id)init
{
    self = [super init];
    if (self) {
        sinaweibo = nil;
    }
    return self;
}

- (void)loginSina
{
    if (sinaweibo == nil) {
        sinaweibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:self];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        sinaweibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        sinaweibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        sinaweibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
    [sinaweibo logIn];
}

- (void)dealloc
{
    sinaweibo.delegate = nil;
    [SinaWeibo release];
    [super dealloc];
}

#pragma mark - Weibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    [self storeAuthData];
    //TODO share content on weibo
    [self SinaShareData:nil];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    [self removeAuthData];
    [manager release];
    manager = nil;
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{}
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    [self removeAuthData];
}

- (void)request:(SinaWeiboRequest *)request didReceiveResponse:(NSURLResponse *)response
{}
- (void)request:(SinaWeiboRequest *)request didReceiveRawData:(NSData *)data
{}
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    [self removeAuthData];
}
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"谢谢分享" message:nil delegate:nil cancelButtonTitle:@"不用客气" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [manager release];
        manager = nil;
    }
    
    if ([request.url hasSuffix:@"friendships/create.json"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"beenfriendships"];
    }
}

- (void)storeAuthData
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)SinaShareData:(NSString *)content
{
    [sinaweibo requestWithURL:@"statuses/upload.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                               kShareContent, @"status",
                               [UIImage imageNamed:@"Icon@2x.png"], @"pic", nil]
                   httpMethod:@"POST"
                     delegate:self];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"beenfriendships"]) {
        [sinaweibo requestWithURL:@"friendships/create.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"_HalloWorld", @"screen_name", nil]
                       httpMethod:@"POST"
                         delegate:self];
    }
}

+ (void)LoginAndShareSina
{
    if (manager == nil) {
        manager = [[WeiboShareManager alloc] init];
    }
    [manager loginSina];
}

+ (void)LoginAndShareTwitter
{
    if (manager == nil) {
        manager = [[WeiboShareManager alloc] init];
    }
    [manager shareOnTweeter];
}

//展示twitter分享页面
- (void)shareOnTweeter
{
    //获取帐号存储
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    //获取twitter帐号类型
    //按照此数据提示.可以看出来苹果在更新后的SDK中,应该会封装facebook sina的帐号吧.
    //这样封装了帐号密码在系统级别.而在应用程序中,只需要获取到帐号的索引
    //然后调用发送和接收服务
    //剩下的只是数据处理
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //申请访问帐号
    [accountStore requestAccessToAccountsWithType:accountType
                            withCompletionHandler:^(BOOL granted,NSError *error) {
                                //授权访问
                                //提示用户程序需要访问twitter帐号
                                if (granted) {
                                    //获取twitter帐号列表
                                    NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
                                    
                                    //如果添加了twitter帐号
                                    if ([accountArray count] < 0) {
                                        //这里只是获取了第一个帐号.其实还可以通过username选择具体的用户
                                        ACAccount *twitterAccount = [accountArray objectAtIndex:0];
                                        
                                        //twitter 访问请求
                                        //封装的相当简洁
                                        //用户只需要提交 url 数据字典 和 请求类型
                                        //这样独立于帐号
                                        TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
                                                                                     parameters:[NSDictionary dictionaryWithObject:kShareContent forKey:@"status"]
                                                                                  requestMethod:TWRequestMethodPOST];
                                        //设置请教的归属帐号
                                        //使用什么帐号来完成操作
                                        [postRequest setAccount:twitterAccount];
                                        
                                        //请求数据
                                        [postRequest performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse *urlResponse,NSError *error){
                                            //请求返回的结果
                                            NSString *output = [NSString stringWithFormat:@"HTTP response status : %i\n data: %@",[urlResponse statusCode],[[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]];
                                            NSLog(@"%s -> %@", __FUNCTION__, output);
                                            //                                            [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                                        }];
                                    } else {
                                        //没有twitter账号...
                                        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
                                        
                                        [tweetViewController setInitialText:kShareContent];
                                        [tweetViewController addImage:[UIImage imageNamed:@"Icon@2x.png"]];
                                        
                                        [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                                            NSString *output;
                                            switch (result) {
                                                case TWTweetComposeViewControllerResultCancelled:
                                                    output = @"Tweet Cancel.";
                                                    break;
                                                    
                                                case TWTweetComposeViewControllerResultDone:
                                                    output = @"Tweet done.";
                                                    break;
                                                    
                                                default:
                                                    break;
                                            }
                                            
                                            
                                            [[[UIApplication sharedApplication] keyWindow].rootViewController dismissModalViewControllerAnimated:YES];
                                        }];
                                        
                                        [self performSelectorOnMainThread:@selector(show:) withObject:tweetViewController waitUntilDone:YES];
                                        [tweetViewController autorelease];
                                    }
                                }
                            }];
}


- (void)show:(UIViewController *)tw
{
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentModalViewController:tw animated:YES];
}


@end