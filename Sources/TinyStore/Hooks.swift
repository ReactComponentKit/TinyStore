//
//  DefineFuncs.swift
//  TinyStore
//
//  Created by burt on 2022/04/13.
//

import Foundation

@discardableResult
public func store(name: Tiny.StoreName) -> Tiny.ScopeStore {
    return Tiny.ScopeStore(name: name)
}

/// define state value
@discardableResult
public func state<Value: Equatable>(name: Tiny.StateName, initialValue: Value, store: Tiny.ScopeStore = Tiny.globalStore) -> Tiny.State<Value> {
    let state = Tiny.State(name: name, initialValue: initialValue)
    store.states[name] = state
    return state
}

/// define effect that has return value
@discardableResult
public func effect<Value: Equatable>(name: Tiny.EffectName, initialValue: Value, store: Tiny.ScopeStore = Tiny.globalStore, job: @escaping (Tiny.Effect<Value>) async -> Value) -> Tiny.Effect<Value> {
    let e = Tiny.Effect(name: name, initialValue: initialValue, job: job)
    store.effects[name] = e
    return e
}

/// define effect that has no return value.
@discardableResult
public func effect(name: Tiny.EffectName, store: Tiny.ScopeStore = Tiny.globalStore, job: @escaping (Tiny.VoidEffect) async -> Void) -> Tiny.VoidEffect {
    let e = Tiny.VoidEffect(name: name, job: job)
    store.voidEffects[name] = e
    return e
}

public func useStore(name: Tiny.StoreName) -> Tiny.ScopeStore {
    // does not guaranteed safety.
    // the store for the name must be in the container.
    return Tiny.scopeStores[name]!
}

public func useState<Value: Equatable>(name: Tiny.StateName) -> Tiny.State<Value> {
    // does not guaranteed safety.
    // the state for the name must be in the store.
    for store in Tiny.scopeStores.values {
        if store.states[name] != nil {
            return store.states[name] as! Tiny.State<Value>
        }
    }
    return Tiny.globalStore.states[name] as! Tiny.State<Value>
}

public func useEffect<Value: Equatable>(name: Tiny.EffectName) -> Tiny.Effect<Value> {
    // does not guaranteed safety.
    // the effect for the name must be in the store.
    for store in Tiny.scopeStores.values {
        if store.effects[name] != nil {
            let e = store.effects[name] as! Tiny.Effect<Value>
            e.didInitialRun = true
            return e
        }
    }
    let e = Tiny.globalStore.effects[name] as! Tiny.Effect<Value>
    e.didInitialRun = true
    return e
}

public func useEffect(name: Tiny.EffectName) -> Tiny.VoidEffect {
    // safety not guaranteed
    // the effect for the name must be in the store.
    for store in Tiny.scopeStores.values {
        if store.voidEffects[name] != nil {
            let e = store.voidEffects[name] as! Tiny.VoidEffect
            e.didInitialRun = true
            return e
        }
    }
    let e = Tiny.globalStore.voidEffects[name] as! Tiny.VoidEffect
    e.didInitialRun = true
    return e
}
