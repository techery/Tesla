//
//  HTTPActionScheme.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/13/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation

struct HTTPActionScheme {
    typealias ActionType = HTTPActionWireframe
    
    static func createFrom(action:HTTPActionWireframe) -> HTTPActionScheme {
        let parser = PropertiesParser(action)
        
        let path = parser.getProp(Path.self)!
        let method = parser.getProp(HTTPMethod.self)!
        
        let responses = parser.getProps(ResponseProperty.self)
        
        let queryFields = parser.getProps(QueryFieldProperty.self)
        let formFields = parser.getProps(FormFieldProperty.self)
        
        let bodyProperty = parser.getProp(BodyProperty.self)
        
        let scheme = HTTPActionScheme(
            path: path,
            method: method,
            queryFields: queryFields,
            formFields: formFields,
            bodyField: bodyProperty,
            responses: responses
        )
        
        scheme.validate()
        
        return scheme
    }
    
    let path:Path
    let method:HTTPMethod
    
    let queryFields:[QueryFieldProperty]
    let formFields:[FormFieldProperty]
    let bodyField:BodyProperty?
    
    let responses:[ResponseProperty]
    
    func validate() {
        if (self.method == .POST && (self.formFields.isEmpty || self.bodyField == nil)) {
            assertionFailure("Request with method POST should contains form fields")
        }
    }
}
