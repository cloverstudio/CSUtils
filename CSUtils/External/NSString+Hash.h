//
//  NSString+Hash.h
//  BeatSeekr
//
//  Created by Josip Bernat on 6/3/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hash)

/**
 @return NSString A hashed string using SHA256 hash function.
 */
- (NSString *)sha256String;

@end
