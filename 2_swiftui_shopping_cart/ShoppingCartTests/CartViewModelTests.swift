import XCTest
@testable import ShoppingCart

@MainActor
final class CartViewModelTests: XCTestCase {
    private func makeViewModel() -> CartViewModel {
        CartViewModel(items: [
            CartItem(name: "Keyboard", unitPrice: 1890, quantity: 1),
            CartItem(name: "Mouse", unitPrice: 590, quantity: 2)
        ])
    }

    func testTotalsAreComputedFromItems() {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.totalQuantity, 3)
        XCTAssertEqual(viewModel.totalPrice, 3070)
    }

    func testIncrementUpdatesTotalsImmediately() {
        let viewModel = makeViewModel()
        viewModel.increment(viewModel.items[0])
        XCTAssertEqual(viewModel.items[0].quantity, 2)
        XCTAssertEqual(viewModel.totalQuantity, 4)
        XCTAssertEqual(viewModel.totalPrice, 4960)
    }

    func testDecrementNeverGoesBelowOne() {
        let viewModel = makeViewModel()
        viewModel.decrement(viewModel.items[0])
        XCTAssertEqual(viewModel.items[0].quantity, 1)

        viewModel.decrement(viewModel.items[1])
        XCTAssertEqual(viewModel.items[1].quantity, 1)
    }

    func testDeleteRemovesItemAndUpdatesTotals() {
        let viewModel = makeViewModel()
        viewModel.delete(at: IndexSet(integer: 1))
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.totalQuantity, 1)
        XCTAssertEqual(viewModel.totalPrice, 1890)
    }

    func testEmptyCart() {
        let viewModel = CartViewModel(items: [])
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertEqual(viewModel.totalQuantity, 0)
        XCTAssertEqual(viewModel.totalPrice, 0)
    }

    func testBahtFormatting() {
        XCTAssertEqual(CurrencyFormatter.baht(1890), "฿1,890.00")
        XCTAssertEqual(CurrencyFormatter.baht(0), "฿0.00")
        XCTAssertEqual(CurrencyFormatter.baht(Decimal(string: "1249.5")!), "฿1,249.50")
        XCTAssertEqual(CurrencyFormatter.baht(1_234_567), "฿1,234,567.00")
    }
}
