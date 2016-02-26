//
//  TSLOperation.m
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "TSLOperation.h"

#import "TSLAction.h"
#import "TSLChainer.h"
#import "TSLOperationState.h"
#import "Tesla.h"
#import "TSLQueryableServiceProtocol.h"
#import "TSLServiceRequestProtocol.h"
#import "TSLServiceResponseProtocol.h"

@interface TSLOperation () {
    TSLOperationState *_currentState;
}

@property (nonatomic, weak) id<TSLServiceLocatorProtocol> serviceLocator;
@property (nonatomic, weak) id<TSLQueryableServiceProtocol> service;

@property (nonatomic, strong) id error;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) id executingRequest;
@property (nonatomic, strong) TSLOperationState *currentState;
@property (nonatomic, strong) NSMutableArray<TSLChainer *> *chainers;

@end

@implementation TSLOperation

#pragma mark - lifecycle & state management

+ (instancetype)operationWithRequest:(id)request responseTemplate:(id)responseTemplate {
    TSLOperation *operation = [self new];
    operation.executingRequest = request;
    operation.response = responseTemplate;
    operation.currentState = TSLOperationState.initialState;
    return operation;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.chainers = [NSMutableArray new];
        self.serviceLocator = [Tesla sharedInstance];
    }
    return self;
}

- (void)dealloc {
    [self cancelInternal];
}

- (void)run {
    dispatch_async(dispatch_get_global_queue(0, 0), ^() {
        self.service = [self.serviceLocator queryableServiceForRequest:self.executingRequest
                                                              response:self.response];
        [self.service addDelegate:self];
        [self.service addRequest:self.executingRequest
                responseTemplate:self.response];
    });
}

- (void)cancel {
    dispatch_async(dispatch_get_global_queue(0, 0), ^() {
        [self cancelInternal];
    });
}

- (void)cancelInternal {
    [self.service cancelRequest:self.executingRequest];
    [self.service removeDelegate:self];
}

- (void)on:(TSLOperationState *)state run:(TSLOperation *)operation {
    TSLCondition<TSLOperationState *> *condition = [TSLCondition conditionWithSubject:state];
    [self onCondition:condition run:operation];
}

- (void)on:(TSLOperationState *)state runBlock:(void (^)())block {
    TSLCondition<TSLOperationState *> *condition = [TSLCondition conditionWithSubject:state];
    [self onCondition:condition runBlock:block];
}

- (void)onCondition:(TSLCondition *)condition run:(TSLOperation *)operation {
    TSLAction *action = [TSLAction actionWithOperation:operation];
    TSLChainer<TSLCondition *, TSLAction *> *chainer = [TSLChainer chainerWithCondition:condition action:action];
    [self.chainers addObject:chainer];
}

- (void)onCondition:(TSLCondition *)condition runBlock:(void (^)())block {
    TSLAction *action = [TSLAction actionWithBlock:block];
    TSLChainer<TSLCondition *, TSLAction *> *chainer = [TSLChainer chainerWithCondition:condition action:action];
    [self.chainers addObject:chainer];
}

#pragma mark - TSLQueryableServiceDelegate

- (void)service:(id<TSLQueryableServiceProtocol> _Nonnull)service
 didChangeState:(TSLOperationState * _Nonnull)state
     forRequest:(id<TSLServiceRequestProtocol> _Nonnull)request {
    if (request == self.executingRequest) {
        self.currentState = state;
        self.response = [request associatedResponse];
        self.error = [request error];
        [self verifyChainersAgainstState:state];
        [self verifyOperationAgainstState:state];
    }
}

#pragma mark - State handling

- (void)verifyChainersAgainstState:(TSLOperationState *)currentState {
    for (TSLChainer<TSLCondition *, TSLAction *> *chainer in self.chainers) {
        if ([chainer.chainingCondition evaluateAgainstState:currentState]) {
            [chainer.chainingAction run];
        }
    }
}

- (void)verifyOperationAgainstState:(TSLOperationState *)currentState {
    [self verifyOperationAgainstStateCancelled:currentState];
    [self verifyOperationAgainstStateCompleted:currentState];
    [self verifyOperationAgainstStateError:currentState];
}

- (void)verifyOperationAgainstStateCancelled:(TSLOperationState *)currentState {
    if (currentState.stateValue == TSLOperationStateCancelled) {
        [self.service removeDelegate:self];
    }
}

- (void)verifyOperationAgainstStateCompleted:(TSLOperationState *)currentState {
    if (currentState.stateValue == TSLOperationStateCompleted) {
        [self.service removeDelegate:self];
    }
}

- (void)verifyOperationAgainstStateError:(TSLOperationState *)currentState {
    if (currentState.stateValue == TSLOperationStateError) {
        [self.service removeDelegate:self];
    }
}

@end
