import SwiftUI

// Swift 6.4's SDK overloads @State with a macro missing from Command Line Tools.
// Name the existing property-wrapper type explicitly; this works on macOS 15+ without a custom implementation.
typealias ViewState<Value> = SwiftUI.State<Value>
