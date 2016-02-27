//
//  TSLService.h
//  ServiceLayer
//
//  Created by Petro Korienev on 2/26/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLServiceMulticastDelegate.h"
#import "TSLServiceProtocol.h"

@interface TSLService : NSObject <TSLServiceProtocol>

@property (nonatomic, strong) TSLServiceMulticastDelegate *delegate;
- (NSString *)serviceId;

@end
