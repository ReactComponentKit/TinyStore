//
//  VoidEffect.swift
//  TinyStore
//
//  Created by burt on 2022/04/13.
//

import Foundation
import Combine

extension Tiny {
    public class VoidEffect: ObservableObject {
        private var watchStates: [AnyHashable: Bool] = [:]
        internal var cancellable = Set<AnyCancellable>()
        internal let name: AnyHashable
        internal let job: (VoidEffect) async -> Void
        private var cacheDidInitialRun = false
        internal var didInitialRun = false {
            didSet {
                guard didInitialRun == true else { return }
                guard cacheDidInitialRun == false else { return }
                cacheDidInitialRun = true
                run()
            }
        }
        
        internal init(name: AnyHashable, job: @escaping (VoidEffect) async -> Void) {
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
                .store(in: &cancellable)
            return state
        }
        
        public func run() {
            Task.detached(priority: .userInitiated) {
                await self.job(self)
            }
        }
    }
}
