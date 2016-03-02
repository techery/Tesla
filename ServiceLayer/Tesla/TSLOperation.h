//
//  TSLOperation.h
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLQueryableServiceDelegate.h"
#import "TSLCondition.h"
#import "TSLAction.h"

@interface TSLOperation<Request, State, Response> : NSObject <TSLQueryableServiceDelegate>

typedef void(^TSLOperationActionBlock)(TSLOperation * _Nonnull);

typedef TSLOperation<Request, State, Response> * _Nonnull(^TSLOperationOnRunPromise)(_Nonnull State, TSLOperation * _Nonnull);
typedef TSLOperation<Request, State, Response> * _Nonnull(^TSLOperationOnRunBlockPromise)(_Nonnull State, _Nonnull TSLOperationActionBlock);
typedef TSLOperation<Request, State, Response> * _Nonnull(^TSLOperationOnConditionRunPromise)(TSLCondition<State> * _Nonnull, TSLOperation * _Nonnull);
typedef TSLOperation<Request, State, Response> * _Nonnull(^TSLOperationOnConditionRunBlockPromise)(TSLCondition<State> * _Nonnull, _Nonnull TSLOperationActionBlock);

- (nullable NSError *)error;
- (nullable Response)response;
- (nonnull Request)executingRequest;
- (nonnull State)currentState;

+ (nonnull instancetype)operationWithRequest:(_Nonnull Request)request
                            responseTemplate:(_Nullable Response)responseTemplate;

- (void)on:(_Nonnull State)state run:(TSLOperation * _Nonnull)operation;
- (void)on:(_Nonnull State)state runBlock:(_Nonnull TSLOperationActionBlock)block;
- (void)onCondition:(TSLCondition<State> * _Nonnull)condition run:(TSLOperation * _Nonnull)operation;
- (void)onCondition:(TSLCondition<State> * _Nonnull)condition runBlock:(_Nonnull TSLOperationActionBlock)block;

@property (nonatomic, strong, readonly, nonnull) TSLOperationOnRunPromise onRun;
@property (nonatomic, strong, readonly, nonnull) TSLOperationOnRunBlockPromise onRunBlock;
@property (nonatomic, strong, readonly, nonnull) TSLOperationOnConditionRunPromise onConditionRun;
@property (nonatomic, strong, readonly, nonnull) TSLOperationOnConditionRunBlockPromise onConditionRunBlock;

- (void)run;
- (void)cancel;

@end
