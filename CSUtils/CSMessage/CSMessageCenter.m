//
//  CSMessageCenter.m
//  StoragePipe
//
//  Created by Josip Bernat on 10/01/14.
//
//

#import "CSMessageCenter.h"
#import "CSMessage.h"
#import "CSUReachability.h"

@interface CSMessageCenter ()

@property (nonatomic, strong) NSOperationQueue *messagesQueue;

@end

@implementation CSMessageCenter

+ (CSMessageCenter *)defaultCenter {

    static dispatch_once_t onceToken;
    static CSMessageCenter *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Memory Management

- (void)dealloc {
    [_messagesQueue cancelAllOperations];
}

#pragma mark - Initialization

- (id)init {

    if (self = [super init]) {
        
        _messagesQueue = [[NSOperationQueue alloc] init];
        _messagesQueue.maxConcurrentOperationCount = 5;
    }
    
    return self;
}

#pragma mark - Adding Messages

- (void)addMessage:(CSMessage *)message {
    [_messagesQueue addOperation:message];
}

#pragma mark - Canceling Messages

- (void)cancelMessage:(CSMessage *)message {

    [message cancel];
}

- (void)cancelAllMessages {
    [_messagesQueue cancelAllOperations];
}

@end
