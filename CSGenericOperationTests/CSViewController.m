//
//  CSViewController.m
//  CSGenericOperationTests
//
//  Created by Josip Bernat on 31/01/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import "CSViewController.h"
#import "CSLongRunningOperation.h"

@interface CSViewController ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation CSViewController

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {

    if (self = [super initWithCoder:aDecoder]) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

#pragma mark - Button Selectors

- (IBAction)onAddOperation:(id)sender {

    __weak id this = self;
    CSLongRunningOperation *operation = [[CSLongRunningOperation alloc] init];
    [operation setUpdateBlock:^(id result){
    
        __strong CSViewController *strongThis = this;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableString *textViewText = [NSMutableString stringWithFormat:@"%@", strongThis.textView.text];
            [textViewText appendFormat:@"\n"];
            [textViewText appendString:result];
            strongThis.textView.text = textViewText;
            [strongThis.textView scrollRangeToVisible:NSMakeRange(strongThis.textView.text.length, 0)];
        });
    }];
    [self.operationQueue addOperation:operation];
}

@end
