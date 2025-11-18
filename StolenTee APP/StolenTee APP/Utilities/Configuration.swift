import Foundation

enum Configuration {
    // MARK: - API Configuration
    static let apiURL: String = {
        #if DEBUG
        // Use production backend for now during development
        return "https://stolentee-backend-production.up.railway.app"
        // return "http://localhost:3001"  // Uncomment to use local backend
        #else
        return "https://stolentee-backend-production.up.railway.app"
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
    static let supabaseURL = "https://dntnjlodfcojzgovikic.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRudG5qbG9kZmNvanpnb3Zpa2ljIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MDgyNjMsImV4cCI6MjA3ODQ4NDI2M30.8YY5uyCsDGNWw-5KWE_1x55konvXd3N0fTyobr5N1k4"

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
