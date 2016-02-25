//
//  TSLCondition.m
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLCondition.h"
#import "TSLOperationState.h"

@interface TSLCondition ()

@property (nonatomic, strong) TSLOperationState *subject;

@end

@implementation TSLCondition

+ (nonnull instancetype)conditionWithSubject:(TSLOperationState * _Nonnull )subject {
    TSLCondition *condition = [self new];
    condition.subject = subject;
    return condition;
}

+ (BOOL)evaluateSubject:(TSLOperationState * _Nonnull)subject
           againstState:(TSLOperationState * _Nonnull)state {
    return [subject isEqual:state];
}

- (BOOL)evaluateAgainstState:(TSLOperationState * _Nonnull)state {
    return [[self class] evaluateSubject:self.subject againstState:state];
}

@end
