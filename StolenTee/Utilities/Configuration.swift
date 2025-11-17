import Foundation

enum Configuration {
    // MARK: - API Configuration
    static let apiURL: String = {
        #if DEBUG
        return "http://localhost:3001"
        #else
        return "https://raspberrymerch.com"
        #endif
    }()

    // MARK: - Stripe Configuration
    // TODO: Replace with your actual Stripe publishable keys from https://dashboard.stripe.com/apikeys
    static let stripePublishableKey: String = {
        #if DEBUG
        return "pk_test_your_stripe_publishable_key" // TODO: Add your test key
        #else
        return "pk_live_your_stripe_publishable_key" // TODO: Add your live key
        #endif
    }()

    // MARK: - Supabase Configuration (for OAuth)
    // TODO: Get these from your Supabase project settings at https://supabase.com/dashboard
    // Navigate to: Settings > API > Project URL and anon/public key
    static let supabaseURL = "https://your-project.supabase.co" // TODO: Add your Supabase URL
    static let supabaseAnonKey = "your_supabase_anon_key" // TODO: Add your Supabase anon key

    // MARK: - App URL Scheme (for OAuth callbacks)
    // This should match the URL scheme configured in your Info.plist
    static let appURLScheme = "stolentee"

    // MARK: - API Endpoints
    enum Endpoint {
        // Auth
        static let login = "/api/auth/login"
        static let register = "/api/auth/register"
        static let me = "/api/auth/me"
        static let oauthSync = "/api/auth/oauth/sync"

        // Products
        static let products = "/api/products"
        static func productDetail(_ slug: String) -> String { "/api/products/\(slug)" }

        // Orders
        static let createOrder = "/api/orders/create"
        static func orderDetail(_ id: String) -> String { "/api/orders/\(id)" }
        static func capturePayment(_ id: String) -> String { "/api/orders/\(id)/capture-payment" }

        // Uploads
        static let uploadFile = "/api/uploads/file"
        static let uploadShirtPhoto = "/api/uploads/shirt-photo"
        static let signedURL = "/api/uploads/signed-url"

        // Pricing
        static let priceQuote = "/api/price/quote"

        // Designs
        static let designs = "/api/designs"
        static func designDetail(_ id: String) -> String { "/api/designs/\(id)" }

        // Jobs
        static func jobStatus(_ id: String) -> String { "/api/jobs/\(id)" }
    }
}
