//
//  CSCacheController.m
//  BeatSeekr
//
//  Created by Josip Bernat on 12/12/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSCacheManager.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

#pragma mark - Interface CSCacheManager
@interface CSCacheManager ()

@property (atomic, strong) NSCache *cache;

@end

/**
 *  Since .framework has problems with including class extensions without aditional compiler flag, let's add it in same file.
 */
#pragma mark - Interface NSString (Hash)
@interface NSString (Hash)

/**
 @return NSString A hashed string using SHA256 hash function.
 */
- (NSString *)sha256String;

@end

#pragma mark - Implementation CSCacheManager

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
               url:(NSURL *)URL
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
    
    NSString *urlHash = [self urlHash:URL];
    [_cache setObject:image forKey:urlHash];
    
    if (shouldSave) {
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:[self imageFilePath:urlHash] atomically:YES];
    }
}

#pragma mark - Deleting Images

- (void)removeImageForURL:(NSURL *)URL
                 fromDisk:(BOOL)fromDisk {

    NSString *urlHash = [self urlHash:URL];
    [self.cache removeObjectForKey:urlHash];
    
    if (fromDisk) {
        [[NSFileManager defaultManager] removeItemAtPath:[self imageFilePath:urlHash]
                                                   error:nil];
    }
}

#pragma mark - Getting Images

- (UIImage *)readCachedImage:(NSURL *)URL
                    fromDisk:(BOOL)readFromDisk {

    if (!URL) {return nil;}
    
    NSString *urlHash = [self urlHash:URL];
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

- (NSString *)urlHash:(NSURL *)URL {
    NSString *absoluteString = [URL absoluteString];
    return [absoluteString sha256String];
}

- (NSString *)imageFilePath:(NSString *)hash {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:hash];
}

@end

#pragma mark - Implementation NSString (Hash)

@implementation NSString (Hash)

- (NSString *)sha256String {
    
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (uint32_t)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
