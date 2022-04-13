//
//  simulateWait.swift
//  TinyStoreTests
//
//  Created by burt on 2022/04/13.
//

import Foundation

/// simulate waiting
func wait(secs: Int) async {
    try? await Task.sleep(nanoseconds: UInt64(secs * 1_000_000_000))
}
