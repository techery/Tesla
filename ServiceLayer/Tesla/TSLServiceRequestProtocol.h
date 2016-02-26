//
//  TSLServiceRequestProtocol.h
//  Tesla
//
//  Created by Petro Korienev on 2/25/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSLServiceResponseProtocol;

@protocol TSLServiceRequestProtocol <NSObject>

- (nonnull id<TSLServiceResponseProtocol>)associatedResponse;
- (nonnull NSError *)error;

@end
