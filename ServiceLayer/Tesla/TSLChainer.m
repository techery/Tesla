//
//  TSLChainer.m
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLChainer.h"

@interface TSLChainer ()

@property (nonatomic, strong) id chainingCondition;
@property (nonatomic, strong) id chainingAction;

@end

@implementation TSLChainer

+ (instancetype)chainerWithCondition:(id)condition action:(id)action {
    TSLChainer *chainer = [self new];
    chainer.chainingCondition = condition;
    chainer.chainingAction = action;
    return chainer;
}

@end
