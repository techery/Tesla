//
//  TSLPipe.m
//  Tesla
//
//  Created by Petro Korienev on 2/25/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLPipe.h"

@implementation TSLPipe

#pragma mark - TSLEventServiceDelegate

+ (instancetype)pipeWithEventClass:(Class<TSLServiceEventProtocol>)eventClass filter:(NSPredicate *)filter {
    TSLPipe *pipe = [self new];
    return pipe;
}

- (void)service:(id<TSLEventServiceProtocol>)service
   didFireEvent:(id<TSLServiceEventProtocol>)event {
    
}

@end
