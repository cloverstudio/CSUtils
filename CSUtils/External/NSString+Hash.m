//
//  NSString+Hash.m
//  BeatSeekr
//
//  Created by Josip Bernat on 6/3/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "NSString+Hash.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Hash)

- (NSString *)sha256String {

    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
