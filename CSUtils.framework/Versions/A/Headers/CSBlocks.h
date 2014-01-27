//
//  CSBlocks.h
//  CSUtils
//
//  Created by Josip Bernat on 5/9/13.
//
//

/**
 *  CSBlock contains set of block object defines used in Clover-Studio frameworks.
 */

#ifndef CSUtils_CSBlocks_h
#define CSUtils_CSBlocks_h

#import <UIKit/UIImage.h>

#pragma mark - Generic
typedef void (^CSVoidBlock)(void);
typedef void (^CSBoolBlock)(BOOL yesOrNo);
typedef void (^CSErrorBlock)(NSError* error);
typedef void (^CSResultBlock)(id result);
typedef void (^CSResponseBlock)(id responseObject, NSError *error);

#pragma mark - Image
typedef void (^CSImageDownloadBlock)(NSURL *imageURL, UIImage *image);
typedef void (^CSImageBlock)(UIImage* image);

#pragma mark - Collections
typedef void (^CSArrayBlock)(NSArray *array);
typedef void (^CSDictionaryBlock)(NSDictionary *dictionary);
typedef void (^CSSetBlock)(NSSet *set);

#pragma mark - Progress
typedef void (^CSUploadProgressBlock)(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void (^CSDownloadProgressBlock)(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void (^CSProgressBlock)(float progress);

#endif
