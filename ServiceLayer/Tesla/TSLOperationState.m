//
//  TSLOperationState.m
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLOperationState.h"

@interface TSLOperationState ()

@property (nonatomic, assign, readwrite) TSLOperationStateEnum stateValue;
@property (nonatomic, assign, readwrite) float progress;

@end

@implementation TSLOperationState

+ (instancetype)initialState {
    TSLOperationState *state = [self new];
    state.stateValue = TSLOperationStateInitial;
    return state;
}

+ (instancetype)startedState {
    TSLOperationState *state = [self new];
    state.stateValue = TSLOperationStateStarted;
    return state;
}

+ (instancetype)completedState {
    TSLOperationState *state = [self new];
    state.stateValue = TSLOperationStateCompleted;
    return state;
}

+ (instancetype)cancelledState {
    TSLOperationState *state = [self new];
    state.stateValue = TSLOperationStateCancelled;
    return state;
}

+ (instancetype)errorState {
    TSLOperationState *state = [self new];
    state.stateValue = TSLOperationStateError;
    return state;
}

+ (instancetype)stateWithProgress:(float)progress {
    return [self stateWithProgress:progress stateValue:TSLOperationStateStarted];
}

+ (instancetype)stateWithProgress:(float)progress
                       stateValue:(TSLOperationStateEnum)stateValue {
    TSLOperationState *state = [self new];
    state.progress = progress;
    state.stateValue = stateValue;
    return state;
}

- (BOOL)isEqual:(TSLOperationState *)obj {
    return ([obj isKindOfClass:[self class]] && self.stateValue == obj.stateValue && self.progress == obj.progress);
}

@end
