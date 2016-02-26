//
//  TSLEventServiceProtocol.h
//  Tesla
//
//  Created by Petro Korienev on 2/25/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSLEventServiceDelegate;
@protocol TSLServiceEventProtocol;

@protocol TSLEventServiceProtocol <NSObject>

- (void)addEventDelegate:(id<TSLEventServiceDelegate> _Nonnull)delegate;
- (void)removeEventDelegate:(id<TSLEventServiceDelegate> _Nonnull)delegate;
- (BOOL)canFireEventsOfClass:(Class<TSLServiceEventProtocol> _Nonnull)eventClass;

@end
