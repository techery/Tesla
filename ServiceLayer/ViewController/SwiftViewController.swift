//
//  SwiftViewController.swift
//  ServiceLayer
//
//  Created by Petro Korienev on 3/3/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation
import UIKit

class SwiftViewController : UIViewController {
    private var currentOperation : TSLOperation? = nil;
    @IBOutlet private weak var label : UILabel!
    @IBOutlet private weak var activityIndicator : UIActivityIndicatorView!
    private var loaded : UInt = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        weak var weakSelf : SwiftViewController? = self;
        let errorBlock = {(operation : TSLOperation) -> Void in
            let error : String? = weakSelf?.currentOperation?.error()?.localizedDescription
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                weakSelf!.activityIndicator.stopAnimating()
                weakSelf!.label.text = "Loaded \((weakSelf?.loaded)!) events.\n\(error)"
            })
        }
        var sequenceBlock : ((operation : TSLOperation) -> Void)? = nil
        sequenceBlock = {(operation : TSLOperation) -> Void in
            if weakSelf!.currentOperation?.response()?.serializedResponseBody().isKindOfClass(NSDictionary) != false &&
                weakSelf!.currentOperation?.response()?.serializedResponseBody()["results"]??.count != 0  {
                let nextPage : UInt = (weakSelf?.currentOperation?.executingRequest().page)! + 1
                weakSelf!.loaded = weakSelf!.loaded + UInt((weakSelf!.currentOperation?.response()?.serializedResponseBody()["results"]??.count)!)
                weakSelf!.currentOperation = weakSelf!.operationForPage(nextPage)
                weakSelf!.currentOperation?.onRunBlock(TSLOperationState.completedState(), sequenceBlock!)
                weakSelf!.currentOperation?.onRunBlock(TSLOperationState.errorState(), errorBlock)
                weakSelf!.currentOperation?.run()
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    weakSelf!.activityIndicator.stopAnimating()
                    weakSelf!.label.text = "Loaded \((weakSelf?.loaded)!) events"
                })
            }
        }
        self.currentOperation = self.operationForPage(1)
        self.currentOperation?.onRunBlock(TSLOperationState.completedState(), sequenceBlock!)
        self.currentOperation?.onRunBlock(TSLOperationState.errorState(), errorBlock)
        self.currentOperation?.run()
        self.activityIndicator.startAnimating()
    }
    
    private func operationForPage(page : UInt) -> TSLOperation! {
        let request : RESTRequest = RESTRequest()
        request.method = "GET"
        request.page = page
        request.path = "_query?input=webpage/url:http%3A%2F%2Fdou.ua%2Fcalendar%2Fpage-\(page)%2F&&_apikey=7054e2e6c2bd4c2eb90e56164c635a9076eba370601cfec63bf4576e5ea8f3362885e9eb5b6ebb6e3b9a1b44886414e0fbf3a958debe2163c048b2862198f7976ccedeaa8fe256edd8f7bee146bfa97b"
        return TSLOperation(request: request, responseTemplate: nil)
    }
}

