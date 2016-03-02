//
//  TSLChainer.m
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLChainer.h"

@interface TSLChainer ()

@property (nonatomic, strong, nonnull) id chainingCondition;
@property (nonatomic, strong, nonnull) id chainingAction;
@property (nonatomic, weak, nullable) id sourceOperation;

@end

@implementation TSLChainer

+ (nonnull instancetype)chainerWithCondition:(_Nonnull id)condition
                                      action:(_Nonnull id)action
                             sourceOperation:(_Nonnull id)sourceOperation {
    TSLChainer *chainer = [self new];
    chainer.chainingCondition = condition;
    chainer.chainingAction = action;
    chainer.sourceOperation = sourceOperation;
    return chainer;
}

@end
