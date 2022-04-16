//
//  ProperyWrappers.swift
//  TinyStore
//
//  Created by burt on 2022/04/16.
//

import Foundation

@propertyWrapper
public struct UseState<Value: Equatable> {
    private var state: Tiny.State<Value>
    public init(name: AnyHashable) {
        self.state = useState(name: name)
    }
    
    public var wrappedValue: Tiny.State<Value> {
        return state
    }
}

@propertyWrapper
public struct UseEffectValue<Value: Equatable> {
    private var effectValue: Tiny.EffectValue<Value>
    
    public init(name: AnyHashable) {
        self.effectValue = useEffectValue(name: name)
    }
    
    public var wrappedValue: Tiny.EffectValue<Value> {
        return effectValue
    }
}

@propertyWrapper
public struct UseEffect {
    private var effect: Tiny.Effect
    
    public init(name: AnyHashable) {
        self.effect = useEffect(name: name)
    }
    
    public var wrappedValue: Tiny.Effect {
        return effect
    }
}
