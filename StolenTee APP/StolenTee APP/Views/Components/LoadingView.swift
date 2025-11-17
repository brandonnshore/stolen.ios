import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Theme.Colors.primary)

            Text(message)
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

struct FullScreenLoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.md) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text(message)
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(.white)
            }
            .padding(Theme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .fill(Color.black.opacity(0.8))
            )
        }
    }
}

// Skeleton loading view for content
struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        Rectangle()
            .fill(Theme.Colors.backgroundSecondary)
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 400 : -400)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

struct ProductCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SkeletonView()
                .aspectRatio(Theme.Layout.cardImageAspectRatio, contentMode: .fit)
                .cornerRadius(Theme.CornerRadius.md)

            SkeletonView()
                .frame(height: 16)
                .frame(maxWidth: .infinity)
                .cornerRadius(Theme.CornerRadius.xs)

            SkeletonView()
                .frame(height: 14)
                .frame(width: 60)
                .cornerRadius(Theme.CornerRadius.xs)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView()

        ProductCardSkeleton()
            .padding()
    }
}
