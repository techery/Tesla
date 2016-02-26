//
//  TSLQueryableServiceProtocol.h
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSLQueryableServiceDelegate;
@protocol TSLServiceRequestProtocol;
@protocol TSLServiceResponseProtocol;

@protocol TSLQueryableServiceProtocol <NSObject>

- (void)addRequestDelegate:(id<TSLQueryableServiceDelegate> _Nonnull)delegate;
- (void)removeRequestDelegate:(id<TSLQueryableServiceDelegate> _Nonnull)delegate;
- (void)addRequest:(id<TSLServiceRequestProtocol> _Nonnull)request
  responseTemplate:(id<TSLServiceResponseProtocol> _Nullable)responseTemplate;
- (void)cancelRequest:(id<TSLServiceRequestProtocol> _Nonnull)request;
- (BOOL)canHandleRequest:(id<TSLServiceRequestProtocol> _Nonnull)request
                response:(id<TSLServiceResponseProtocol> _Nullable)response;

@end
