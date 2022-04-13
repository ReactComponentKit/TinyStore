//
//  ContextSwitching.swift
//  TinyStoreTests
//
//  Created by sungcheol.kim on 2022/04/13.
//  https://github.com/ReactComponentKit/TinyStore
//

import Foundation


/// simulate context switching
func contextSwitching() async {
    try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
}
