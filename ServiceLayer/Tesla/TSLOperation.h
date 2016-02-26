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

@interface TSLOperation<Request, State, Response> : NSObject <TSLQueryableServiceDelegate>

- (nullable NSError *)error;
- (nullable Response)response;
- (nonnull Request)executingRequest;
- (nonnull State)currentState;

+ (nonnull instancetype)operationWithRequest:(_Nonnull Request)request
                            responseTemplate:(_Nullable Response)responseTemplate;

- (void)on:(_Nonnull State)state run:(TSLOperation * _Nonnull)operation;
- (void)on:(_Nonnull State)state runBlock:(void(^ _Nonnull)())block;
- (void)onCondition:(TSLCondition<State> * _Nonnull)condition run:(TSLOperation * _Nonnull)operation;
- (void)onCondition:(TSLCondition<State> * _Nonnull)condition runBlock:(void(^ _Nonnull)())block;

- (void)run;
- (void)cancel;

@end
