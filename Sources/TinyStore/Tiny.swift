//
//  Tiny.swift
//  TinyStore
//
//  Created by sungcheol.kim on 2022/04/13.
//  https://github.com/ReactComponentKit/TinyStore
//

import Foundation

/// Namespace Tiny.
public enum Tiny {
    public typealias StoreName = AnyHashable
    public typealias StateName = AnyHashable
    public typealias EffectName = AnyHashable
    internal enum GlobalScope {
        case store
    }
    public static var globalStore = ScopeStore(name: GlobalScope.store)
    internal static var scopeStores: [Tiny.StoreName: ScopeStore] = [:]
}
