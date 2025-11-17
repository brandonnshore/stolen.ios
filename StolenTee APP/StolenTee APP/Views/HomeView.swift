import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ProductsViewModel
    @State private var heistCount = 12847
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                        .padding(.vertical, Theme.Spacing.xl)

                    // Stats Dashboard
                    statsDashboard
                        .padding(.vertical, Theme.Spacing.lg)
                        .background(Theme.Colors.backgroundSecondary)

                    // Trophy Case
                    trophyCase
                        .padding(.vertical, Theme.Spacing.xl)

                    // Products Preview
                    productsPreview
                        .padding(.vertical, Theme.Spacing.xl)
                }
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Stolen Tee")
                        .font(Theme.Typography.titleLarge)
                        .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            startHeistCounter()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: Theme.Spacing.lg) {
            VStack(spacing: Theme.Spacing.sm) {
                Text("Seen it.")
                    .font(Theme.Typography.displayMedium)
                    .fontWeight(.bold)
                Text("Want it.")
                    .font(Theme.Typography.displayMedium)
                    .fontWeight(.bold)
                Text("Got it.")
                    .font(Theme.Typography.displayMedium)
                    .fontWeight(.bold)
            }
            .foregroundColor(Theme.Colors.text)

            Text("Upload a photo of any shirt. Our thieves extract the design and recreate it on premium blanks in seconds.")
                .font(Theme.Typography.bodyLarge)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: Theme.Spacing.md) {
                NavigationLink(destination: ProductsView()) {
                    Text("Start Your Heist")
                        .fontWeight(.semibold)
                }
                .primaryButtonStyle()

                NavigationLink(destination: HowItWorksView()) {
                    Text("See How It Works")
                }
                .secondaryButtonStyle()
            }
            .padding(.horizontal, Theme.Spacing.xl)
        }
    }

    // MARK: - Stats Dashboard

    private var statsDashboard: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("By the Numbers")
                .font(Theme.Typography.headlineSmall)
                .foregroundColor(Theme.Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.Spacing.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    HomeStatCard(
                        value: String(heistCount.formatted()),
                        label: "Designs Stolen",
                        gradient: [Color.purple, Color.pink]
                    )

                    HomeStatCard(
                        value: "99.2%",
                        label: "Accuracy Rate",
                        gradient: [Color.blue, Color.cyan]
                    )

                    HomeStatCard(
                        value: "0",
                        label: "Lawyers Contacted",
                        subtitle: "(so far)",
                        gradient: [Color.green, Color.mint]
                    )

                    HomeStatCard(
                        value: "24/7",
                        label: "Active Heists",
                        gradient: [Color.orange, Color.red]
                    )
                }
                .padding(.horizontal, Theme.Spacing.screenPadding)
            }
        }
    }

    // MARK: - Trophy Case

    private var trophyCase: some View {
        VStack(spacing: Theme.Spacing.md) {
            VStack(spacing: Theme.Spacing.sm) {
                Text("Trophy Case")
                    .font(Theme.Typography.headlineMedium)
                    .foregroundColor(Theme.Colors.text)

                Text("Recent heists pulled off by our community")
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Theme.Spacing.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    ForEach(trophyItems, id: \.title) { item in
                        TrophyCard(item: item)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenPadding)
            }
        }
    }

    // MARK: - Products Preview

    private var productsPreview: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Premium blanks,")
                        .font(Theme.Typography.headlineSmall)
                        .foregroundColor(Theme.Colors.text)
                    Text("perfected by AI")
                        .font(Theme.Typography.headlineSmall)
                        .foregroundColor(Theme.Colors.text)
                }

                Spacer()

                NavigationLink(destination: ProductsView()) {
                    Text("View All")
                        .font(Theme.Typography.labelMedium)
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .padding(.horizontal, Theme.Spacing.screenPadding)

            if viewModel.isLoading {
                HStack(spacing: Theme.Spacing.md) {
                    ProductCardSkeleton()
                    ProductCardSkeleton()
                }
                .padding(.horizontal, Theme.Spacing.screenPadding)
            } else {
                LazyVGrid(columns: Theme.Layout.gridColumns, spacing: Theme.Spacing.md) {
                    ForEach(viewModel.products.prefix(4)) { product in
                        NavigationLink(destination: CustomizerView(product: product, variants: product.variants ?? [])) {
                            ProductCard(product: product)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenPadding)
            }
        }
    }

    // MARK: - Helper Methods

    private func startHeistCounter() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeOut(duration: 0.5)) {
                heistCount += Int.random(in: 1...3)
            }
        }
    }

    private let trophyItems = [
        TrophyItem(title: "Coachella Find", designer: "@vintage_hunter", status: "CLASSIFIED"),
        TrophyItem(title: "Supreme Drop", designer: "@streetwear_king", status: "EXTRACTED"),
        TrophyItem(title: "Band Tee '85", designer: "@retro_collector", status: "STOLEN"),
        TrophyItem(title: "Skate Logo", designer: "@urban_style", status: "CLASSIFIED"),
        TrophyItem(title: "Nike Vintage", designer: "@sneaker_head", status: "EXTRACTED"),
        TrophyItem(title: "Concert Merch", designer: "@music_fan", status: "STOLEN")
    ]
}

// MARK: - Supporting Views

struct HomeStatCard: View {
    let value: String
    let label: String
    var subtitle: String?
    let gradient: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(value)
                .font(Theme.Typography.displaySmall)
                .fontWeight(.black)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(Theme.Typography.labelMedium)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .textCase(.uppercase)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Theme.Typography.captionSmall)
                        .foregroundColor(Theme.Colors.textTertiary)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .frame(width: 180)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.lg)
        .shadow(color: Theme.Shadows.small, radius: 4, y: 2)
    }
}

struct TrophyCard: View {
    let item: TrophyItem

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ZStack {
                Theme.Colors.backgroundSecondary
                    .aspectRatio(1, contentMode: .fit)

                VStack(spacing: Theme.Spacing.xs) {
                    Text("👕")
                        .font(.system(size: 50))

                    Text(item.title)
                        .font(Theme.Typography.labelSmall)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.center)
                }

                // Status stamp
                VStack {
                    HStack {
                        Spacer()
                        Text(item.status)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(statusColor)
                            .padding(4)
                            .background(statusColor.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(statusColor, lineWidth: 1)
                            )
                            .cornerRadius(4)
                            .rotationEffect(.degrees(12))
                            .padding(8)
                    }
                    Spacer()
                }
            }
            .cornerRadius(Theme.CornerRadius.sm)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(Theme.Typography.labelMedium)
                    .foregroundColor(Theme.Colors.text)
                    .lineLimit(1)

                Text(item.designer)
                    .font(Theme.Typography.captionSmall)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 140)
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(color: Theme.Shadows.small, radius: 4, y: 2)
    }

    private var statusColor: Color {
        switch item.status {
        case "CLASSIFIED": return .purple
        case "EXTRACTED": return .green
        case "STOLEN": return .red
        default: return .gray
        }
    }
}

struct TrophyItem {
    let title: String
    let designer: String
    let status: String
}

// MARK: - How It Works View (Placeholder)

struct HowItWorksView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                Text("How It Works")
                    .font(Theme.Typography.headlineLarge)

                // Add how it works content here
                Text("Coming soon...")
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.screenPadding)
        }
        .navigationTitle("How It Works")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HomeView()
}
