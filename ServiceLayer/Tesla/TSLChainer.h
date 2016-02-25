//
//  TSLChainer.h
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSLChainer<Condition, Action> : NSObject

+ (nonnull instancetype)chainerWithCondition:(_Nonnull Condition)condition
                                      action:(_Nonnull Action)action;
- (nonnull Condition)chainingCondition;
- (nonnull Action)chainingAction;

@end
