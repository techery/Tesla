//
//  RoutableService.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/14/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation

protocol ActionRoute {
    func accepts(_ action:Any) -> Bool
    func run(_ action:Any)
}

class ActionRouteHolder<T> : ActionRoute {
    
    typealias RouteBody<T> = (action:T) -> Void
    typealias RouteBodyWithThrow<T> = (action:T) throws -> Void
    
    let body:RouteBody<T>
    
    init(_ body:RouteBody<T>) {
        self.body = body
    }
    
    func accepts(_ action:Any) -> Bool {
        return action is T
    }
    
    func run(_ action:Any) {
        if let castedAction = action as? T {
            self.body(action: castedAction)
        } else {
            assertionFailure("Can't cast action \(action) to \(T.self)")
        }
    }
}

class RoutingActionService<R:TeslaAction> : TypedActionService {
    
    typealias ActionType = R
    
    var routes:[ActionRoute] = []
    var callback:ActionServiceCallback?
    
    func acceptsType(_ actionType:Any.Type) -> Bool {
        return actionType is ActionType.Type || actionType.self == ActionType.self
    }
    
    func executeAction(_ action:ActionType) throws {
        if let handler = findRouteHandlerFor(action: action) {
            handler.run(action)
        } else {
            assertionFailure("Can't find handler for action: \(action)")
        }
    }        
    
    func findRouteHandlerFor<T>(action:T) -> ActionRoute? {
        return self.routes.first { (route) -> Bool in
            return route.accepts(action)
        }
    }
    
    func use<T>(_ routeHolderBody:ActionRouteHolder<T>.RouteBody<T>) {
        routes.append(ActionRouteHolder(routeHolderBody))
    }
    
    func useWithAutoCallback<T:TeslaAction>(_ routeHolderBody:ActionRouteHolder<T>.RouteBodyWithThrow<T>) {
        self.use { (action:T) in
            do {
                self.onStart(action as! ActionType)
                try routeHolderBody(action: action)
                self.onSuccess(action as! ActionType)
            } catch {
                self.onError(action as! ActionType, error: error)
            }
        }
    }
}
