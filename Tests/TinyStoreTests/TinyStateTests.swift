import XCTest
@testable import TinyStore

final class TinyStateTsts: XCTestCase {
    func testInitState() {
        let state = Tiny.State(name: "name", initialValue: "A")
        XCTAssertEqual(state.value, "A")
    }
    
    func testUpdateStateOnMainThread() {
        let state = Tiny.State(name: "name", initialValue: "A")
        XCTAssertEqual(state.value, "A")
        
        state.value = "B"
        XCTAssertEqual(state.value, "B")
    }
    
    func testUpdateStateOnOtherThread() async {
        let state = Tiny.State(name: "name", initialValue: "A")
        XCTAssertEqual(state.value, "A")
        
        let task = Task.detached(priority: .background) {
            state.commit { $0 = "B" }
            await contextSwitching()
            XCTAssertEqual(state.value, "B")
        }
        await task.value
    }
    
    func testStateEquality() {
        enum States {
            case a
            case b
            case c
            case d
        }
        
        let a = Tiny.State(name: States.a, initialValue: 1)
        let b = Tiny.State(name: States.b, initialValue: "A")
        let c = Tiny.State(name: States.c, initialValue: 1)
        let d = Tiny.State(name: States.d, initialValue: "A")
        
        XCTAssertEqual(a, a)
        XCTAssertEqual(b, b)
        XCTAssertEqual(a == b, false)
        XCTAssertEqual(a != b, true)
        XCTAssertEqual(a == c, false)
        XCTAssertEqual(a != c, true)
        XCTAssertEqual(b == d, false)
        XCTAssertEqual(b != d, true)
    }
    
    func testDescriptions() {
        let state = Tiny.State(name: "name", initialValue: "TinyStore")
        XCTAssertEqual("\(state)", "TinyStore")
        XCTAssertEqual(state.description, "TinyStore")
        XCTAssertEqual(state.debugDescription, "TinyStore")
    }
}
