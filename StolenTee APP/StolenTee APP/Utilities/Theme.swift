import SwiftUI

// MARK: - Theme System
// Centralized design system for Stolen Tee iOS app
// Following Apple Human Interface Guidelines

struct Theme {
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color.black
        static let primaryInverse = Color.white
        static let accent = Color.blue

        // Text Colors
        static let text = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(uiColor: .tertiaryLabel)
        static let textInverse = Color.white

        // Background Colors
        static let background = Color(uiColor: .systemBackground)
        static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
        static let backgroundTertiary = Color(uiColor: .tertiarySystemBackground)
        static let backgroundGrouped = Color(uiColor: .systemGroupedBackground)

        // Surface Colors (for cards, sheets)
        static let surface = Color.white
        static let surfaceSecondary = Color(uiColor: .secondarySystemBackground)

        // Border Colors
        static let border = Color(uiColor: .separator)
        static let borderLight = Color.gray.opacity(0.2)

        // Semantic Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue

        // Product Colors (for garment visualization)
        static func garmentColor(named name: String) -> Color {
            switch name.lowercased() {
            case "white":
                return Color.white
            case "black":
                return Color.black
            case "navy":
                return Color(red: 0, green: 0.12, blue: 0.25)
            case "gray", "grey":
                return Color.gray
            default:
                return Color.gray
            }
        }

        // Gradient Overlays
        static let gradientOverlay = LinearGradient(
            colors: [Color.black.opacity(0.6), Color.clear],
            startPoint: .bottom,
            endPoint: .center
        )
    }

    // MARK: - Typography
    struct Typography {
        // Display (Hero text)
        static let displayLarge = Font.system(size: 57, weight: .bold)
        static let displayMedium = Font.system(size: 45, weight: .bold)
        static let displaySmall = Font.system(size: 36, weight: .bold)

        // Headlines
        static let headlineLarge = Font.system(size: 32, weight: .bold)
        static let headlineMedium = Font.system(size: 28, weight: .bold)
        static let headlineSmall = Font.system(size: 24, weight: .semibold)

        // Title
        static let titleLarge = Font.system(size: 22, weight: .semibold)
        static let titleMedium = Font.system(size: 16, weight: .semibold)
        static let titleSmall = Font.system(size: 14, weight: .semibold)

        // Body
        static let bodyLarge = Font.system(size: 17, weight: .regular) // iOS standard body
        static let bodyMedium = Font.system(size: 15, weight: .regular)
        static let bodySmall = Font.system(size: 13, weight: .regular)

        // Label
        static let labelLarge = Font.system(size: 14, weight: .medium)
        static let labelMedium = Font.system(size: 12, weight: .medium)
        static let labelSmall = Font.system(size: 11, weight: .medium)

        // Caption
        static let caption = Font.system(size: 12, weight: .regular)
        static let captionSmall = Font.system(size: 11, weight: .regular)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48

        // Screen padding
        static let screenPadding: CGFloat = 20
        static let cardPadding: CGFloat = 16
        static let listItemPadding: CGFloat = 16
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let pill: CGFloat = 100 // For pill-shaped buttons
    }

    // MARK: - Shadows
    struct Shadows {
        static let small = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let large = Color.black.opacity(0.15)

        static func card(radius: CGFloat = 8, y: CGFloat = 2) -> some View {
            EmptyView()
                .shadow(color: small, radius: radius, x: 0, y: y)
        }
    }

    // MARK: - Animation
    struct Animation {
        static let fast = SwiftUI.Animation.easeOut(duration: 0.2)
        static let medium = SwiftUI.Animation.easeOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
    }

    // MARK: - Layout
    struct Layout {
        // Grid
        static let gridColumns = [
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md)
        ]

        static let gridColumnsThree = [
            GridItem(.flexible(), spacing: Spacing.sm),
            GridItem(.flexible(), spacing: Spacing.sm),
            GridItem(.flexible(), spacing: Spacing.sm)
        ]

        // Minimum touch target (Apple HIG)
        static let minTouchTarget: CGFloat = 44

        // Card dimensions
        static let cardImageAspectRatio: CGFloat = 4/5
        static let thumbnailSize: CGFloat = 80
        static let avatarSize: CGFloat = 40
    }
}

// MARK: - Reusable View Modifiers

struct CardStyle: ViewModifier {
    var padding: CGFloat = Theme.Spacing.cardPadding
    var cornerRadius: CGFloat = Theme.CornerRadius.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.Colors.surface)
            .cornerRadius(cornerRadius)
            .shadow(color: Theme.Shadows.small, radius: 8, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    var isLoading: Bool = false

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(Theme.Typography.titleMedium)
            .foregroundColor(isEnabled ? Theme.Colors.textInverse : Theme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Layout.minTouchTarget)
            .background(isEnabled ? Theme.Colors.primary : Theme.Colors.border)
            .cornerRadius(Theme.CornerRadius.md)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(isLoading ? 0.7 : 1.0)
            .animation(Theme.Animation.fast, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(Theme.Typography.titleMedium)
            .foregroundColor(Theme.Colors.text)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Layout.minTouchTarget)
            .background(Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(Theme.Colors.border, lineWidth: 1.5)
            )
            .cornerRadius(Theme.CornerRadius.md)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(Theme.Animation.fast, value: configuration.isPressed)
    }
}

struct PillButtonStyle: ButtonStyle {
    var isSelected: Bool = false

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(Theme.Typography.labelMedium)
            .foregroundColor(isSelected ? Theme.Colors.textInverse : Theme.Colors.text)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isSelected ? Theme.Colors.primary : Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.pill)
                    .stroke(isSelected ? Color.clear : Theme.Colors.border, lineWidth: 1)
            )
            .cornerRadius(Theme.CornerRadius.pill)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(Theme.Animation.fast, value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(padding: CGFloat = Theme.Spacing.cardPadding, cornerRadius: CGFloat = Theme.CornerRadius.md) -> some View {
        modifier(CardStyle(padding: padding, cornerRadius: cornerRadius))
    }

    func primaryButtonStyle(isEnabled: Bool = true, isLoading: Bool = false) -> some View {
        buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, isLoading: isLoading))
    }

    func secondaryButtonStyle() -> some View {
        buttonStyle(SecondaryButtonStyle())
    }

    func pillButtonStyle(isSelected: Bool = false) -> some View {
        buttonStyle(PillButtonStyle(isSelected: isSelected))
    }

    // Haptic feedback
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }

    func successFeedback() -> some View {
        self.onAppear {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    func errorFeedback() -> some View {
        self.onAppear {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

// MARK: - Animations and Transitions

extension AnyTransition {
    static var slideUpFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }

    static var scaleAndFade: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }
}
