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
@protocol TSLServiceRequestProtocol;
@protocol TSLServiceResponseProtocol;
@protocol TSLServiceEventProtocol;

@protocol TSLServiceLocatorProtocol <NSObject>

- (id<TSLQueryableServiceProtocol>)queryableServiceForRequest:(id<TSLServiceRequestProtocol>)request
                                                     response:(id<TSLServiceResponseProtocol>)response;
- (id<TSLEventServiceProtocol>)eventServiceForEventClass:(Class<TSLServiceEventProtocol>)eventClass;

@end
