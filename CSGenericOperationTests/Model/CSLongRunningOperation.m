//
//  CSLongRunningOperation.m
//  CSUtils
//
//  Created by Josip Bernat on 31/01/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import "CSLongRunningOperation.h"

@interface CSLongRunningOperation ()

@property (nonatomic, readwrite) NSInteger operationId;

@end

@implementation CSLongRunningOperation

#pragma mark - Memory Management

- (void)dealloc {
    NSLog(@"Dealloc called in operation with id: %d", self.operationId);
}

#pragma mark - Start Methods

- (void)operationDidStart {

    self.operationId = arc4random() % 100;
    NSDate *startDate = [NSDate date];
    
    [self sendUpdateText:[NSString stringWithFormat:@"Operation %d started at: %@",
                          self.operationId, startDate]];
    
    for (int i=0; i<10; i++) {
        
        [NSThread sleepForTimeInterval:1.0];
        
        [self sendUpdateText:[NSString stringWithFormat:@"Operation %d is running %f seconds",
                              self.operationId, (-[startDate timeIntervalSinceNow])]];
    }
    
    NSDate *finishDate = [NSDate date];
    [self sendUpdateText:[NSString stringWithFormat:@"Operation %d finishet at: %@",
                          self.operationId, finishDate]];
    
    [self operationDidFinish];
}

- (void)sendUpdateText:(NSString *)updateText {

    NSLog(@"%@", updateText);
    
    if (self.updateBlock) {
        self.updateBlock(updateText);
    }
}

@end
