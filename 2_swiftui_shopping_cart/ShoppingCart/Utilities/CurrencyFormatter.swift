import Foundation

/// Formats Thai Baht as "฿1,890.00", independent of the device locale.
enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .halfUp
        return formatter
    }()

    static func baht(_ amount: Decimal) -> String {
        let number = NSDecimalNumber(decimal: amount)
        let formatted = formatter.string(from: number) ?? "\(amount)"
        return "฿" + formatted
    }
}

extension Decimal {
    var bahtFormatted: String { CurrencyFormatter.baht(self) }
}
