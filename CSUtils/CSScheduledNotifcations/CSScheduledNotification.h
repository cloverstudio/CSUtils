//
//  CSScheduledNotification.h
//  BeatSeekr
//
//  Created by Josip Bernat on 20/11/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  CSSCheduledNotification object contains notification data such as notification name, user info and fire data.
 */
@interface CSScheduledNotification : NSObject

/**
 *  The name of the notification. Typically you use this method to find out what kind of notification you are dealing with when you receive a notification.
 */
@property (nonatomic, strong) NSString *name;

/**
 *  The user information dictionary associated with the receiver. May be nil.
 */
@property (nonatomic, strong) NSDictionary *userInfo;

/**
 *  The date at which the notification will fire. The date must be greather that current date using compare: method with [NSDate date] date.
 */
@property (nonatomic, strong) NSDate *fireDate;


#pragma mark - Class Methods

/**
 *  Creates and returns a new CSScheduledNotification object with given name and fire date.
 *
 *  @param name     The name of the notification.
 *  @param fireDate The date at which the notification will fire.
 *
 *  @return A new CSScheduledNotification object, configured according to the specified parameters.
 */
+ (id)scheduledNotificationWithName:(NSString *)name
                           fireDate:(NSDate *)fireDate;

/**
 *  Creates and returns a new CSScheduledNotification object with given name, fire date and user info.
 *
 *  @param name     The name of the notification.
 *  @param fireDate The date at which the notification will fire.
 *  @param userInfo The user information dictionary.
 *
 *  @return A new CSScheduledNotification object, configured according to the specified parameters.
 */
+ (id)scheduledNotificationWithName:(NSString *)name
                           fireDate:(NSDate *)fireDate
                           userInfo:(NSDictionary *)userInfo;

#pragma mark - Instance Methods
/**
 *  Initializes a new CSScheduledNotification object with given parameters.
 *
 *  @param name     The name of the notification.
 *  @param fireDate The date at which the notification will fire.
 *  @param userInfo The user information dictionary.
 *
 *  @return The scheduled notification object with properties configured with given parameters.
 */
- (id)initWithName:(NSString *)name
          fireDate:(NSDate *)fireDate
          userInfo:(NSDictionary *)userInfo;

/**
 *  Inspects if fire date is in future comparing to [NSDate date]
 *
 *  @param fireDate A date object to comapre.
 *
 *  @return YES if given date is in future, other NO.
 */
+ (BOOL)isFireDateValid:(NSDate *)fireDate;

@end
