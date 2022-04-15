//
//  ScopeStore.swift
//  TinyStore
//
//  Created by sungcheol.kim on 2022/04/13.
//  https://github.com/ReactComponentKit/TinyStore
//

/// store states and effects
extension Tiny {
    public class ScopeStore {
        internal var states = [Tiny.StateName: Any]()
        internal var effects = [Tiny.EffectName: Any]()
        internal var voidEffects = [Tiny.EffectName: Any]()
        
        private var name: Tiny.StoreName
        public init(name: Tiny.StoreName) {
            self.name = name
            Tiny.scopeStores[name] = self
        }
        
        deinit {
            states.removeAll()
            Tiny.scopeStores[name] = nil
        }
    }
}
