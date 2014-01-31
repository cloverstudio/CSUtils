//
//  CSLongRunningOperation.h
//  CSUtils
//
//  Created by Josip Bernat on 31/01/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import <CSUtils/CSUtils.h>

@interface CSLongRunningOperation : CSGenericOperation

@property (copy) CSResultBlock updateBlock;

@end
