//
//  CSCacheController.m
//  BeatSeekr
//
//  Created by Josip Bernat on 12/12/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSCacheManager.h"
#import <UIKit/UIKit.h>
#import "CSURL.h"

@interface CSCacheManager ()

@property (atomic, strong) NSCache *cache;

@end

@implementation CSCacheManager

+ (CSCacheManager *)defaultCache {

    static CSCacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - Initialization

- (id)init {

    if (self = [super init]) {
        self.cache = [[NSCache alloc] init];
        
        __weak id this = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          
                                                          __strong CSCacheManager *strongThis = this;
                                                          [strongThis.cache removeAllObjects];
                                                      }];
    }
    return self;
}

#pragma mark - Saving Images

- (void)cacheImage:(UIImage *)image
               url:(CSURL *)URL
        saveToDisk:(BOOL)shouldSave {

    if (!URL) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                reason:@"URL argument cannot be nil"
                               userInfo:nil] raise];
    }
    if (!image) {
        
        [self removeImageForURL:URL
                       fromDisk:shouldSave];
        return;
    }
    
    NSString *urlHash = URL.hashValue;
    [_cache setObject:image forKey:urlHash];
    
    if (shouldSave) {
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:[self imageFilePath:urlHash] atomically:YES];
    }
}

#pragma mark - Deleting Images

- (void)removeImageForURL:(CSURL *)URL
                 fromDisk:(BOOL)fromDisk {

    NSString *urlHash = URL.hashValue;
    [self.cache removeObjectForKey:urlHash];
    
    if (fromDisk) {
        [[NSFileManager defaultManager] removeItemAtPath:[self imageFilePath:urlHash]
                                                   error:nil];
    }
}

#pragma mark - Getting Images

- (UIImage *)readCachedImage:(CSURL *)URL
                    fromDisk:(BOOL)readFromDisk {

    if (!URL) {return nil;}
    
    NSString *urlHash = URL.hashValue;
    UIImage *image = [_cache objectForKey:urlHash];
    
    if (!image && readFromDisk) {
        NSData *data = [NSData dataWithContentsOfFile:[self imageFilePath:urlHash]];
        image = [UIImage imageWithData:data];
        if (image) {
            [_cache setObject:image forKey:urlHash];
        }
    }
    return image;
}

#pragma mark - Cache Location

- (NSString *)imageFilePath:(NSString *)hash {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:hash];
}

@end
