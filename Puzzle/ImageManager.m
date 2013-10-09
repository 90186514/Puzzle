//
//  ImageManager.m
//  Puzzle
//
//  Created by Kira on 9/2/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "ImageManager.h"

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
        NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_tile.png", filePrefix]];
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
    for (int i = 0; i < [self.serverTileImagesArray count]; i ++) {
        //Download the tile image
    }
}

@end
