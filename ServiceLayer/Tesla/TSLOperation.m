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
#import "TSLServiceLocatorProtocol.h"
#import "TSLQueryableServiceProtocol.h"
#import "TSLServiceRequestProtocol.h"
#import "TSLServiceResponseProtocol.h"

@interface TSLOperation () {
    TSLOperationState *_currentState;
}

@property (nonatomic, strong) id<TSLServiceLocatorProtocol> serviceLocator;
@property (nonatomic, strong) id<TSLQueryableServiceProtocol> service;

@property (nonatomic, strong) id error;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) id executingRequest;
@property (nonatomic, strong) TSLOperationState *currentState;
@property (nonatomic, strong) NSMutableArray<TSLChainer *> *chainers;

@end

@implementation TSLOperation

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
//      Assign or inject
//        self.serviceLocator =
    }
    return self;
}

- (void)run {
    dispatch_async(dispatch_get_global_queue(0, 0), ^() {
        self.service = [self.serviceLocator queryableServiceForRequest:self.executingRequest
                                                              response:self.response];
    });
}

- (void)cancel {
    
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

- (void)setCurrentState:(TSLOperationState *)currentState {
    _currentState = currentState;
}

- (TSLOperationState *)currentState {
    return _currentState;
}

#pragma mark - TSLQueryableServiceDelegate

- (void)service:(id<TSLQueryableServiceProtocol>)service
 didChangeState:(TSLOperationState *)state
     forRequest:(id<TSLServiceRequestProtocol>)request {
    
}

@end
