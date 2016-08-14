//
//  HTTPService.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/14/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

public class HTTPActionService : TypedActionService {
    public typealias ActionType = HTTPActionWireframe
    
    struct ValidationError : Error {
        let message:String
        
        init(_ message:String) {
            self.message = message
        }
    }
    
    public var callback:ActionServiceCallback?
    
    public init() {
        
    }
    
    public func acceptsType(_ actionType:Any.Type) -> Bool {
        return actionType is HTTPActionWireframe.Type || actionType.self == HTTPActionWireframe.self
    }
    
    private static func convertHTTPMethodToAlamofire(_ httpMethod:HTTPMethod) -> Alamofire.HTTPMethod {
        switch httpMethod {
        case .GET:
            return Alamofire.HTTPMethod.get
        case .POST:
            return Alamofire.HTTPMethod.post
        case .PUT:
            return Alamofire.HTTPMethod.put
        case .DELETE:
            return Alamofire.HTTPMethod.delete
        case .HEAD:
            return Alamofire.HTTPMethod.head
        }
    }
    
    var currentRequest:Request?
    
    public func executeAction(_ action:HTTPActionWireframe) throws {
        self.onStart(action)
        
        let actionScheme = HTTPActionScheme.createFrom(action: action)
        
        let path = actionScheme.path.value
        let method = HTTPActionService.convertHTTPMethodToAlamofire(actionScheme.method)
        
        currentRequest = Alamofire.request(path, withMethod: method).responseString(completionHandler: { (response) in
            
            if let error = response.result.error {
                self.onError(action, error: error)
            } else {
                do {
                    if let responseProperty = actionScheme.responses.first {
                        try responseProperty.set(response.result.value)
                    }
                } catch {
                    print(error)
                }
                
                self.onSuccess(action)
            }
        })
    }
    
    public func cancel(_ action: TeslaAction) {
        print("Cancel:\(action)")
        currentRequest?.cancel()
    }
}
