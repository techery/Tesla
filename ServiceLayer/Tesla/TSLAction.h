//
//  TSLAction.h
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLOperation;

@interface TSLAction : NSObject

+ (instancetype)actionWithOperation:(TSLOperation *)operation;
+ (instancetype)actionWithBlock:(void(^)())block;
- (void)run;

@end