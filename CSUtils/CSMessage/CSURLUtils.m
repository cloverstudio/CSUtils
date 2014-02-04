//
//  CSURLUtils.m
//  CSUtils
//
//  Created by Josip Bernat on 04/02/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import "CSURLUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation CSURLUtils

#pragma mark - Boundary

+ (NSString *)generateBoundaryString {
    
    // generate boundary string
    //
    // adapted from http://developer.apple.com/library/ios/#samplecode/SimpleURLConnections
    
    CFUUIDRef  uuid;
    NSString  *uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    assert(uuidStr != NULL);
    
    CFRelease(uuid);
    
    return [NSString stringWithFormat:@"Boundary-%@", uuidStr];
}

#pragma mark - Mime

+ (NSString *)mimeTypeForPath:(NSString *)path {
    
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}


@end
