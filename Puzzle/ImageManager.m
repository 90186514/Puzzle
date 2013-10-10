//
//  ImageManager.m
//  Puzzle
//
//  Created by Kira on 9/2/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "ImageManager.h"
#import "def.h"
#import "BWStatusBarOverlay.h"

static ImageManager *userInterface = nil;

@implementation ImageManager

+ (NSArray *)AllPlayImagePaths
{
    NSMutableArray *imgArr = [NSMutableArray arrayWithCapacity:10];
    
    NSString *resFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"free"];
    NSArray *subitems = [[NSFileManager defaultManager] subpathsAtPath:resFolder];
    for (int i = 0; i < [subitems count]; i ++) {
        NSString * itemPath = [resFolder stringByAppendingPathComponent:[subitems objectAtIndex:i]];
        [imgArr addObject:itemPath];
    }
    
    NSString *docPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
    NSArray *subItem = [[NSFileManager defaultManager] subpathsAtPath:docPath];
    for (int i = 0; i < [subItem count]; i ++) {
        NSString *imgPath = [docPath stringByAppendingPathComponent:[subItem objectAtIndex:i]];
        [imgArr addObject:imgPath];
    }
    return imgArr;
}

+ (ImageManager *)shareInterface
{
    if (userInterface == nil) {
        userInterface = [[self alloc] init];
    }
    return userInterface;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    self.localTileImagesArray = nil;
    self.serverTileImagesArray = nil;
    [super dealloc];
}

- (NSString *)tilePathForName:(NSString *)name
{
    NSString *tilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_tile.jpg", name]];
    return tilePath;
}

- (void)partAllTileList:(NSArray *)allList
{
    //allList是某个类别下的所有tile图片
    //在类别之间切换必须要清空localTileImagesArray + serverTileImagesArray;
    if (self.localTileImagesArray != nil) {
        self.localTileImagesArray = nil;
    }
    self.localTileImagesArray = [NSMutableArray arrayWithCapacity:30];
    
    if (self.serverTileImagesArray != nil) {
        self.serverTileImagesArray = nil;
    }
    self.serverTileImagesArray = [NSMutableArray arrayWithCapacity:30];
    
    for (int i = 0; i < [allList count]; i ++) {
        NSDictionary *item = [allList objectAtIndex:i];
        NSString *filePrefix = [item objectForKey:@"path"];
        NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_tile.jpg", filePrefix]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            //has download
            [self.localTileImagesArray addObject:item];
        } else {
            [self.serverTileImagesArray addObject:item];
        }
    }
}

- (void)loadTiltImages
{
    //init tile queue
    if (!([self.serverTileImagesArray count] > 0)) {
        return ;
    }
    ASINetworkQueue *tileQueue = [[ASINetworkQueue alloc] init];
    tileQueue.delegate = self;
    [tileQueue setRequestDidFinishSelector:@selector(tileRequestDidFinish:)];
    [tileQueue setRequestDidFailSelector:@selector(tileRequestDidFail:)];
    [tileQueue setQueueDidFinishSelector:@selector(tileQueueDidFinish:)];
    
    for (int i = 0; i < [self.serverTileImagesArray count]; i ++) {
        //Download the tile image
        NSDictionary *tileItem = [self.serverTileImagesArray objectAtIndex:i];
        NSString *name = [tileItem objectForKey:@"path"];
        NSString *tileUrl = [NSString stringWithFormat:@"%@/download.php?filename=%@_tile.jpg", domin, name];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:tileUrl]];
        NSString *desPath = [self tilePathForName:name];
        [request setDownloadDestinationPath:desPath];
        [request setUserInfo:tileItem];
        [tileQueue addOperation:request];
    }
    [tileQueue go];
}


#pragma mark - Tile Network Queue Delegate

- (void)tileRequestDidFail:(ASIHTTPRequest *)request
{
    [BWStatusBarOverlay showErrorWithMessage:NSLocalizedString(@"NetworkErrorMessage", nil) duration:2.0 animated:YES];
    NSString *tilePath = [self tilePathForName:[[request userInfo] objectForKey:@"path"]];
    [[NSFileManager defaultManager] removeItemAtPath:tilePath error:nil];
    NSLog(@"%s -> %@", __FUNCTION__, [request userInfo]);
}

- (void)tileRequestDidFinish:(ASIHTTPRequest *)request
{
    NSDictionary *tileItem = [request userInfo];
    if ([self.serverTileImagesArray indexOfObject:tileItem] == NSNotFound) {
        //说明这个request并不是当前类别
        //则仅仅保存图片，不做后续的操作操作
        return ;
    }
    [self.localTileImagesArray addObject:tileItem];
    [self.serverTileImagesArray removeObject:tileItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiNameDidLoadTileImage object:nil];
}

- (void)tileQueueDidFinish:(ASINetworkQueue *)queue
{
    [queue reset];
    [queue cancelAllOperations];
    [queue release];
}


@end
