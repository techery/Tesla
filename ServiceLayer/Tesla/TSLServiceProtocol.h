//
//  TSLServiceProtocol.h
//  ServiceLayer
//
//  Created by Petro Korienev on 2/25/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLQueryableServiceProtocol.h"
#import "TSLEventServiceProtocol.h"

@protocol TSLServiceProtocol <TSLQueryableServiceProtocol, TSLEventServiceProtocol>

@end
