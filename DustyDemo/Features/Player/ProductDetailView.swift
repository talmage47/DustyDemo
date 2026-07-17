import SwiftUI

struct ProductDetailView: View {
    let product: Product
    let team: Team?

    @Environment(CartService.self) private var cart
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSize: String?
    @State private var quantity = 1
    @State private var showingAddedConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    (team.map { Color(hex: $0.primaryColorHex) } ?? Color.gray).opacity(0.15)
                    Image(systemName: product.symbol)
                        .font(.system(size: 96))
                        .foregroundStyle(team.map { Color(hex: $0.primaryColorHex) } ?? Color.gray)
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name).font(.appLargeTitle)
                    Text(product.basePriceCents.asDollarString)
                        .font(.appTitle)
                        .foregroundStyle(AppColors.textMuted)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Size").font(.appHeadline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: 8)], spacing: 8) {
                        ForEach(product.availableSizes, id: \.self) { size in
                            Button(size) { selectedSize = size }
                                .buttonStyle(SizeChipStyle(isSelected: selectedSize == size))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Quantity").font(.appHeadline)
                    Stepper(value: $quantity, in: 1...10) {
                        Text("\(quantity)")
                    }
                }

                Button {
                    guard let size = selectedSize else { return }
                    cart.add(product, size: size, quantity: quantity)
                    showingAddedConfirmation = true
                } label: {
                    Text("Add to Cart")
                        .font(.appHeadline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(selectedSize == nil)
            }
            .padding()
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Added to Cart", isPresented: $showingAddedConfirmation) {
            Button("Keep Shopping", role: .cancel) { }
            Button("View Cart") { dismiss() /* pop to shop; user taps cart tab */ }
        } message: {
            Text("\(quantity) × \(product.name) (\(selectedSize ?? ""))")
        }
    }
}

private struct SizeChipStyle: ButtonStyle {
    let isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appHeadline)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : AppColors.surface)
            .foregroundStyle(isSelected ? Color.white : AppColors.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
