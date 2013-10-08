//
//  ImageManager.m
//  Puzzle
//
//  Created by Kira on 9/2/13.
//  Copyright (c) 2013 Kira. All rights reserved.
//

#import "ImageManager.h"

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

@end
