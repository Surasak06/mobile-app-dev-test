import Foundation

/// Single source of truth for the cart. Totals are computed properties,
/// so they update immediately whenever `items` changes.
@MainActor
final class CartViewModel: ObservableObject {
    @Published private(set) var items: [CartItem]

    static let minimumQuantity = 1

    init(items: [CartItem] = CartItem.samples) {
        self.items = items
    }

    var isEmpty: Bool { items.isEmpty }

    /// Total number of pieces across all rows.
    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Decimal {
        items.reduce(Decimal.zero) { $0 + $1.subtotal }
    }

    func increment(_ item: CartItem) {
        guard let index = index(of: item) else { return }
        items[index].quantity += 1
    }

    /// Quantity never goes below `minimumQuantity`; use swipe to delete instead.
    func decrement(_ item: CartItem) {
        guard let index = index(of: item),
              items[index].quantity > Self.minimumQuantity else { return }
        items[index].quantity -= 1
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    func checkout() {
        items.removeAll()
    }

    private func index(of item: CartItem) -> Int? {
        items.firstIndex { $0.id == item.id }
    }
}
