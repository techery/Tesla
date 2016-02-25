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

- (void)addDelegate:(id<TSLQueryableServiceDelegate>)delegate;
- (void)removeDelegate:(id<TSLQueryableServiceDelegate>)delegate;
- (void)addRequest:(id<TSLServiceRequestProtocol>)request
  responseTemplate:(id<TSLServiceResponseProtocol>)responseTemplate;
- (void)cancelRequest:(id<TSLServiceRequestProtocol>)request;

@end
