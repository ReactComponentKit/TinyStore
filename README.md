# TinyStore

![license MIT](https://img.shields.io/cocoapods/l/Redux.svg)
![Platform](https://img.shields.io/badge/iOS-%3E%3D%2013.0-green.svg)
![Platform](https://img.shields.io/badge/macos-%3E%3D%2010.15-green.svg)
![Xcode](https://img.shields.io/badge/xcode-%3E%3D%2013.2-orange.svg)
[![Swift 5.5](https://img.shields.io/badge/Swift-5.5-orange.svg?style=flat)](https://developer.apple.com/swift/)

TinyStore is really small state management library for UIKit and SwiftUI. It catches ideas from [Recoil](https://recoiljs.org/)!

## States

You can define a state with `state()` function.

```swift
state(name: "name", initialValue: "burt")
state(name: "age", initialValue: 20)
```

## Effects

You can define a side effect with `effect()` function.

```swift
effect(name: "loggingName") { effect in 
    let name: String = effect.watch(state: "name")
    
    // call logging api
    await API.logging(name: name)
}
```

effect can watch the changes of the State of EffectValue.

## EffectValue: Compose them!

Composing states is very important! You can compose States and EffectValues with EffectValue.

```swift
effectValue(name: "nameAge", initailValue: "") { effect in 
    let name: String = effect.watch(state: "name")
    let age: Int = effect.watch(state: "age")
    return "\(name)-\(age)"
}
```

There are more [examples](https://github.com/ReactComponentKit/TinyStoreExamples)

## ScopeStore

TinyStore use Tiny.globalStore as default store. But you can define your ScopeStore where you want. For example, you can define SomeViewController's scope store.

```swift
class SomeViewController: UIViewController {
    init() {
        var store = store(name: "mystore")
        state(name: "A", initialValue: 100, store: store)
        state(name: "B", initialValue: "Hello", store: store)
    }
    
    weak var collectionView: UICollectionView!
    ...
}

class MyCollectionViewCell: UICollectionViewCell {
    @UseState("A")
    var a: Tiny.State<Int>
    
    @UseState("B")
    var b: Tiny.State<String>
}
```


## MIT License

Copyright (c) 2021 Redux, ReactComponentKit

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
