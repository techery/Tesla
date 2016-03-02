//
//  TSLAction.m
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLAction.h"
#import "TSLOperation.h"

@interface TSLAction ()

@property (nonatomic, copy, nullable) TSLActionBlock block;
@property (nonatomic, strong, nullable) TSLOperation *operation;

@end

@implementation TSLAction

+ (instancetype)actionWithBlock:(TSLActionBlock)block {
    TSLAction *action = [self new];
    action.block = block;
    return action;
}

+ (instancetype)actionWithOperation:(TSLOperation *)operation {
    TSLAction *action = [self new];
    action.operation = operation;
    return action;
}

- (void)runWithSourceOperation:(id)operation {
    [self runBlockWithSourceOperationIfPossible:operation];
    [self runOperationIfPossible];
}

- (void)runBlockWithSourceOperationIfPossible:(id)operation {
    if (self.block) {
        self.block(operation);
    }
}

- (void)runOperationIfPossible {
    if (self.operation) {
        [self.operation run];
    }
}

@end
