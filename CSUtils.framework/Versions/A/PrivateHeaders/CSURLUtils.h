//
//  CSURLUtils.h
//  CSUtils
//
//  Created by Josip Bernat on 04/02/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSURLUtils : NSObject

#pragma mark - Boundary
/**
 *  Generates boundary string used in httpBody.
 *
 *  @return String object containing generated boundary.
 */
+ (NSString *)generateBoundaryString;

#pragma mark - Mime
/**
 *  Generates mimeType string depending on file that is path pointing on.
 *
 *  @param path Path to file in system.
 *
 *  @return String object containing mimeType.
 */
+ (NSString *)mimeTypeForPath:(NSString *)path;

@end
