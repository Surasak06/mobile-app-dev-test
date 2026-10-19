import Foundation

struct CartItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    /// Decimal avoids floating-point rounding errors with money.
    let unitPrice: Decimal
    var quantity: Int

    init(id: UUID = UUID(), name: String, unitPrice: Decimal, quantity: Int = 1) {
        self.id = id
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = max(1, quantity)
    }

    var subtotal: Decimal {
        unitPrice * Decimal(quantity)
    }
}

extension CartItem {
    static let samples: [CartItem] = [
        CartItem(name: "Mechanical Keyboard", unitPrice: 1890, quantity: 1),
        CartItem(name: "Wireless Mouse", unitPrice: 590, quantity: 2),
        CartItem(name: "USB-C Hub 7-in-1", unitPrice: Decimal(string: "1249.50")!, quantity: 1),
        CartItem(name: "Laptop Stand (Aluminium, Adjustable Height)", unitPrice: 890, quantity: 1),
        CartItem(name: "Keyboard Wrist Rest", unitPrice: Decimal(string: "359.75")!, quantity: 3)
    ]
}
