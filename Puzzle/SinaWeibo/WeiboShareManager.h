//
//  WeiboShareManager.h
//  MaJiong
//
//  Created by Kira on 8/1/13.
//
//

#import <Foundation/Foundation.h>


#define kAppKey             @"3516220031"
#define kAppSecret          @"74d729fedf504951871c8f831d5a5b6b"
#define kAppRedirectURI     @"https://api.weibo.com/oauth2/default.html"

#ifndef kAppKey
#error
#endif

#ifndef kAppSecret
#error
#endif

#ifndef kAppRedirectURI
#error
#endif

#import "SinaWeibo.h"

@interface WeiboShareManager : NSObject <SinaWeiboDelegate, SinaWeiboRequestDelegate>
{
    SinaWeibo *sinaweibo;
}

+ (void)LoginAndShareSina;

+ (void)LoginAndShareTwitter;

@end