//
//  TSLServiceMulticastDelegate.mm
//  ServiceLayer
//
//  Created by Petro Korienev on 2/26/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLServiceMulticastDelegate.h"
#import <libkern/OSAtomic.h>
#import <list>

@interface TSLServiceMulticastDelegate ()

@property (nonatomic, assign) std::list<__weak id<TSLQueryableServiceDelegate>> *requestDelegates;
@property (nonatomic, assign) std::list<__weak id<TSLEventServiceDelegate>> *eventDelegates;
@property (nonatomic, assign) OSSpinLock requestDelegatesLock;
@property (nonatomic, assign) OSSpinLock eventDelegatesLock;

@end

@implementation TSLServiceMulticastDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestDelegates = new std::list<__weak id<TSLQueryableServiceDelegate>>;
        self.eventDelegates = new std::list<__weak id<TSLEventServiceDelegate>>;
        self.requestDelegatesLock = OS_SPINLOCK_INIT;
        self.eventDelegatesLock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)service:(id<TSLQueryableServiceProtocol>)service
 didChangeState:(TSLOperationState *)state
     forRequest:(id<TSLServiceRequestProtocol>)request {
    OSSpinLockLock(&_requestDelegatesLock);
    for (auto delegate : *self.requestDelegates) {
        [delegate service:service didChangeState:state forRequest:request];
    }
    OSSpinLockUnlock(&_requestDelegatesLock);
}

- (void)service:(id<TSLEventServiceProtocol>)service
   didFireEvent:(id<TSLServiceEventProtocol>)event {
    OSSpinLockLock(&_eventDelegatesLock);
    for (auto delegate : *self.eventDelegates) {
        [delegate service:service didFireEvent:event];
    }
    OSSpinLockUnlock(&_eventDelegatesLock);
}

- (void)attachQueryableDelegate:(id<TSLQueryableServiceDelegate>)queryableDelegate {
    OSSpinLockLock(&_requestDelegatesLock);
    self.requestDelegates->push_back(queryableDelegate);
    OSSpinLockUnlock(&_requestDelegatesLock);
}

- (void)detachQueryableDelegate:(id<TSLQueryableServiceDelegate>)queryableDelegate {
    OSSpinLockLock(&_requestDelegatesLock);
    self.requestDelegates->remove(queryableDelegate);
    OSSpinLockUnlock(&_requestDelegatesLock);
}

- (void)attachEventDelegate:(id<TSLEventServiceDelegate>)eventDelegate {
    OSSpinLockLock(&_eventDelegatesLock);
    self.eventDelegates->push_back(eventDelegate);
    OSSpinLockUnlock(&_eventDelegatesLock);
}

- (void)detachEventDelegate:(id<TSLEventServiceDelegate>)eventDelegate {
    OSSpinLockLock(&_eventDelegatesLock);
    self.eventDelegates->remove(eventDelegate);
    OSSpinLockUnlock(&_eventDelegatesLock);
}

- (void)dealloc {
    delete self.requestDelegates;
    delete self.eventDelegates;
}

@end
