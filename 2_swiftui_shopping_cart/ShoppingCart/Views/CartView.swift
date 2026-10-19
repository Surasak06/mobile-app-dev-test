import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: CartViewModel
    @State private var showCheckoutConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isEmpty {
                    EmptyCartView()
                        .transition(.opacity)
                } else {
                    cartList
                }
            }
            .navigationTitle("Shopping Cart")
            .safeAreaInset(edge: .bottom) {
                CartSummaryView(
                    totalQuantity: viewModel.totalQuantity,
                    totalPrice: viewModel.totalPrice,
                    isCheckoutDisabled: viewModel.isEmpty,
                    onCheckout: { showCheckoutConfirmation = true }
                )
            }
            .animation(.default, value: viewModel.isEmpty)
            .alert("Confirm checkout", isPresented: $showCheckoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Pay \(viewModel.totalPrice.bahtFormatted)") {
                    withAnimation { viewModel.checkout() }
                }
            } message: {
                Text("\(viewModel.totalQuantity) items will be ordered.")
            }
        }
    }

    private var cartList: some View {
        List {
            ForEach(viewModel.items) { item in
                CartItemRow(
                    item: item,
                    canDecrement: item.quantity > CartViewModel.minimumQuantity,
                    onIncrement: {
                        withAnimation(.snappy) { viewModel.increment(item) }
                    },
                    onDecrement: {
                        withAnimation(.snappy) { viewModel.decrement(item) }
                    }
                )
            }
            .onDelete { offsets in
                withAnimation { viewModel.delete(at: offsets) }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Your cart is empty")
                .font(.title3.weight(.semibold))
            Text("Items you add will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Cart") {
    CartView(viewModel: CartViewModel())
}

#Preview("Empty cart") {
    CartView(viewModel: CartViewModel(items: []))
}
