import Foundation

@Observable
@MainActor
final class CartService {
    private(set) var items: [CartItem] = []

    var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }
    var subtotalCents: Int { items.reduce(0) { $0 + $1.lineTotalCents } }
    var taxCents: Int { Int(Double(subtotalCents) * 0.08) } // flat 8% for POC
    var totalCents: Int { subtotalCents + taxCents }
    var isEmpty: Bool { items.isEmpty }

    func add(_ product: Product, size: String, quantity: Int = 1) {
        // Merge into existing line if same product + size
        if let idx = items.firstIndex(where: { $0.product.id == product.id && $0.size == size }) {
            items[idx].quantity += quantity
        } else {
            items.append(CartItem(product: product, size: size, quantity: quantity))
        }
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    func setQuantity(_ item: CartItem, to newQuantity: Int) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        if newQuantity <= 0 { items.remove(at: idx) }
        else { items[idx].quantity = newQuantity }
    }

    func clear() { items.removeAll() }
}
