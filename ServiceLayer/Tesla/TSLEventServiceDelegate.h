//
//  TSLEventServiceDelegate.h
//  Tesla
//
//  Created by Petro Korienev on 2/25/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSLEventServiceProtocol;
@protocol TSLServiceEventProtocol;

@protocol TSLEventServiceDelegate <NSObject>

- (void)service:(id<TSLEventServiceProtocol>)service
   didFireEvent:(id<TSLServiceEventProtocol>)event;

@end
