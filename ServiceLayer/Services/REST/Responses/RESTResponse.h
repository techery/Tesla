//
//  RESTResponse.h
//  ServiceLayer
//
//  Created by Petro Korienev on 2/27/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTService.h"

@interface RESTResponse : NSObject <RESTServiceResponseProtocol>

@property (nonatomic, strong) id serializedResponseBody;
@property (nonatomic, strong) NSData *deserializedResponseBody;
@property (nonatomic, strong) NSHTTPURLResponse *HTTPResponse;

@end
