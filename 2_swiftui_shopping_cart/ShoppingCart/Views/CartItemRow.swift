import SwiftUI

struct CartItemRow: View {
    let item: CartItem
    let canDecrement: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                Text("\(item.unitPrice.bahtFormatted) / piece")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(item.subtotal.bahtFormatted)
                    .font(.subheadline.weight(.semibold))
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            QuantityStepper(
                quantity: item.quantity,
                canDecrement: canDecrement,
                onIncrement: onIncrement,
                onDecrement: onDecrement
            )
        }
        .padding(.vertical, 4)
    }
}

private struct QuantityStepper: View {
    let quantity: Int
    let canDecrement: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onDecrement) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
            }
            .disabled(!canDecrement)
            .accessibilityLabel("Decrease quantity")

            Text("\(quantity)")
                .font(.body.monospacedDigit().weight(.semibold))
                .frame(minWidth: 28)
                .contentTransition(.numericText())
                .accessibilityLabel("Quantity \(quantity)")

            Button(action: onIncrement) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .accessibilityLabel("Increase quantity")
        }
        // Borderless: otherwise tapping anywhere in the List row fires both buttons.
        .buttonStyle(.borderless)
    }
}

#Preview {
    List {
        CartItemRow(
            item: CartItem(name: "Mechanical Keyboard", unitPrice: 1890, quantity: 2),
            canDecrement: true,
            onIncrement: {},
            onDecrement: {}
        )
        CartItemRow(
            item: CartItem(name: "Wireless Mouse", unitPrice: 590, quantity: 1),
            canDecrement: false,
            onIncrement: {},
            onDecrement: {}
        )
    }
}
