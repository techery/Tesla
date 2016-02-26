//
//  TSLService.m
//  ServiceLayer
//
//  Created by Petro Korienev on 2/26/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLService.h"

@implementation TSLService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = [TSLServiceMulticastDelegate new];
    }
    return self;
}

- (void)addRequestDelegate:(id<TSLQueryableServiceDelegate>)delegate {
    [self.delegate attachQueryableDelegate:delegate];
}

- (void)removeRequestDelegate:(id<TSLQueryableServiceDelegate>)delegate {
    [self.delegate detachQueryableDelegate:delegate];
}

- (void)addEventDelegate:(id<TSLEventServiceDelegate>)delegate {
    [self.delegate attachEventDelegate:delegate];
}

- (void)removeEventDelegate:(id<TSLEventServiceDelegate>)delegate {
    [self.delegate detachEventDelegate:delegate];
}

- (void)addRequest:(id<TSLServiceRequestProtocol>)request
  responseTemplate:(id<TSLServiceResponseProtocol>)responseTemplate {
    NSAssert(NO, @"%s Should be overriden in subclass", __PRETTY_FUNCTION__);
}

- (void)cancelRequest:(id<TSLServiceRequestProtocol>)request {
    NSAssert(NO, @"%s Should be overriden in subclass", __PRETTY_FUNCTION__);
}

- (BOOL)canHandleRequest:(id<TSLServiceRequestProtocol>)request
                response:(id<TSLServiceResponseProtocol>)response {
    NSAssert(NO, @"%s Should be overriden in subclass", __PRETTY_FUNCTION__);
    return NO;
}

- (BOOL)canFireEventsOfClass:(Class<TSLServiceEventProtocol>)eventClass {
    NSAssert(NO, @"%s Should be overriden in subclass", __PRETTY_FUNCTION__);
    return NO;
}

@end
