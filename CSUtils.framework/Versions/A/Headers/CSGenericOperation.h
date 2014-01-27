//
//  CSGenericOperation.h
//  StoragePipe
//
//  Created by Josip Bernat on 23/01/14.
//
//

#import <Foundation/Foundation.h>

/**
 *  Generic class suitable for creating concurrent operations. Subclass needs to overrid operationDidStart in order to start with the operation and must call operationDidFinish when it's done with operation in order to finish operation.
 */
@interface CSGenericOperation : NSOperation

/**
 *  This method is never called by system and should be called from subclass when it's done with job. If never called operation will never finish.
 */
- (void)operationDidFinish;

/**
 *  Called when operation starts with progress. In your subclass you should override this method and start with job in it. Calling super operationDidStart invokes calling operationDidFinish so you should not call super in your subclasses.
 */
- (void)operationDidStart;

@end
