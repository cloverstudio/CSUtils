//
//  CSMessageCenter.h
//  StoragePipe
//
//  Created by Josip Bernat on 10/01/14.
//
//

#import <Foundation/Foundation.h>

@class CSMessage;

/**
 *  CSMessageCenter class handles sending messages using NSOperationQueue.
 */
@interface CSMessageCenter : NSObject

/**
 *  Number of concurrent messages in queue.
 */
@property (nonatomic, readwrite) NSInteger maxConcurrentMessagesCount;

/**
 *  If the default center does not exist yet, it is created.
 *
 *  @return The default center instance.
 */
+ (CSMessageCenter *)defaultCenter;

#pragma mark - Adding Messages

/**
 *  Adds message to messages queue.
 *
 *  @param message Message object to be sent.
 */
- (void)addMessage:(CSMessage *)message;

#pragma mark - Canceling Messages

/**
 *  Calls cancel on given message. Message will be removed from NSOperationQueue if possible.
 *
 *  @param message Message object to be canceled.
 */
- (void)cancelMessage:(CSMessage *)message;

/**
 *  Sends cancel message to all messages in queue.
 */
- (void)cancelAllMessages;

@end
