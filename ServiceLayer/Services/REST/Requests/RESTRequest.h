//
//  RESTRequest.h
//  ServiceLayer
//
//  Created by Petro Korienev on 2/27/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTService.h"
#import "RESTResponse.h"

@interface RESTRequest : NSObject <RESTServiceRequestProtocol>

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSDictionary *parameters;

@property (nonatomic, strong) RESTResponse *associatedResponse;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign) NSUInteger page;

@end
