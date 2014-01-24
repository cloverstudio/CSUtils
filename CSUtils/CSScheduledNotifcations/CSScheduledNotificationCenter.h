//
//  CSScheduledNotificationCenter.h
//  BeatSeekr
//
//  Created by Josip Bernat on 20/11/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSScheduledNotification;

/**
 *  CSScheduledNotificationCenter handles scheduling notifications for fire.
 */
@interface CSScheduledNotificationCenter : NSObject

#pragma mark - Class Methods

/**
 *  If the default center does not exist yet, it is created.
 *
 *  @return The default center instance.
 */
+ (instancetype)defaultCenter;

/**
 *  Starts CSScheduledNotificationCenter. Usually call this method from AppDelegate applicationDidFinishLaunchingWithOptions:.
 */
+ (void)start;

/**
 *  Adds an entry to the receiver’s dispatch table with an observer, a notification selector, notification name and sender.
 *
 *  @param notificationObserver Object registering as an observer. This value must not be nil.
 *  @param selector             Selector that specifies the message the receiver sends notificationObserver to notify it of the notification posting. The method specified by notificationSelector must have one and only one argument (an instance of CSScheduledNotification).
 *  @param notificationName     The name of the notification for which to register the observer; that is, only notifications with this name are delivered to the observer. This value must not be nil.
 */
+ (void)addObserver:(id)notificationObserver
           selector:(SEL)selector
               name:(NSString *)notificationName;

/**
 *  Removes matching entries from the receiver’s dispatch table.
 *
 *  @param notificationObserver Observer to remove from the dispatch table. Must not be nil, or message will have no effect.
 *  @param notificationName     Name of the notification to remove from dispatch table
 */
+ (void)removeObserver:(id)notificationObserver
                  name:(NSString *)notificationName;

/**
 *  Adds a given notification to the timer queue.
 *
 *  @param notification The notification to add in queue. This value must not be nil.
 */
+ (void)addScheduledNotification:(CSScheduledNotification *)notification;

/**
 *  Removes a given notification from the timer queue.
 *
 *  @param notification The notification to add in queue. This value must not be nil.
 */
+ (void)removeScheduledNotification:(CSScheduledNotification *)notification;

@end
