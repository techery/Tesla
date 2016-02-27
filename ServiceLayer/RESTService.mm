//
//  RESTService.mm
//  ServiceLayer
//
//  Created by Petro Korienev on 2/26/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "RESTService.h"
#import "TSLOperationState.h"
#import <map>

const struct RESTHTTPMethodStruct RESTHTTPMethod = {
    .GET = @"GET",
    .POST = @"POST",
    .PUT = @"PUT",
    .PATCH = @"PATCH",
    .DELETE = @"DELETE"
};

@interface RESTService ()

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) std::map<id<RESTServiceRequestProtocol>, NSURLSessionDataTask *> *taskMap;

@end

@implementation RESTService

+ (instancetype)serviceWithBaseURL:(NSURL *)baseURL {
    RESTService *service = [self new];
    service.baseURL = baseURL;
    service.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    service.sessionManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
    service.sessionManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    service.taskMap = new std::map<id<RESTServiceRequestProtocol>, NSURLSessionDataTask *>;
    return service;
}

- (void)addRequest:(id<RESTServiceRequestProtocol>)request
  responseTemplate:(id<RESTServiceResponseProtocol>)responseTemplate {
    if ([[request method] isEqualToString:RESTHTTPMethod.GET]) {
        [self performGETRequestWithRequest:request responseTemplate:responseTemplate];
    }
    if ([[request method] isEqualToString:RESTHTTPMethod.POST]) {
        [self performGETRequestWithRequest:request responseTemplate:responseTemplate];
    }
    if ([[request method] isEqualToString:RESTHTTPMethod.PUT]) {
        [self performGETRequestWithRequest:request responseTemplate:responseTemplate];
    }
    if ([[request method] isEqualToString:RESTHTTPMethod.DELETE]) {
        [self performGETRequestWithRequest:request responseTemplate:responseTemplate];
    }
    if ([[request method] isEqualToString:RESTHTTPMethod.PATCH]) {
        [self performGETRequestWithRequest:request responseTemplate:responseTemplate];
    }
}

- (void)cancelRequest:(id<RESTServiceRequestProtocol> _Nonnull)request {
    NSURLSessionDataTask *dataTask = (*self.taskMap)[request];
    [dataTask cancel];
}

#pragma mark - helper

- (void)performGETRequestWithRequest:(id<RESTServiceRequestProtocol>)request
                    responseTemplate:(id<RESTServiceResponseProtocol>)responseTemplate {
    if (responseTemplate) {
        request.associatedResponse = responseTemplate;
    }
    (*self.taskMap)[request] = [self.sessionManager GET:[request path]
                                             parameters:[request parameters]
                                               progress:^(NSProgress *downloadProgress)
    {
        [self.delegate service:self
                didChangeState:[TSLOperationState stateWithProgress:downloadProgress.fractionCompleted stateValue:TSLOperationStateStarted]
                    forRequest:request];
    }
                     success:^(NSURLSessionDataTask *task, id responseObject)
    {
        
        [self.delegate service:self
                didChangeState:[TSLOperationState stateWithProgress:1 stateValue:TSLOperationStateCompleted]
                    forRequest:request];
    }
                     failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        request.error = [self processError:error];
        [self.delegate service:self
                didChangeState:[TSLOperationState stateWithProgress:1 stateValue:TSLOperationStateError]
                    forRequest:request];
        self.taskMap->erase(request);
    }];
}

- (void)performPOSTRequestWithRequest:(id<RESTServiceRequestProtocol>)request
                     responseTemplate:(id<RESTServiceResponseProtocol>)responseTemplate {
}

- (void)performPUTRequestWithRequest:(id<RESTServiceRequestProtocol>)request
                    responseTemplate:(id<RESTServiceResponseProtocol>)responseTemplate {
}

- (void)performPATCHRequestWithRequest:(id<RESTServiceRequestProtocol>)request
                    responseTemplate:(id<RESTServiceResponseProtocol>)responseTemplate {
}

- (void)performDELETERequestWithRequest:(id<RESTServiceRequestProtocol>)request
                    responseTemplate:(id<RESTServiceResponseProtocol>)responseTemplate {
}

- (NSError *)processError:(NSError *)error {
    return error;
}

@end
