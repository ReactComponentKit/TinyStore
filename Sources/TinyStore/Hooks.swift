//
//  DefineFuncs.swift
//  TinyStore
//
//  Created by burt on 2022/04/13.
//

import Foundation

/// Define Tiny.ScopeStore
/// Parameter name: The name of a ScopeStore
/// Returns: Tiny.ScopeStore
@discardableResult
public func store(name: Tiny.StoreName) -> Tiny.ScopeStore {
    let store = Tiny.ScopeStore(name: name)
    Tiny.scopeStores[name] = store
    return store
}

/// Define Tiny.State
/// Parameter name: The name of a state.
/// Parameter initialValue: The initial value of a state.
/// Parameter store: The container of a state.
/// Return: Tiny.State<Value>
@discardableResult
public func state<Value: Equatable>(name: Tiny.StateName, initialValue: Value, store: Tiny.ScopeStore = Tiny.globalStore) -> Tiny.State<Value> {
    let state = Tiny.State(name: name, initialValue: initialValue)
    store.states[name] = state
    return state
}

/// Define Tiny.EffectValue
@discardableResult
public func effectValue<Value: Equatable>(name: Tiny.EffectName, initialValue: Value, store: Tiny.ScopeStore = Tiny.globalStore, job: @escaping (Tiny.EffectValue<Value>) async -> Value) -> Tiny.EffectValue<Value> {
    let e = Tiny.EffectValue(name: name, initialValue: initialValue, job: job)
    store.effectValues[name] = e
    return e
}

/// Define Tiny.Effect
@discardableResult
public func effect(name: Tiny.EffectName, store: Tiny.ScopeStore = Tiny.globalStore, job: @escaping (Tiny.Effect) async -> Void) -> Tiny.Effect {
    let e = Tiny.Effect(name: name, job: job)
    store.effects[name] = e
    return e
}

/// Get Tiny.ScopeStore instance that has the name.
public func useStore(name: Tiny.StoreName) -> Tiny.ScopeStore {
    if Tiny.scopeStores[name] == nil {
        Tiny.scopeStores[name] = Tiny.ScopeStore(name: name)
    }
    return Tiny.scopeStores[name]!
}

/// Get Tiny.State instance that has the name.
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

/// Get Tiny.EffectValue instance that has the name.
public func useEffectValue<Value: Equatable>(name: Tiny.EffectName) -> Tiny.EffectValue<Value> {
    // does not guaranteed safety.
    // the effect for the name must be in the store.
    for store in Tiny.scopeStores.values {
        if store.effectValues[name] != nil {
            let e = store.effectValues[name] as! Tiny.EffectValue<Value>
            e.didInitialRun = true
            return e
        }
    }
    let e = Tiny.globalStore.effectValues[name] as! Tiny.EffectValue<Value>
    e.didInitialRun = true
    return e
}

/// Get Tiny.Effect instance that has the name.
@discardableResult
public func useEffect(name: Tiny.EffectName) -> Tiny.Effect {
    // safety not guaranteed
    // the effect for the name must be in the store.
    for store in Tiny.scopeStores.values {
        if store.effects[name] != nil {
            let e = store.effects[name] as! Tiny.Effect
            e.didInitialRun = true
            return e
        }
    }
    let e = Tiny.globalStore.effects[name] as! Tiny.Effect
    e.didInitialRun = true
    return e
}
