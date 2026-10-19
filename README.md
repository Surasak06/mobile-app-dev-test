# Mobile App Dev – คำตอบโจทย์ 3 ส่วน

| โฟลเดอร์ | โจทย์ | เทคโนโลยี |
|---|---|---|
| `1_flutter_product_list/` | Searchable Product List | Flutter 3.22+ / Dart 3.4+ |
| `2_swiftui_shopping_cart/` | Shopping Cart | SwiftUI, iOS 17+, Xcode 15+ |
| `3_android_temperature_converter/` | Temperature Converter | Kotlin + Jetpack Compose + Material 3 |

---

## 1) Flutter – Searchable Product List

### วิธีรัน
```bash
cd 1_flutter_product_list
flutter create . --project-name product_list --platforms=android,ios   # สร้างโฟลเดอร์ platform (ไม่ทับไฟล์ที่มีอยู่)
flutter pub get
flutter analyze
flutter test
flutter run
```

### โครงสร้าง
```
lib/
  main.dart                       # แค่ตั้งค่า MaterialApp + theme (light/dark)
  models/product.dart             # Product แบบ typed + fromJson ที่ validate ทุก field
  services/product_service.dart   # ProductService (interface) + MockProductService (จำลอง API/JSON)
  controllers/product_list_controller.dart  # ChangeNotifier: state, search, filter, sort, debounce
  screens/product_list_screen.dart
  screens/product_detail_screen.dart
  widgets/product_tile.dart, stock_badge.dart, category_filter_bar.dart, state_views.dart
  utils/formatters.dart           # ฿2,490.00
test/
  widget_test.dart                # search, search+category, empty, error+retry, narrow screen
  product_parsing_test.dart       # JSON parsing + price formatting
```

### Requirements → การทำ
- รายการแสดง ชื่อ / ราคา / หมวดหมู่ / In stock–Out of stock (`ProductTile`, `StockBadge`)
- ค้นหาจากชื่อ (ไม่สนตัวพิมพ์เล็ก–ใหญ่) + Filter หมวดหมู่ด้วย ChoiceChip — **ทำงานร่วมกันแบบ AND** เช่น "Keyboard" ใน "Accessories"
- กดสินค้า → `ProductDetailScreen`
- State: Loading / Empty / Error / Data; Error มีปุ่ม **Retry**
- ทดลอง Error ได้จากเมนู ⋮ บน AppBar → "Simulate network error"
- ไม่มี `dynamic` หลัง parse: `Product.fromJson(Map<String, Object?>)` ตรวจ type ทุก field และเปิด `strict-casts` / `strict-raw-types` ใน analysis_options
- `TextEditingController` และ controller ถูก `dispose()` ใน `State.dispose`
- กัน overflow: ชื่อใช้ `Expanded` + `maxLines/ellipsis`, chip หมวดหมู่เลื่อนแนวนอน, หน้า state/detail scroll ได้ — มี test จอกว้าง 320px ชื่อยาวมาก
- State management: `ChangeNotifier` + `ListenableBuilder` (ไม่ใช้ package เพิ่ม)

**Bonus:** Debounce 300ms · Sort ราคา น้อย→มาก / มาก→น้อย · แสดงจำนวนผลลัพธ์ · Dark mode ตามระบบ

---

## 2) SwiftUI – Shopping Cart

### วิธีรัน
**ทางเลือก A (XcodeGen):**
```bash
cd 2_swiftui_shopping_cart
brew install xcodegen
xcodegen generate
open ShoppingCart.xcodeproj      # Run (⌘R) / Test (⌘U)
```
**ทางเลือก B:** Xcode → New Project → iOS App (SwiftUI) ชื่อ `ShoppingCart` → ลบ `ContentView.swift` และไฟล์ App เดิม → ลากโฟลเดอร์ `ShoppingCart/` เข้าโปรเจกต์ (และ `ShoppingCartTests/` เข้า test target)

