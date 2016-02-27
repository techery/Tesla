//
//  RESTService.h
//  ServiceLayer
//
//  Created by Petro Korienev on 2/26/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "TSLService.h"

typedef struct RESTHTTPMethodStruct {
    __unsafe_unretained NSString *GET;
    __unsafe_unretained NSString *POST;
    __unsafe_unretained NSString *PUT;
    __unsafe_unretained NSString *PATCH;
    __unsafe_unretained NSString *DELETE;
} RESTHTTPMethodStruct;

@protocol RESTServiceResponseProtocol <NSObject>

- (id)serializedResponseBody;
- (NSData *)deserializedResponseBody;
- (NSHTTPURLResponse *)HTTPResponse;

@end

@protocol RESTServiceRequestProtocol <TSLServiceRequestProtocol>

@required
- (NSString *)path;
- (NSString *)method;

@property (nonatomic, strong) id<RESTServiceResponseProtocol> associatedResponse;
@property (nonatomic, strong) NSError *error;

@optional
- (NSDictionary *)parameters;

@end


@interface RESTService : TSLService

+ (instancetype)serviceWithBaseURL:(NSURL *)baseURL;

@end
