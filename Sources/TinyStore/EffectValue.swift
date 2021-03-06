//
//  EffectValue.swift
//  TinyStore
//
//  Created by sungcheol.kim on 2022/04/13.
//  https://github.com/ReactComponentKit/TinyStore
//

import Foundation
import Combine

/// Tiny.Effect<Value>
/// represent side-effect which could return value.
extension Tiny {
    public class EffectValue<Value: Equatable>: ObservableObject {
        @Published
        private var innerValue: Value
        @Published
        public private(set) var value: Value
        private var watchStates: [AnyHashable: Bool] = [:]
        internal var cancellables = Set<AnyCancellable>()
        internal let name: AnyHashable
        internal let job: (EffectValue) async -> Value
        private var cacheDidInitialRun = false
        internal var didInitialRun = false {
            didSet {
                guard didInitialRun == true else { return }
                guard cacheDidInitialRun == false else { return }
                cacheDidInitialRun = true
                run()
            }
        }
        
        internal init(name: AnyHashable, initialValue: Value, job: @escaping (EffectValue) async -> Value) {
            self.name = name
            self.innerValue = initialValue
            self.value = initialValue
            self.job = job
            
            if #available(iOS 14, macOS 11, *) {
                self.$innerValue
                    .removeDuplicates()
                    .assign(to: &self.$value)
            } else {
                self.$innerValue
                    .removeDuplicates()
                    .sink(receiveValue: { [weak self] value in
                        self?.value = value
                    })
                    .store(in: &cancellables)
            }
        }
        
        public func watch<Value: Equatable>(state name: AnyHashable, store: Tiny.ScopeStore = Tiny.globalStore) -> Value {
            let state = store.states[name] as! State<Value>
            guard watchStates[state.name] == nil else { return state.value }
            watchStates[state.name] = true
            state.$value
                .removeDuplicates()
                .sink { [weak self] value in
                    self?.run()
                }
                .store(in: &cancellables)
            return state.value
        }
        
        public func watch<Value: Equatable>(effectValue name: AnyHashable, store: Tiny.ScopeStore = Tiny.globalStore) -> Value {
            let effectValue = store.effectValues[name] as! Tiny.EffectValue<Value>
            guard watchStates[effectValue.name] == nil else { return effectValue.value }
            watchStates[effectValue.name] = true
            effectValue.$value
                .removeDuplicates()
                .sink { [weak self] value in
                    self?.run()
                }
                .store(in: &cancellables)
            return effectValue.value
        }
        
        @MainActor
        internal func commitOnMainThread(new: Value, old: Value) {
            if new != old {
                self.innerValue = new
            }
        }
        
        public func run() {
            Task.detached(priority: .userInitiated) {
                let old = self.value
                let new = await self.job(self)
                await self.commitOnMainThread(new: new, old: old)
            }
        }
    }
}
