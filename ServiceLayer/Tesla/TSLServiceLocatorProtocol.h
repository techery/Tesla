//
//  TSLServiceLocatorProtocol.h
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSLQueryableServiceProtocol;
@protocol TSLEventServiceProtocol;
@protocol TSLServiceProtocol;
@protocol TSLServiceRequestProtocol;
@protocol TSLServiceResponseProtocol;
@protocol TSLServiceEventProtocol;

@protocol TSLServiceLocatorProtocol <NSObject>

- (nullable id<TSLQueryableServiceProtocol>)queryableServiceForRequest:(id<TSLServiceRequestProtocol> _Nonnull)request
                                                              response:(id<TSLServiceResponseProtocol> _Nullable)response;
- (nullable id<TSLEventServiceProtocol>)eventServiceForEventClass:(Class<TSLServiceEventProtocol> _Nonnull)eventClass;

- (void)registerService:(id<TSLServiceProtocol> _Nonnull)service;
- (void)unregisterService:(id<TSLServiceProtocol> _Nonnull)service;

- (void)registerQueryableService:(id<TSLQueryableServiceProtocol> _Nonnull)service;
- (void)unregisterQueryableService:(id<TSLQueryableServiceProtocol> _Nonnull)service;

- (void)registerEventService:(id<TSLEventServiceProtocol> _Nonnull)service;
- (void)unregisterEventService:(id<TSLEventServiceProtocol> _Nonnull)service;

@end
