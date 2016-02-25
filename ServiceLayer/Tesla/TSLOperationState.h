//
//  TSLOperationState.h
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TSLOperationStateEnum) {
    TSLOperationStateInitial,
    TSLOperationStateStarted,
    TSLOperationStateCompleted,
    TSLOperationStateCancelled,
    TSLOperationStateError
};

@interface TSLOperationState : NSObject

+ (nonnull instancetype)initialState;
+ (nonnull instancetype)startedState;
+ (nonnull instancetype)completedState;
+ (nonnull instancetype)cancelledState;
+ (nonnull instancetype)errorState;
+ (nonnull instancetype)stateWithProgress:(float)progress; // TSLOperationStateStarted by default
+ (nonnull instancetype)stateWithProgress:(float)progress
                               stateValue:(TSLOperationStateEnum)stateValue;

@property (nonatomic, assign, readonly) TSLOperationStateEnum stateValue;
@property (nonatomic, assign, readonly) float progress;

@end
