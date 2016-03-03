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
    private var currentOperation : TSLOperation? = nil
    @IBOutlet private weak var label : UILabel!
    @IBOutlet private weak var activityIndicator : UIActivityIndicatorView!
    private var loaded : UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let errorClosure = {[weak self](operation : TSLOperation) -> Void in
            let error : String? = self?.currentOperation?.error()?.localizedDescription
            self?.completeWithError(error)
        }
        var sequenceClosure : ((operation : TSLOperation) -> Void)? = nil
        sequenceClosure = {[weak weakSelf = self](operation : TSLOperation) -> Void in
            if let strongSelf = weakSelf {
                let response : RESTResponse? = strongSelf.currentOperation?.response() as? RESTResponse;
                if strongSelf.shouldContinueAfterResponse(response) {
                    let nextPage : UInt = (strongSelf.currentOperation?.executingRequest().page)! + 1
                    strongSelf.loaded = strongSelf.loaded + UInt(strongSelf.eventCountForResponse(response))
                    strongSelf.runOperation(nextPage, successClosure:sequenceClosure!, errorClosure:errorClosure)
                }
                else {
                    strongSelf.completeWithError(nil)
                }
            }
        }
        self.runOperation(1, successClosure:sequenceClosure!, errorClosure:errorClosure)
        self.activityIndicator.startAnimating()
    }
    
    private func operationForPage(page : UInt) -> TSLOperation! {
        let request : RESTRequest = RESTRequest()
        request.method = "GET"
        request.page = page
        request.path = "_query?input=webpage/url:http%3A%2F%2Fdou.ua%2Fcalendar%2Fpage-\(page)%2F&&_apikey=7054e2e6c2bd4c2eb90e56164c635a9076eba370601cfec63bf4576e5ea8f3362885e9eb5b6ebb6e3b9a1b44886414e0fbf3a958debe2163c048b2862198f7976ccedeaa8fe256edd8f7bee146bfa97b"
        return TSLOperation(request: request, responseTemplate: nil)
    }
    
    private func completeWithError(error : String?) {
        dispatch_async(dispatch_get_main_queue(), {[weak weakSelf = self] () -> Void in
            if let strongSelf = weakSelf {
                strongSelf.activityIndicator.stopAnimating()
                strongSelf.label.text = "Loaded \(strongSelf.loaded) events.\n\(error)"
            }
        })
    }
    
    private func runOperation(page : UInt, successClosure : TSLOperationActionBlock, errorClosure : TSLOperationActionBlock) {
        self.currentOperation = self.operationForPage(page)
        self.currentOperation?.onRunBlock(TSLOperationState.completedState(), successClosure)
        self.currentOperation?.onRunBlock(TSLOperationState.errorState(), errorClosure)
        self.currentOperation?.run()
    }
    
    private func shouldContinueAfterResponse(response : RESTResponse?) -> Bool {
        return self.eventCountForResponse(response) != NSNotFound && self.eventCountForResponse(response) > 0
    }
    
    private func eventCountForResponse(response : RESTResponse?) -> Int {
        guard let response = response else {
            return NSNotFound
        }
        guard let body : Dictionary<String, Array<AnyObject>> = response.serializedResponseBody as? Dictionary else {
            return NSNotFound
        }
        guard let array : Array<AnyObject> = body["results"] else {
            return NSNotFound
        }
        return array.count
    }
}

