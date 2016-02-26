//
//  TSLPipe.m
//  Tesla
//
//  Created by Petro Korienev on 2/25/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLPipe.h"

#import "TSLEventServiceProtocol.h"
#import "TSLServiceEventProtocol.h"
#import "Tesla.h"

@interface TSLPipe ()

@property (nonatomic, weak) id<TSLServiceLocatorProtocol> serviceLocator;
@property (nonatomic, weak) id<TSLEventServiceProtocol> service;

@property (nonatomic, assign, nonnull) Class<TSLServiceEventProtocol> eventClass;
@property (nonatomic, strong, nullable) NSPredicate *filter;
@property (nonatomic, copy, nonnull) TSLPipeEventBlock eventBlock;
@property (atomic, assign, readwrite) BOOL isSuspended;

@end

@implementation TSLPipe

#pragma mark - lifecycle & state management

+ (instancetype)pipeWithEventClass:(Class<TSLServiceEventProtocol> _Nonnull)eventClass
                            filter:(NSPredicate * _Nullable)filter
                        eventBlock:(TSLPipeEventBlock _Nonnull)eventBlock {
    TSLPipe *pipe = [self new];
    pipe.eventClass = eventClass;
    pipe.filter = filter;
    pipe.eventBlock = eventBlock;
    pipe.serviceLocator = [Tesla sharedInstance];
    return pipe;
}

- (void)dealloc {
    [self stopInternal];
}

- (void)start {
    dispatch_async(dispatch_get_global_queue(0, 0), ^() {
        self.service = [self.serviceLocator eventServiceForEventClass:self.eventClass];
        [self.service addEventDelegate:self];
    });
}

- (void)suspend {
    dispatch_async(dispatch_get_global_queue(0, 0), ^() {
        self.isSuspended = YES;
    });
}

- (void)resume {
    dispatch_async(dispatch_get_global_queue(0, 0), ^() {
        self.isSuspended = NO;
    });
}

- (void)stop {
    dispatch_async(dispatch_get_global_queue(0, 0), ^() {
        [self stopInternal];
    });
}

- (void)stopInternal {
    [self.service removeEventDelegate:self];
}

#pragma mark - TSLEventServiceDelegate

- (void)service:(id<TSLEventServiceProtocol>)service
   didFireEvent:(id<TSLServiceEventProtocol>)event {
    if (!self.isSuspended &&
        [event isKindOfClass:self.eventClass] &&
        (!self.filter || [self.filter evaluateWithObject:event])) {
        self.eventBlock(self, event);
    }
}

@end
