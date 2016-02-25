//
//  TSLPipe.m
//  Tesla
//
//  Created by Petro Korienev on 2/25/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLPipe.h"

#import "TSLServiceEventProtocol.h"
#import "Tesla.h"

@interface TSLPipe ()

@property (nonatomic, assign, nonnull) Class<TSLServiceEventProtocol> eventClass;
@property (nonatomic, strong, nullable) NSPredicate *filter;
@property (nonatomic, copy, nonnull) TSLPipeEventBlock eventBlock;

@end

@implementation TSLPipe

#pragma mark - lifecycle & state management

+ (instancetype)pipeWithEventClass:(Class<TSLServiceEventProtocol> _Nonnull)eventClass
                            filter:(NSPredicate * _Nullable)filter
                        eventBlock:(TSLPipeEventBlock _Nonnull)eventBlock {
    TSLPipe *pipe = [self new];
    pipe.eventClass = eventClass;
    pipe.filter = filter;
    pipe.eventBlock = eventBlock;
    return pipe;
}

- (void)start {
    
}

- (void)suspend {
    
}

- (void)resume {
    
}

- (void)stop {
    
}

#pragma mark - TSLEventServiceDelegate

- (void)service:(id<TSLEventServiceProtocol>)service
   didFireEvent:(id<TSLServiceEventProtocol>)event {
    if ([event isKindOfClass:self.eventClass]) {
        if (!self.filter || [self.filter evaluateWithObject:event]) {
            self.eventBlock(self, event);
        }
    }
}

@end
