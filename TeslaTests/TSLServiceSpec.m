//
//  TSLServiceSpec.m
//  ServiceLayer
//
//  Created by Petro Korienev on 2/27/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "TSLService.h"
#import "TSLOperationState.h"
#import "TSLServiceRequestProtocol.h"
#import "TSLServiceResponseProtocol.h"
#import "TSLServiceEventProtocol.h"

SPEC_BEGIN(TSLServiceSpec)

let(requestDelegateMock, ^KWMock<TSLQueryableServiceDelegate> *{
    return [KWMock mockForProtocol:@protocol(TSLQueryableServiceDelegate)];
});
let(eventDelegateMock, ^KWMock<TSLEventServiceDelegate> *{
    return [KWMock mockForProtocol:@protocol(TSLEventServiceDelegate)];
});
let(operationStateMock, ^TSLOperationState *{
    return [TSLOperationState mock];
});
let(requestMock, ^KWMock<TSLServiceRequestProtocol> *{
    return [KWMock mockForProtocol:@protocol(TSLServiceRequestProtocol)];
});
let(responseMock, ^KWMock<TSLServiceResponseProtocol> *{
    return [KWMock mockForProtocol:@protocol(TSLServiceResponseProtocol)];
});
let(eventMock, ^KWMock<TSLServiceEventProtocol> *{
    return [KWMock mockForProtocol:@protocol(TSLServiceEventProtocol)];
});


describe(@"initialization", ^() {
    
    it(@"should init multicast delegate", ^() {
        TSLService *service = [TSLService alloc];
        KWCaptureSpy *spy = [service captureArgument:@selector(setDelegate:) atIndex:0];
        service = [service init];
        [[spy.argument should] beKindOfClass:[TSLServiceMulticastDelegate class]];
    });
    
    it(@"shoud pass attach request delegate to multicast delegate", ^() {
        TSLService *service = [TSLService new];
        [[service.delegate should] receive:@selector(attachQueryableDelegate:) withArguments:requestDelegateMock];
        [service addRequestDelegate:requestDelegateMock];
    });

    it(@"shoud pass detach request delegate from multicast delegate", ^() {
        TSLService *service = [TSLService new];
        [[service.delegate should] receive:@selector(detachQueryableDelegate:) withArguments:requestDelegateMock];
        [service removeRequestDelegate:requestDelegateMock];
    });

    it(@"shoud pass attach event delegate to multicast delegate", ^() {
        TSLService *service = [TSLService new];
        [[service.delegate should] receive:@selector(attachEventDelegate:) withArguments:eventDelegateMock];
        [service addEventDelegate:eventDelegateMock];
    });

    it(@"shoud pass detach event delegate from multicast delegate", ^() {
        TSLService *service = [TSLService new];
        [[service.delegate should] receive:@selector(detachEventDelegate:) withArguments:eventDelegateMock];
        [service removeEventDelegate:eventDelegateMock];
    });
#ifndef DNS_BLOCK_ASSERTIONS
    it(@"should assert addRequest:responseTemplate: abstract method", ^() {
        [[theBlock(^() {[[TSLService new] addRequest:requestMock responseTemplate:responseMock];}) should] raise];
    });
    
    it(@"should assert cancelRequest: abstract method", ^() {
        [[theBlock(^() {[[TSLService new] cancelRequest:requestMock];}) should] raise];
    });
    
    it(@"should assert canHandleRequest:response: abstract method", ^() {
        [[theBlock(^() {[[TSLService new] canHandleRequest:requestMock response:responseMock];}) should] raise];
    });
    
    it(@"should assert canFireEventOfClass: abstract method", ^() {
        [[theBlock(^() {[[TSLService new] canFireEventsOfClass:[eventMock class]];}) should] raise];
    });
#endif
    
    it(@"should have serviceId", ^() {
        TSLService *service = [TSLService new];
        [[service.serviceId should] startWithString:@"io.techery.tesla.TSLService"];
    });
    
    it(@"should create serviceId once", ^() {
        TSLService *service = [TSLService new];
        [NSString stub:@selector(stringWithFormat:) andReturn:nil];
        [[[service serviceId] should] beNil];
        [NSString stub:@selector(stringWithFormat:) andReturn:@"io.techery.tesla.TSLService"];
        [[[service serviceId] should] equal:@"io.techery.tesla.TSLService"];
    });
});

SPEC_END