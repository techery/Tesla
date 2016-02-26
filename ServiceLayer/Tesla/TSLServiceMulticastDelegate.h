//
//  TSLServiceMulticastDelegate.h
//  ServiceLayer
//
//  Created by Petro Korienev on 2/26/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLEventServiceDelegate.h"
#import "TSLQueryableServiceDelegate.h"

@interface TSLServiceMulticastDelegate : NSObject<TSLEventServiceDelegate, TSLQueryableServiceDelegate>

- (void)attachEventDelegate:(id<TSLEventServiceDelegate>)eventDelegate;
- (void)detachEventDelegate:(id<TSLEventServiceDelegate>)eventDelegate;
- (void)attachQueryableDelegate:(id<TSLQueryableServiceDelegate>)queryableDelegate;
- (void)detachQueryableDelegate:(id<TSLQueryableServiceDelegate>)queryableDelegate;

@end
