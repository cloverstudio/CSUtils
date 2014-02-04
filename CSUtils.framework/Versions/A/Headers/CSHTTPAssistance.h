//
//  CSHTTPAssistance.h
//  CSUtils
//
//  Created by Josip Bernat on 04/02/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  HTTP request method types.
 */
typedef NSString *CSHTTPMethod;
extern CSHTTPMethod const CSHTTPMethodGET;      ///HTTP GET method.
extern CSHTTPMethod const CSHTTPMethodPOST;     ///HTTP POST method.
extern CSHTTPMethod const CSHTTPMethodPUT;      ///HTTP PUT method.
extern CSHTTPMethod const CSHTTPMethodDELETE;   ///HTTP DELETE method.

@interface CSHTTPAssistance : NSObject

@end
