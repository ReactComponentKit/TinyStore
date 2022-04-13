//
//  DefineFuncs.swift
//  TinyStore
//
//  Created by burt on 2022/04/13.
//

import Foundation

/// define state value
public func state<Value: Equatable>(name: Tiny.StateName, initialValue: Value) -> Tiny.State<Value> {
    let state = Tiny.State(name: name, initialValue: initialValue)
    Tiny.globalStore.states[name] = state
    return state
}

/// define effect that has return value
public func effect<Value: Equatable>(name: Tiny.EffectName, initialValue: Value, job: @escaping (Tiny.Effect<Value>) async -> Value) -> Tiny.Effect<Value> {
    let e = Tiny.Effect(name: name, initialValue: initialValue, job: job)
    Tiny.globalStore.effects[name] = e
    return e
}

/// define effect that has no return value.
public func effect(name: Tiny.EffectName, job: @escaping (Tiny.VoidEffect) async -> Void) -> Tiny.VoidEffect {
    let e = Tiny.VoidEffect(name: name, job: job)
    Tiny.globalStore.voidEffects[name] = e
    return e
}

public func useState<Value: Equatable>(name: Tiny.StateName) -> Tiny.State<Value> {
    // safety not guaranteed
    // the state for the name must be in the store.
    return Tiny.globalStore.states[name] as! Tiny.State<Value>
}

public func useEffect<Value: Equatable>(name: Tiny.EffectName) -> Tiny.Effect<Value> {
    // safety not guaranteed
    // the effect for the name must be in the store.
    return Tiny.globalStore.effects[name] as! Tiny.Effect<Value>
}

public func useEffect(name: Tiny.EffectName) -> Tiny.VoidEffect {
    // safety not guaranteed
    // the effect for the name must be in the store.
    return Tiny.globalStore.voidEffects[name] as! Tiny.VoidEffect
}
