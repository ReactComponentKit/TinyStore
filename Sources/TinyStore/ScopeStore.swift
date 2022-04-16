//
//  ScopeStore.swift
//  TinyStore
//
//  Created by sungcheol.kim on 2022/04/13.
//  https://github.com/ReactComponentKit/TinyStore
//

import Foundation

/// store states and effects
extension Tiny {
    public class ScopeStore {
        internal var states = [Tiny.StateName: Any]()
        internal var effectValues = [Tiny.EffectName: Any]()
        internal var effects = [Tiny.EffectName: Any]()
        private var name: Tiny.StoreName
        public init(name: Tiny.StoreName) {
            self.name = name
            Tiny.scopeStores[name] = self
        }
        
        deinit {
            states.removeAll()
            effectValues.removeAll()
            effects.removeAll()
        }
    }
}
