//
//  Effect.swift
//  TinyStore
//
//  Created by burt on 2022/04/13.
//

import Foundation
import Combine

extension Tiny {
    public class Effect: ObservableObject {
        private var watchStates: [AnyHashable: Bool] = [:]
        internal var cancellables = Set<AnyCancellable>()
        internal let name: AnyHashable
        internal let job: (Effect) async -> Void
        private var cacheDidInitialRun = false
        internal var didInitialRun = false {
            didSet {
                guard didInitialRun == true else { return }
                guard cacheDidInitialRun == false else { return }
                cacheDidInitialRun = true
                run()
            }
        }
        
        internal init(name: AnyHashable, job: @escaping (Effect) async -> Void) {
            self.name = name
            self.job = job
        }
        
        public func watch<Value: Equatable>(state name: AnyHashable, store: Tiny.ScopeStore = Tiny.globalStore) -> Tiny.State<Value> {
            let state = store.states[name] as! Tiny.State<Value>
            guard watchStates[state.name] == nil else { return state }
            watchStates[state.name] = true
            state.$value
                .removeDuplicates()
                .sink { [weak self] value in
                    self?.run()
                }
                .store(in: &cancellables)
            return state
        }
        
        public func watch<Value: Equatable>(effectValue name: AnyHashable, store: Tiny.ScopeStore = Tiny.globalStore) -> Tiny.EffectValue<Value> {
            let effectValue = store.effectValues[name] as! Tiny.EffectValue<Value>
            guard watchStates[effectValue.name] == nil else { return effectValue }
            watchStates[effectValue.name] = true
            effectValue.$value
                .removeDuplicates()
                .sink { [weak self] value in
                    self?.run()
                }
                .store(in: &cancellables)
            return effectValue
        }
        
        public func run() {
            Task.detached(priority: .userInitiated) {
                await self.job(self)
            }
        }
    }
}
