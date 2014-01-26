//
//  CSLazyLoadController.m
//  LifeLine
//
//  Created by Giga on 1/8/13.
//  Copyright (c) 2013 Clover-Studio. All rights reserved.
//

#import "CSLazyLoadController.h"
#import "CSCacheManager.h"

static NSOperationQueue *_cacheOperationQueue = nil;
static NSOperationQueue *_downloadingOperationQueue = nil;

static NSMutableSet   *_readingUrlsSet = nil;
static NSMutableSet   *_downloadingUrlsSet = nil;

@interface CSLazyLoadController ()

@end

@implementation CSLazyLoadController

@synthesize delegate = _delegate;

#pragma mark - Class Methods

+ (NSOperationQueue *)sharedCacheOperationQueue {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cacheOperationQueue = [[NSOperationQueue alloc] init];
        _cacheOperationQueue.maxConcurrentOperationCount = 3;
    });
    
    return _cacheOperationQueue;
}

+ (NSOperationQueue *)sharedDownloadingOperationQueue {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadingOperationQueue = [[NSOperationQueue alloc] init];
        _downloadingOperationQueue.maxConcurrentOperationCount = 3;
    });
    
    return _downloadingOperationQueue;
}

+ (NSMutableSet *)sharedReadingUrlsSet {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _readingUrlsSet = [[NSMutableSet alloc] init];
    });
    
    return _readingUrlsSet;
}

+ (NSMutableSet *)sharedDownloadingUrlsSet {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadingUrlsSet = [[NSMutableSet alloc] init];
    });
    
    return _downloadingUrlsSet;
}

#pragma mark - Initialization

-(id) init {
    
    if (self = [super init]) {
        [CSCacheManager defaultCache];
    }
    
    return self;
}

#pragma mark - Actions

- (void)notifyDelegateForImage:(UIImage *)image
                       fromUrl:(NSURL *)imageURL
                     indexPath:(NSIndexPath *)indexPath {
    
    if ([(NSObject *)_delegate respondsToSelector:@selector(lazyLoadController:didReciveImage:fromURL:indexPath:)]) {
        
        if ([NSThread isMainThread]) {
            [_delegate lazyLoadController:self
                           didReciveImage:image
                                  fromURL:imageURL
                                indexPath:indexPath];
        }
        else {
            __weak id this = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong CSLazyLoadController *strongThis = this;
                [strongThis.delegate lazyLoadController:strongThis
                                         didReciveImage:image
                                                fromURL:imageURL
                                              indexPath:indexPath];
            });
        }
    }
}

- (void)readURLCache:(NSURL *)url
           indexPath:(NSIndexPath *)indexPath {

    if (!url) {
        [self notifyDelegateForImage:nil
                             fromUrl:url
                           indexPath:indexPath];
        return;
    }
    
    [[CSLazyLoadController sharedReadingUrlsSet] addObject:url];
    
    __weak id this = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        UIImage *image = [[CSCacheManager defaultCache] readCachedImage:url
                                                               fromDisk:YES];
        if (image) {
            __strong CSLazyLoadController *strongThis = this;
            [strongThis notifyDelegateForImage:image
                                       fromUrl:url
                                     indexPath:indexPath];
        }
        else {
            __strong CSLazyLoadController *strongThis = this;
            [strongThis readURLContnent:url indexPath:indexPath];
        }
        
        [[CSLazyLoadController sharedReadingUrlsSet] removeObject:url];
    }];
    operation.queuePriority = NSOperationQueuePriorityHigh;
    [[CSLazyLoadController sharedCacheOperationQueue] addOperation:operation];
}


- (void)readURLContnent:(NSURL *)url
              indexPath:(NSIndexPath *)indexPath {

    if (!url) {
        [self notifyDelegateForImage:nil
                             fromUrl:url
                           indexPath:indexPath];
        return;
    }
    
    [[CSLazyLoadController sharedDownloadingUrlsSet] addObject:url];
    
    __weak id this = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                             timeoutInterval:20];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        
        [[CSCacheManager defaultCache] cacheImage:[UIImage imageWithData:data]
                                              url:url
                                       saveToDisk:YES];
        
        UIImage *downloadedImage = [UIImage imageWithData:data];
        
        __strong CSLazyLoadController *strongThis = this;
        [strongThis notifyDelegateForImage:downloadedImage
                                   fromUrl:url
                                 indexPath:indexPath];
        
        [[CSLazyLoadController sharedDownloadingUrlsSet] removeObject:url];
    }];
    operation.queuePriority = NSOperationQueuePriorityLow;
    [[CSLazyLoadController sharedDownloadingOperationQueue] addOperation:operation];
}

- (void)startDownload:(NSURL *)url
         forIndexPath:(NSIndexPath *)indexPath {
    
    [self readURLCache:url
             indexPath:indexPath];
}

- (void)loadImagesForOnscreenRows:(NSArray *) indexPaths {
    
    NSArray *copyPaths = [indexPaths copy];
    for (NSIndexPath *indexPath in copyPaths) {
        
        NSURL *url = nil;
        if ([(NSObject *)_delegate respondsToSelector:@selector(lazyLoadController:urlForImageAtIndexPath:)]) {
            
            url = [_delegate lazyLoadController:self
                         urlForImageAtIndexPath:indexPath];
        }
        
		if (url) {
            [self startDownload:url forIndexPath:indexPath];
		}
	}
}

- (UIImage *)fastCacheImage:(NSURL *)url {
    
    return [[CSCacheManager defaultCache] readCachedImage:url
                                                         fromDisk:NO];
}

@end
