import SwiftUI

@main
struct ShoppingCartApp: App {
    @StateObject private var cart = CartViewModel()

    var body: some Scene {
        WindowGroup {
            CartView(viewModel: cart)
        }
    }
}
