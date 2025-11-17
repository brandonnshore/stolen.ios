import SwiftUI

// MARK: - Color Picker

struct ColorPicker: View {
    let colors: [String]
    @Binding var selectedColor: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Color")
                .font(Theme.Typography.titleSmall)
                .foregroundColor(Theme.Colors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(colors, id: \.self) { color in
                        ColorButton(
                            color: color,
                            isSelected: selectedColor == color
                        ) {
                            withAnimation(Theme.Animation.fast) {
                                selectedColor = color
                            }
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                    }
                }
            }
        }
    }
}

struct ColorButton: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(garmentColor)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    color.lowercased() == "white" ? Theme.Colors.border : Color.clear,
                                    lineWidth: 1
                                )
                        )

                    if isSelected {
                        Circle()
                            .strokeBorder(Theme.Colors.primary, lineWidth: 3)
                            .frame(width: 58, height: 58)
                    }

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(color.lowercased() == "white" || color.lowercased() == "navy" ? .black : .white)
                    }
                }

                Text(color)
                    .font(Theme.Typography.caption)
                    .foregroundColor(isSelected ? Theme.Colors.text : Theme.Colors.textSecondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var garmentColor: Color {
        Theme.Colors.garmentColor(named: color)
    }
}

// MARK: - Size Picker

struct SizePicker: View {
    let sizes: [String]
    @Binding var selectedSize: String

    private let sizeOrder = ["XS", "S", "M", "L", "XL", "2XL", "3XL"]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Size")
                .font(Theme.Typography.titleSmall)
                .foregroundColor(Theme.Colors.text)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.Spacing.sm) {
                ForEach(sortedSizes, id: \.self) { size in
                    SizeButton(
                        size: size,
                        isSelected: selectedSize == size
                    ) {
                        withAnimation(Theme.Animation.fast) {
                            selectedSize = size
                        }
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
            }
        }
    }

    private var sortedSizes: [String] {
        sizes.sorted { size1, size2 in
            let index1 = sizeOrder.firstIndex(of: size1) ?? Int.max
            let index2 = sizeOrder.firstIndex(of: size2) ?? Int.max
            return index1 < index2
        }
    }
}

struct SizeButton: View {
    let size: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(size)
                .font(Theme.Typography.titleSmall)
                .foregroundColor(isSelected ? Theme.Colors.textInverse : Theme.Colors.text)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Layout.minTouchTarget)
                .background(isSelected ? Theme.Colors.primary : Theme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .strokeBorder(isSelected ? Color.clear : Theme.Colors.border, lineWidth: 1.5)
                )
                .cornerRadius(Theme.CornerRadius.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quantity Picker

struct QuantityPicker: View {
    @Binding var quantity: Int
    var minQuantity: Int = 1
    var maxQuantity: Int = 99

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Quantity")
                .font(Theme.Typography.titleSmall)
                .foregroundColor(Theme.Colors.text)

            HStack(spacing: 0) {
                Button(action: decrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(quantity > minQuantity ? Theme.Colors.text : Theme.Colors.textTertiary)
                        .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
                }
                .disabled(quantity <= minQuantity)

                Text("\(quantity)")
                    .font(Theme.Typography.titleMedium)
                    .foregroundColor(Theme.Colors.text)
                    .frame(minWidth: 60)
                    .multilineTextAlignment(.center)

                Button(action: increment) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(quantity < maxQuantity ? Theme.Colors.text : Theme.Colors.textTertiary)
                        .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
                }
                .disabled(quantity >= maxQuantity)
            }
            .background(Theme.Colors.backgroundSecondary)
            .cornerRadius(Theme.CornerRadius.sm)
        }
    }

    private func increment() {
        if quantity < maxQuantity {
            quantity += 1
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }

    private func decrement() {
        if quantity > minQuantity {
            quantity -= 1
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 30) {
            ColorPicker(
                colors: ["White", "Black", "Navy"],
                selectedColor: .constant("Black")
            )

            SizePicker(
                sizes: ["S", "M", "L", "XL", "2XL"],
                selectedSize: .constant("M")
            )

            QuantityPicker(quantity: .constant(1))
        }
        .padding()
    }
}
