//
//  CSScheduledNotification.m
//  BeatSeekr
//
//  Created by Josip Bernat on 20/11/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSScheduledNotification.h"

@implementation CSScheduledNotification

#pragma mark - Class Methods

+ (id)scheduledNotificationWithName:(NSString *)name
                           fireDate:(NSDate *)fireDate {
    
    return [self scheduledNotificationWithName:name
                                      fireDate:fireDate
                                      userInfo:nil];
}

+ (id)scheduledNotificationWithName:(NSString *)name
                           fireDate:(NSDate *)fireDate
                           userInfo:(NSDictionary *)userInfo {

    CSScheduledNotification *note = [[self alloc] initWithName:name
                                                      fireDate:fireDate
                                                      userInfo:userInfo];
    
    return note;
}

#pragma mark - Initialization

- (id)initWithName:(NSString *)name
          fireDate:(NSDate *)fireDate
          userInfo:(NSDictionary *)userInfo {

    if (self = [super init]) {
        
        self.name = name;
        self.fireDate = fireDate;
        self.userInfo = userInfo;
    }
    
    return self;
}

#pragma mark - Setters 

- (void)setName:(NSString *)name {

    if (!name) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"A notification name can't be nil!"
                               userInfo:nil] raise];
    }
    
    _name = name;
}

- (void)setFireDate:(NSDate *)fireDate {

    if ([[self class] isFireDateValid:fireDate] == NO) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"Fire date must be greather then current [NSDate date]"
                               userInfo:nil] raise];
    }

    _fireDate = fireDate;
}

#pragma mark - Validate

+ (BOOL)isFireDateValid:(NSDate *)fireDate {
    
    NSComparisonResult result = [fireDate compare:[NSDate date]];
    return (result != NSOrderedDescending ? NO : YES);
}

#pragma mark - Description

- (NSString *)description {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    return [NSString stringWithFormat:@"name: %@, fireDate: %@, userInfo: %@",
            _name,
            [dateFormatter stringFromDate:_fireDate],
            _userInfo];
}

@end
