//
//  TSLAction.h
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLOperation;

@interface TSLAction<Operation> : NSObject

typedef void(^TSLActionBlock)(_Nonnull Operation);

+ (nonnull instancetype)actionWithOperation:(_Nonnull Operation)operation;
+ (nonnull instancetype)actionWithBlock:(_Nonnull TSLActionBlock)block;
- (void)runWithSourceOperation:(_Nonnull Operation)operation;

@end