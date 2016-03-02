//
//  TSLServiceMulticastDelegateSpec.mm
//  TeslaTests
//
//  Created by Petro Korienev on 2/26/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "TSLServiceMulticastDelegate.h"
#import "TSLServiceProtocol.h"
#import "TSLOperationState.h"
#import "TSLServiceRequestProtocol.h"
#import "TSLServiceEventProtocol.h"
#import <list>

@interface TSLServiceMulticastDelegate (Test)

@property (nonatomic, assign) std::list<__weak id<TSLQueryableServiceDelegate>> *requestDelegates;
@property (nonatomic, assign) std::list<__weak id<TSLEventServiceDelegate>> *eventDelegates;

@end

SPEC_BEGIN(TSLServiceMulticastDelegateSpec)

let(requestDelegateMock1, ^KWMock<TSLQueryableServiceDelegate> *{
    return [KWMock mockForProtocol:@protocol(TSLQueryableServiceDelegate)];
});
let(requestDelegateMock2, ^KWMock<TSLQueryableServiceDelegate> *{
    return [KWMock mockForProtocol:@protocol(TSLQueryableServiceDelegate)];
});
let(eventDelegateMock1, ^KWMock<TSLEventServiceDelegate> *{
    return [KWMock mockForProtocol:@protocol(TSLEventServiceDelegate)];
});
let(eventDelegateMock2, ^KWMock<TSLEventServiceDelegate> *{
    return [KWMock mockForProtocol:@protocol(TSLEventServiceDelegate)];
});
let(serviceMock, ^KWMock<TSLServiceProtocol> *{
    return [KWMock mockForProtocol:@protocol(TSLServiceProtocol)];
});
let(operationStateMock, ^TSLOperationState *{
    return [TSLOperationState mock];
});
let(requestMock, ^KWMock<TSLServiceRequestProtocol> *{
    return [KWMock mockForProtocol:@protocol(TSLServiceRequestProtocol)];
});
let(eventMock, ^KWMock<TSLServiceEventProtocol> *{
    return [KWMock mockForProtocol:@protocol(TSLServiceEventProtocol)];
});

describe(@"managing delegates", ^() {
    
    it(@"should attach request delegate only to request delegates list", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [delegate attachQueryableDelegate:requestDelegateMock1];
        XCTAssert(std::find(delegate.requestDelegates->cbegin(),
                            delegate.requestDelegates->cend(),
                            requestDelegateMock1) != delegate.requestDelegates->cend());
        XCTAssert(std::find(delegate.eventDelegates->cbegin(),
                            delegate.eventDelegates->cend(),
                            requestDelegateMock1) == delegate.eventDelegates->cend());
    });
    
#ifndef DNS_BLOCK_ASSERTIONS
    it(@"should assert on object non-conformant to TSLQueryableServiceDelegate", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [[theBlock(^{[delegate attachQueryableDelegate:(id<TSLQueryableServiceDelegate>)eventDelegateMock1];}) should] raise];
    });
#endif

    it(@"should attach event delegate", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [delegate attachEventDelegate:eventDelegateMock1];
        XCTAssert(std::find(delegate.eventDelegates->cbegin(),
                            delegate.eventDelegates->cend(),
                            eventDelegateMock1) != delegate.eventDelegates->cend());
        XCTAssert(std::find(delegate.requestDelegates->cbegin(),
                            delegate.requestDelegates->cend(),
                            eventDelegateMock1) == delegate.requestDelegates->cend());
    });
    
#ifndef DNS_BLOCK_ASSERTIONS
    it(@"should assert on object non-conformant to TSLEventServiceDelegate", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [[theBlock(^{[delegate attachEventDelegate:(id<TSLEventServiceDelegate>)requestDelegateMock1];}) should] raise];
    });
#endif
    
    it(@"should broadcast state change to all request delegates", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [delegate attachQueryableDelegate:requestDelegateMock1];
        [delegate attachQueryableDelegate:requestDelegateMock2];
        [[requestDelegateMock1 shouldEventuallyBeforeTimingOutAfter(0.01)] receive:@selector(service:didChangeState:forRequest:)
                                 withArguments:serviceMock, operationStateMock, requestMock];
        [[requestDelegateMock2 shouldEventuallyBeforeTimingOutAfter(0.01)] receive:@selector(service:didChangeState:forRequest:)
                                 withArguments:serviceMock, operationStateMock, requestMock];
        [delegate service:serviceMock didChangeState:operationStateMock forRequest:requestMock];
    });
    
    it(@"should broadcast event to all event delegates", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [delegate attachEventDelegate:eventDelegateMock1];
        [delegate attachEventDelegate:eventDelegateMock2];
        [[eventDelegateMock1 shouldEventuallyBeforeTimingOutAfter(0.01)] receive:@selector(service:didFireEvent:)
                                 withArguments:serviceMock, eventMock];
        [[eventDelegateMock2 shouldEventuallyBeforeTimingOutAfter(0.01)] receive:@selector(service:didFireEvent:)
                                 withArguments:serviceMock, eventMock];
        [delegate service:serviceMock didFireEvent:eventMock];
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    it(@"should not retain request delegate", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        NSUInteger retainCount = (NSUInteger)((__bridge void *)[requestDelegateMock1 performSelector:NSSelectorFromString(@"retainCount")]);
        [delegate attachQueryableDelegate:requestDelegateMock1];
        NSUInteger retainCountNew = (NSUInteger)((__bridge void *)[requestDelegateMock1 performSelector:NSSelectorFromString(@"retainCount")]);
        [[theValue(retainCountNew - retainCount) should] equal:theValue(0)];
    });

    it(@"should not retain event delegate", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        NSUInteger retainCount = (NSUInteger)((__bridge void *)[eventDelegateMock1 performSelector:NSSelectorFromString(@"retainCount")]);
        [delegate attachEventDelegate:eventDelegateMock1];
        NSUInteger retainCountNew = (NSUInteger)((__bridge void *)[eventDelegateMock1 performSelector:NSSelectorFromString(@"retainCount")]);
        [[theValue(retainCountNew - retainCount) should] equal:theValue(0)];
    });
