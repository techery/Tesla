//
//  TSLCondition.h
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSLCondition<State> : NSObject

+ (nonnull instancetype)conditionWithSubject:(_Nonnull State)subject;
+ (BOOL)evaluateSubject:(_Nonnull State)subject againstState:(_Nonnull State)state;
- (BOOL)evaluateAgainstState:(_Nonnull State)state;

@end
