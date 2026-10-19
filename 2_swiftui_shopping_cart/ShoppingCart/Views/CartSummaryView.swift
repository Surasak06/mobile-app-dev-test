import SwiftUI

struct CartSummaryView: View {
    let totalQuantity: Int
    let totalPrice: Decimal
    let isCheckoutDisabled: Bool
    let onCheckout: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total items")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(totalQuantity)")
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }

            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(totalPrice.bahtFormatted)
                    .font(.title2.bold())
                    .contentTransition(.numericText())
            }

            Button(action: onCheckout) {
                Text("Checkout")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isCheckoutDisabled)
        }
        .padding()
        .background(.regularMaterial)
    }
}

#Preview {
    CartSummaryView(totalQuantity: 4, totalPrice: 3070, isCheckoutDisabled: false, onCheckout: {})
}
