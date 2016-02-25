//
//  TSLPipe.h
//  Tesla
//
//  Created by Petro Korienev on 2/25/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLEventServiceDelegate.h"

@interface TSLPipe<Event> : NSObject <TSLEventServiceDelegate>

typedef void(^TSLPipeEventBlock)(TSLPipe<Event> * _Nonnull pipe, _Nonnull Event event);

+ (nonnull instancetype)pipeWithEventClass:(_Nonnull Class<TSLServiceEventProtocol>)eventClass
                                    filter:(NSPredicate * _Nullable)filter;

@end
