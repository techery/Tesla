//
//  Tesla.m
//  ServiceLayer
//
//  Created by Petro Korienev on 2/25/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//

#import "Tesla.h"
#import "TSLServiceProtocol.h"

@interface Tesla ()

@property (nonatomic, strong) NSMutableArray<id<TSLQueryableServiceProtocol>> *queryableServices;
@property (nonatomic, strong) NSMutableArray<id<TSLEventServiceProtocol>> *eventServices;

@end

@implementation Tesla

+ (nonnull instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^() {
        sharedInstance = [Tesla new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queryableServices = [NSMutableArray new];
        self.eventServices = [NSMutableArray new];
    }
    return self;
}

- (nullable id<TSLQueryableServiceProtocol>)queryableServiceForRequest:(id<TSLServiceRequestProtocol>)request
                                                              response:(id<TSLServiceResponseProtocol>)response {
    id<TSLQueryableServiceProtocol> result = nil;
    @synchronized(self.queryableServices) {
        for (id<TSLQueryableServiceProtocol> service in self.queryableServices) {
            if ([service canHandleRequest:request response:response]) {
                result = service;
            }
        }
    }
    return result;
}

- (nullable id<TSLEventServiceProtocol>)eventServiceForEventClass:(Class<TSLServiceEventProtocol>)eventClass {
    id<TSLEventServiceProtocol> result = nil;
    @synchronized(self.eventServices) {
        for (id<TSLEventServiceProtocol> service in self.eventServices) {
            if ([service canFireEventsOfClass:eventClass]) {
                result = service;
            }
        }
    }
    return result;
}

- (void)registerService:(id<TSLServiceProtocol> _Nonnull)service {
    [self registerEventService:service];
    [self registerQueryableService:service];
}

- (void)unregisterService:(id<TSLServiceProtocol> _Nonnull)service {
    [self unregisterEventService:service];
    [self unregisterQueryableService:service];
}

- (void)registerQueryableService:(id<TSLQueryableServiceProtocol> _Nonnull)service {
    @synchronized(self.queryableServices) {
        [self.queryableServices addObject:service];
    }
}

- (void)unregisterQueryableService:(id<TSLQueryableServiceProtocol> _Nonnull)service {
    @synchronized(self.queryableServices) {
        [self.queryableServices removeObject:service];
    }
}

- (void)registerEventService:(id<TSLEventServiceProtocol> _Nonnull)service {
    @synchronized(self.eventServices) {
        [self.eventServices addObject:service];
    }
}

- (void)unregisterEventService:(id<TSLEventServiceProtocol> _Nonnull)service {
    @synchronized(self.eventServices) {
        [self.eventServices removeObject:service];
    }
}

@end
