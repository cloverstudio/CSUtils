//
//  CSGenericOperation.m
//  StoragePipe
//
//  Created by Josip Bernat on 23/01/14.
//
//

#import "CSGenericOperation.h"
#import <UIKit/UIKit.h>

@interface CSGenericOperation () {

    BOOL _isCancelled;
    BOOL _isFinished;
    BOOL _isExecuting;
}

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation CSGenericOperation

#pragma mark - Operation Handling

- (void)operationDidFinish {

    if (!_isExecuting) return;
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    [self finish];
}

- (void)operationDidStart {

    NSAssert(NO, @"In order to make operation usefull you must override operationDidStart method.");
    [self operationDidFinish];
}

#pragma mark - Background Task

-(void) beginBackgroundTask {
    
    __weak id this = self;
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        __strong CSGenericOperation *strongThis = this;
        [[UIApplication sharedApplication] endBackgroundTask:strongThis.backgroundTaskIdentifier];
        strongThis.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
}

-(void) endBackgroundTask {
    
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

- (void)finish {
    [self endBackgroundTask];
}

#pragma mark - NSOperation Override

- (void)start {
    
    _isExecuting = YES;
    _isFinished = NO;
    
    [self operationDidStart];
}

- (void)cancel {
    _isCancelled = YES;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

@end
