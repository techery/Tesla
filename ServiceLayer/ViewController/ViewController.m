//
//  ViewController.m
//  Tesla
//
//  Created by Petro Korienev on 2/24/16.
//  Copyright © 2016 Techery. All rights reserved.
//

#import "ViewController.h"
#import "TSLOperationState.h"
#import "TSLOperation.h"
#import "RESTRequest.h"
#import "RESTResponse.h"

@interface ViewController ()

@property (nonatomic, strong) TSLOperation<RESTRequest *, TSLOperationState *, RESTResponse *> *currentOperation;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (atomic, assign) NSUInteger loaded;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    __block void(^errorBlock)() = ^()
    {
        NSString *error = weakSelf.currentOperation.error.localizedDescription;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.activityIndicator stopAnimating];
            weakSelf.label.text = [NSString stringWithFormat:@"Loaded %lu events.\n%@", weakSelf.loaded, error];
        });
    };
    __block void(^sequenceBlock)() = ^()
    {
        if ([weakSelf.currentOperation.response.serializedResponseBody isKindOfClass:[NSDictionary class]] &&
            [weakSelf.currentOperation.response.serializedResponseBody [@"results"] count]) {
            NSUInteger nextPage = weakSelf.currentOperation.executingRequest.page + 1;
            weakSelf.loaded += [weakSelf.currentOperation.response.serializedResponseBody[@"results"] count];
            weakSelf.currentOperation = [weakSelf operationForPage:nextPage];
            [weakSelf.currentOperation on:TSLOperationState.completedState
                                 runBlock:sequenceBlock];
            [weakSelf.currentOperation on:TSLOperationState.errorState
                                 runBlock:errorBlock];
            [weakSelf.currentOperation run];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.activityIndicator stopAnimating];
                weakSelf.label.text = [NSString stringWithFormat:@"Loaded %lu events", self.loaded];
            });
        }
    };
    self.currentOperation = [self operationForPage:1];
    [self.currentOperation on:TSLOperationState.completedState
                     runBlock:sequenceBlock];
    [self.currentOperation on:TSLOperationState.errorState
                     runBlock:errorBlock];
    [self.currentOperation run];
    [self.activityIndicator startAnimating];
}

- (TSLOperation<RESTRequest *, TSLOperationState *, RESTResponse *> *)operationForPage:(NSUInteger)page {
    RESTRequest *request = [RESTRequest new];
    request.method = @"GET";
    request.page = page;
    request.path = [NSString stringWithFormat:@"_query?input=webpage/url:http%%3A%%2F%%2Fdou.ua%%2Fcalendar%%2Fpage-%lu%%2F&&_apikey=7054e2e6c2bd4c2eb90e56164c635a9076eba370601cfec63bf4576e5ea8f3362885e9eb5b6ebb6e3b9a1b44886414e0fbf3a958debe2163c048b2862198f7976ccedeaa8fe256edd8f7bee146bfa97b", page];
    return [TSLOperation operationWithRequest:request responseTemplate:nil];
}

@end
