//
//  ImageManager.h
//  Puzzle
//
//  Created by Kira on 9/2/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@interface ImageManager : NSObject
{
}

@property (nonatomic, retain) NSMutableArray *localTileImagesArray;
@property (nonatomic, retain) NSMutableArray *serverTileImagesArray;


+ (NSMutableArray *)AllPlayImagePaths;      //返回本地所有可游戏的图片路径大全

+ (NSMutableArray *)AllPlayImagePrefix;

+ (ImageManager *)shareInterface;

- (void)partAllTileList:(NSArray *)allList;
- (void)loadTiltImages;

- (NSString *)tilePathForPrefix:(NSString *)name;
- (NSString *)bigPicPathForPrefix:(NSString *)name;

- (void)loadBigImageWithPrefix:(NSString *)prefix;
- (void)loadBigImageWithDataDic:(NSDictionary *)dic;

@end
