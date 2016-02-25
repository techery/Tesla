//
//  TSLQueryableServiceDelegate.h
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSLQueryableServiceProtocol;
@protocol TSLServiceRequestProtocol;
@class TSLOperationState;

@protocol TSLQueryableServiceDelegate <NSObject>

- (void)service:(id<TSLQueryableServiceProtocol>)service
 didChangeState:(TSLOperationState *)state
     forRequest:(id<TSLServiceRequestProtocol>)request;

@end
