//
//  CSScheduledNotificationCenter.m
//  BeatSeekr
//
//  Created by Josip Bernat on 20/11/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSScheduledNotificationCenter.h"
#import "CSScheduledNotification.h"

NSString * const kCSScheduledInternalNotificationKey = @"kCSScheduledInternalNotificationKey";

@interface CSScheduledNotificationCenter ()

@property (nonatomic, strong) NSMutableDictionary *timersDictionary;
@property (nonatomic, strong) NSMutableDictionary *observersDictionary;

@end

@implementation CSScheduledNotificationCenter

+ (instancetype)defaultCenter {

    static dispatch_once_t onceToken;
    static CSScheduledNotificationCenter *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

#pragma mark - Starting

+ (void)start {
    [self defaultCenter];
}

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
        
        self.timersDictionary = [[NSMutableDictionary alloc] init];
        self.observersDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Adding Schedule

+ (void)addObserver:(id)notificationObserver
           selector:(SEL)selector
               name:(NSString *)notificationName {
    
    [[CSScheduledNotificationCenter defaultCenter] addObserver:notificationObserver
                                                      selector:selector
                                                          name:notificationName];
}

- (void)addObserver:(id)notificationObserver
           selector:(SEL)selector
               name:(NSString *)notificationName {
    
    NSMethodSignature *methodSignature = [[notificationObserver class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = selector;
    invocation.target = notificationObserver;
    
    if (methodSignature.numberOfArguments > 2) {
        [invocation setArgument:&notificationName atIndex:2];
    }
    
    NSMutableSet *observers = [self observersForName:notificationName];
    [observers addObject:invocation];
}

#pragma mark - Removing Observers

+ (void)removeObserver:(id)notificationObserver
                  name:(NSString *)notificationName {

    if (!notificationObserver) {
        return;
    }
    
    [[CSScheduledNotificationCenter defaultCenter] removeObserver:notificationObserver
                                                             name:notificationName];
}

- (void)removeObserver:(id)notificationObserver
                  name:(NSString *)notificationName {

    NSMutableSet *observers = [self observersForName:notificationName];
    [observers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
       
        NSInvocation *invocation = (NSInvocation *)obj;
        if ([invocation.target isEqual:notificationObserver]) {
            [observers removeObject:invocation];
        }
    }];
    
    if (observers.count == 0) {
        [self invalidateNotificationTimer:notificationName];
    }
}

- (void)fireObserversForNotification:(CSScheduledNotification *)note {
    
    __weak id notification = note;
    NSMutableSet *observers = [self observersForName:[note name]];
    [observers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
       
        NSInvocation *invocation = (NSInvocation *)obj;
        if (invocation.methodSignature.numberOfArguments > 2) {
            __strong id strongNote = notification;
            [invocation setArgument:&strongNote atIndex:2];
        }
        [invocation invoke];
    }];
}

#pragma mark - Timers

- (void)invalidateNotificationTimer:(NSString *)notificationName {

    NSTimer *timer = _timersDictionary[notificationName];
    [timer invalidate];
}

- (void)addNotificationTimer:(CSScheduledNotification *)notification {

    [self invalidateNotificationTimer:[notification name]];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:[notification.fireDate timeIntervalSinceNow]
                                             target:self
                                           selector:@selector(onNotificationTimer:)
                                           userInfo:@{kCSScheduledInternalNotificationKey: notification}
                                            repeats:NO];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer
              forMode:NSRunLoopCommonModes];
    
    _timersDictionary[[notification name]] = timer;
}

#pragma mark - Timer Selectors

- (void)onNotificationTimer:(NSTimer *)timer {

    [self fireObserversForNotification:timer.userInfo[kCSScheduledInternalNotificationKey]];
}

#pragma mark - Getting Observers

- (NSMutableSet *)observersForName:(NSString *)notificationName {
    
    id value = _observersDictionary[notificationName];
    if (!value) {
        value = [[NSMutableSet alloc] init];
        _observersDictionary[notificationName] = value;
    }
    return value;
}

#pragma mark - Adding Notifications

+ (void)addScheduledNotification:(CSScheduledNotification *)notification {
    
    [[CSScheduledNotificationCenter defaultCenter] addNotification:notification];
}

- (void)addNotification:(CSScheduledNotification *)notification {
    
    if (!notification.name) {
        
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"A notification name can't be nil!"
                               userInfo:nil] raise];
    }
    
    [self addNotificationTimer:notification];
}

#pragma mark - Removing Notifications

+ (void)removeScheduledNotification:(CSScheduledNotification *)notification {
    
    [[CSScheduledNotificationCenter defaultCenter] removeNotification:notification];
}

- (void)removeNotification:(CSScheduledNotification *)notification {
    
    if (!notification.name) {
        
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"A notification name can't be nil!"
                               userInfo:nil] raise];
    }
    
    [self invalidateNotificationTimer:notification.name];
}

@end
