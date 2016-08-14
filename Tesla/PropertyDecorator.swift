//
//  Fields.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/9/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation

public struct ValueStoreError : Error {
    
}

public protocol ReadonlyProperty {
    func get() -> Any
    func valueType() -> Any.Type
}

public protocol WritableProperty : ReadonlyProperty {
    func set(_ val:Any) throws
}

public protocol Property : WritableProperty {
    
}

public class PropertyDecorator<T> : Property {
    public var value:T?
    
    public func get() -> Any {
        return value
    }
    
    public func set(_ val:T) {
        self.value = val
    }
    
    public func set(_ val:Any) throws  {
        if val is T {
            value = val as? T
        } else {
            throw ValueStoreError()
        }
    }
    
    public func valueType() -> Any.Type {
        return T.self
    }
}



class PropertiesParser<T> {
    
    static func getAllTargetProps(mirror:Mirror) -> [Any] {
        let props = mirror.children.map({ (child) -> Any in
            return child.value
        })
        
        if let parent = mirror.superclassMirror {
            return props + getAllTargetProps(mirror: parent)
        } else {
            return props
        }
    }
    
    var actionProps:Array<Any>
    
    init(_ target:T) {
        let mirror = Mirror(reflecting: target)
        
        self.actionProps = PropertiesParser.getAllTargetProps(mirror: mirror)
    }
    
    func getProps<T>(_ propType:T.Type) -> [T] {
        var props = Array<T>()
        
        actionProps = actionProps.filter { (item) -> Bool in
            if let prop = item as? T {
                props.append(prop)
                return false
            } else {
                return true
            }
        }
        
        return props
    }
    
    func getProp<T>(_ propType:T.Type) -> T? {
        let props = getProps(propType)
        
        assert(props.count <= 1, "Multiple \(propType) declaration. Only 1 declaration is allowed.")
        
        return props.first
    }
}