### โครงสร้าง
```
ShoppingCart/
  ShoppingCartApp.swift
  Models/CartItem.swift              # ราคาเป็น Decimal (ไม่มีปัญหาปัดเศษแบบ Double)
  ViewModels/CartViewModel.swift     # ObservableObject: increment/decrement/delete, totals
  Views/CartView.swift               # List + onDelete + summary + empty state + checkout alert
  Views/CartItemRow.swift            # แถวสินค้าแยกเป็น CartItemRow
  Views/CartSummaryView.swift        # จำนวนชิ้นรวม + ราคารวม + ปุ่ม Checkout
  Utilities/CurrencyFormatter.swift  # ฿1,890.00 (ไม่ขึ้นกับ locale เครื่อง)
ShoppingCartTests/CartViewModelTests.swift
```

### Requirements → การทำ
- `List` + `ForEach` แสดง ชื่อ, ราคาต่อชิ้น, จำนวน, ราคารวมรายการ
- ปุ่ม + / − (`.buttonStyle(.borderless)` เพื่อไม่ให้แตะทั้งแถวแล้วยิงทั้งสองปุ่ม); ปุ่ม − ถูก disable และ ViewModel guard ไม่ให้ต่ำกว่า 1
- Swipe to Delete ด้วย `.onDelete`
- ด้านล่าง (`safeAreaInset`) แสดงจำนวนชิ้นรวม + ราคารวม — เป็น computed property จึงอัปเดตทันที
- รูปแบบเงินบาท `฿1,890.00`

**Bonus:** Empty state · ปุ่ม Checkout กดไม่ได้เมื่อตะกร้าว่าง · `CartItemRow` แยกไฟล์ · Animation (`withAnimation` + `.contentTransition(.numericText())`) · Unit tests ของ ViewModel

---

## 3) Native Android – Temperature Converter

### วิธีรัน
เปิดโฟลเดอร์ `3_android_temperature_converter` ด้วย Android Studio แล้วกด Run หรือ
```bash
cd 3_android_temperature_converter
./gradlew installDebug
./gradlew testDebugUnitTest      # unit tests
```
(AGP 8.10, Kotlin 2.1, Compose BOM, minSdk 24 / targetSdk 35, Gradle 8.14)

### โครงสร้าง
```
domain/TemperatureUnit.kt        # enum พร้อม symbol และ absoluteZero ของแต่ละหน่วย
domain/TemperatureConverter.kt   # pure Kotlin: convert, validate, format (ไม่มี Android dependency)
ui/TemperatureConverterScreen.kt # Stateful screen + Stateless content (preview ได้)
ui/theme/Theme.kt                # Material 3 + dynamic color + dark mode
test/.../TemperatureConverterTest.kt
```

### Requirements → การทำ
- รองรับทศนิยมและค่าติดลบ (+ ปุ่ม ± เพราะคีย์บอร์ดตัวเลขบางรุ่นไม่มีเครื่องหมายลบ; รับ `,` เป็นจุดทศนิยมด้วย)
- เลือกหน่วยต้นทาง/ปลายทาง °C °F K ด้วย Segmented buttons
- คำนวณทันทีเมื่อค่า/หน่วยเปลี่ยน (`remember(input, from, to)`)
- แสดง 2 ตำแหน่ง ด้วย `BigDecimal` HALF_UP (ไม่มีกรณี `-0.00`)
- ปุ่มสลับหน่วย → คำนวณใหม่ทันที, ไม่ reset input
- กันค่าต่ำกว่า Absolute Zero ของหน่วยต้นทาง (-273.15 °C, -459.67 °F, 0 K) พร้อมข้อความแจ้ง
- Input ว่าง/ไม่ใช่ตัวเลข → ไม่ crash (ไม่มี `toDouble()` ที่ throw) และแสดงข้อความ
- หน่วยเดียวกัน → คืนค่าเดิม
- F ↔ K แปลงผ่าน Celsius
- State เก็บด้วย `rememberSaveable` จึงไม่หายเมื่อหมุนจอ

**Bonus ที่เลือก:** Unit test สำหรับ conversion function — 15 test cases ครอบคลุมตารางตัวอย่าง, acceptance criteria, absolute zero ทุกหน่วย, input ไม่ถูกต้อง และการสลับหน่วย (ทั้งหมดผ่าน)
