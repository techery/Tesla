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

@property (nonatomic, copy) void(^block)();
@property (nonatomic, strong) TSLOperation *operation;

@end

@implementation TSLAction

+ (instancetype)actionWithBlock:(void (^)())block {
    TSLAction *action = [self new];
    action.block = block;
    return action;
}

+ (instancetype)actionWithOperation:(TSLOperation *)operation {
    TSLAction *action = [self new];
    action.operation = operation;
    return action;
}

- (void)run {
    if (self.block) {
        self.block();
    }
    else if (self.operation) {
        [self.operation run];
    }
}

@end
