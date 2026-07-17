import Foundation

struct CartItem: Identifiable, Equatable {
    let id: UUID
    let product: Product
    let size: String
    var quantity: Int

    init(product: Product, size: String, quantity: Int = 1, id: UUID = UUID()) {
        self.id = id
        self.product = product
        self.size = size
        self.quantity = quantity
    }

    var lineTotalCents: Int { product.basePriceCents * quantity }
}