#pragma clang diagnostic pop
    
    it(@"should detach request delegate when attached previously", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [delegate attachQueryableDelegate:requestDelegateMock1];
        [delegate detachQueryableDelegate:requestDelegateMock1];
        XCTAssert(std::find(delegate.requestDelegates->cbegin(),
                            delegate.requestDelegates->cend(),
                            requestDelegateMock1) == delegate.requestDelegates->cend());
    });
    
    it(@"should detach request delegate when wasn't attached previously", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [delegate detachQueryableDelegate:requestDelegateMock1];
        XCTAssert(std::find(delegate.requestDelegates->cbegin(),
                            delegate.requestDelegates->cend(),
                            requestDelegateMock1) == delegate.requestDelegates->cend());
    });
    
    it(@"should detach event delegate when attached previously", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [delegate attachEventDelegate:eventDelegateMock1];
        [delegate detachEventDelegate:eventDelegateMock1];
        XCTAssert(std::find(delegate.eventDelegates->cbegin(),
                            delegate.eventDelegates->cend(),
                            eventDelegateMock1) == delegate.eventDelegates->cend());
    });
    
    it(@"should detach event delegate when wasn't attached previously", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        [delegate detachEventDelegate:eventDelegateMock1];
        XCTAssert(std::find(delegate.eventDelegates->cbegin(),
                            delegate.eventDelegates->cend(),
                            eventDelegateMock1) == delegate.eventDelegates->cend());
    });
    
    it(@"should support ARC weak behaviour for request delegate", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        KWMock<TSLQueryableServiceDelegate> * __unsafe_unretained mockPointer = nil;
        @autoreleasepool {
            mockPointer = [KWMock mockForProtocol:@protocol(TSLQueryableServiceDelegate)];
            [delegate attachQueryableDelegate:mockPointer];
            XCTAssert(std::find(delegate.requestDelegates->cbegin(),
                                delegate.requestDelegates->cend(),
                                mockPointer) != delegate.requestDelegates->cend());
        }
        XCTAssert(std::find(delegate.requestDelegates->cbegin(),
                            delegate.requestDelegates->cend(),
                            mockPointer) == delegate.requestDelegates->cend());
    });
    
    it(@"should support ARC weak behaviour for event delegate", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        KWMock<TSLEventServiceDelegate> * __unsafe_unretained mockPointer = nil;
        @autoreleasepool {
            mockPointer = [KWMock mockForProtocol:@protocol(TSLEventServiceDelegate)];
            [delegate attachEventDelegate:mockPointer];
            XCTAssert(std::find(delegate.eventDelegates->cbegin(),
                                delegate.eventDelegates->cend(),
                                mockPointer) != delegate.eventDelegates->cend());
        }
        XCTAssert(std::find(delegate.eventDelegates->cbegin(),
                            delegate.eventDelegates->cend(),
                            mockPointer) == delegate.eventDelegates->cend());
    });
    
    it(@"should safely broadcast states after one of ARC weak delegates deallocation", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        KWMock<TSLQueryableServiceDelegate> * __unsafe_unretained mockPointer = nil;
        @autoreleasepool {
            mockPointer = [KWMock mockForProtocol:@protocol(TSLQueryableServiceDelegate)];
            [delegate attachQueryableDelegate:mockPointer];
            [delegate attachQueryableDelegate:requestDelegateMock1];
        }
        [[requestDelegateMock1 shouldEventuallyBeforeTimingOutAfter(0.01)] receive:@selector(service:didChangeState:forRequest:)
                                 withArguments:serviceMock, operationStateMock, requestMock];
        [delegate service:serviceMock didChangeState:operationStateMock forRequest:requestMock];
    });
    
    it(@"should safely broadcast event after one of ARC weak delegates deallocation", ^() {
        TSLServiceMulticastDelegate *delegate = [TSLServiceMulticastDelegate new];
        KWMock<TSLEventServiceDelegate> * __unsafe_unretained mockPointer = nil;
        @autoreleasepool {
            mockPointer = [KWMock mockForProtocol:@protocol(TSLEventServiceDelegate)];
            [delegate attachEventDelegate:mockPointer];
            [delegate attachEventDelegate:eventDelegateMock1];
        }
        [[eventDelegateMock1 shouldEventuallyBeforeTimingOutAfter(0.01)] receive:@selector(service:didFireEvent:)];
        [delegate service:serviceMock didFireEvent:eventMock];
    });
});

SPEC_END