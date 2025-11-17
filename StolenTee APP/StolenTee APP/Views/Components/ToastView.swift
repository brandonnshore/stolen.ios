import SwiftUI

struct ToastView: View {
    enum ToastType {
        case success
        case error
        case info
        case warning

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return Theme.Colors.success
            case .error: return Theme.Colors.error
            case .info: return Theme.Colors.info
            case .warning: return Theme.Colors.warning
            }
        }
    }

    let message: String
    let type: ToastType

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: type.icon)
                .font(.system(size: 20))
                .foregroundColor(type.color)

            Text(message)
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(Theme.Colors.text)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(color: Theme.Shadows.medium, radius: 12, y: 4)
        .padding(.horizontal, Theme.Spacing.md)
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let type: ToastView.ToastType
    let duration: TimeInterval

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if isPresented {
                ToastView(message: message, type: type)
                    .padding(.top, Theme.Spacing.md)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation(Theme.Animation.medium) {
                                isPresented = false
                            }
                        }
                    }
            }
        }
        .animation(Theme.Animation.medium, value: isPresented)
    }
}

extension View {
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        type: ToastView.ToastType = .info,
        duration: TimeInterval = 3.0
    ) -> some View {
        modifier(ToastModifier(
            isPresented: isPresented,
            message: message,
            type: type,
            duration: duration
        ))
    }
}

// Temporarily disabled preview due to macro issue
// #Preview {
//     VStack {
//         ToastView(message: "Successfully added to cart!", type: .success)
//         ToastView(message: "An error occurred", type: .error)
//         ToastView(message: "Information message", type: .info)
//     }
//     .padding()
// }
