# Stolen Tee iOS - API Integration Guide

This guide provides complete setup instructions for all external API integrations required by the Stolen Tee iOS app.

## Table of Contents

1. [Backend REST API](#backend-rest-api)
2. [Stripe Payment Processing](#stripe-payment-processing)
3. [Supabase OAuth (Google & Apple Sign In)](#supabase-oauth)
4. [Configuration Setup](#configuration-setup)
5. [Testing](#testing)

---

## Backend REST API

### Overview
The iOS app communicates with the Node.js/Express backend for all data operations.

### Status: ✅ FULLY INTEGRATED

### Endpoints Implemented
All backend endpoints are properly integrated via service classes:

- **AuthService**: Login, register, get current user
- **ProductService**: Get products, product details
- **OrderService**: Create orders, get order status, capture payments
- **UploadService**: Upload images, upload shirt photos, check job status
- **DesignService**: Save, retrieve, update, delete designs
- **PricingService**: Get price quotes

### Configuration
Set your backend URL in `Configuration.swift`:

```swift
static let apiURL: String = {
    #if DEBUG
    return "http://localhost:3001"  // Development
    #else
    return "https://raspberrymerch.com"  // Production
    #endif
}()
```

### Authentication
- JWT tokens stored securely in iOS Keychain
- Automatic token attachment to authenticated requests
- Token refresh handled via `/api/auth/me` endpoint

---

## Stripe Payment Processing

### Overview
Stripe handles all payment processing, including Apple Pay and credit cards.

### Status: ⚠️ NEEDS CONFIGURATION

### Required Setup

#### 1. Get Stripe Keys
1. Go to https://dashboard.stripe.com/apikeys
2. Copy your **Publishable Key** (starts with `pk_test_` or `pk_live_`)

#### 2. Configure iOS App
Update `Configuration.swift`:

```swift
static let stripePublishableKey: String = {
    #if DEBUG
    return "pk_test_YOUR_TEST_KEY_HERE"
    #else
    return "pk_live_YOUR_LIVE_KEY_HERE"
    #endif
}()
```

#### 3. Configure Apple Pay (Optional but Recommended)

##### Create Merchant ID:
1. Go to https://developer.apple.com/account/resources/identifiers/list/merchant
2. Click "+" to create new Merchant ID
3. Set ID: `merchant.com.stolenlee.app`
4. Enable for your app

##### Update StripePaymentService.swift:
Replace `merchant.com.stolenlee.app` with your actual Merchant ID if different.

##### Add Capability to Xcode:
1. Select your project target
2. Go to "Signing & Capabilities"
3. Click "+ Capability"
4. Add "Apple Pay"
5. Select your Merchant ID

### Implementation

The `StripePaymentService` class handles:
- Payment Sheet presentation
- Apple Pay configuration
- Payment confirmation with backend

### Usage Example

```swift
// In CheckoutView or similar
let order = try await OrderService.shared.createOrder(request: orderRequest)

let wrapper = StripePaymentSheetWrapper(
    order: order,
    clientSecret: order.clientSecret
)

await wrapper.present { result in
    switch result {
    case .success(let orderId):
        print("Payment successful! Order ID: \(orderId)")
    case .failure(let error):
        print("Payment failed: \(error)")
    }
}
```

---

## Supabase OAuth

### Overview
Supabase handles OAuth authentication for Google and Apple Sign In.

### Status: ⚠️ NEEDS CONFIGURATION

### Required Setup

#### 1. Get Supabase Credentials
1. Go to https://supabase.com/dashboard
2. Select your project (or create one)
3. Go to **Settings → API**
4. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key**

#### 2. Configure iOS App
Update `Configuration.swift`:

```swift
static let supabaseURL = "https://YOUR_PROJECT.supabase.co"
static let supabaseAnonKey = "YOUR_ANON_KEY_HERE"
```

#### 3. Configure OAuth Providers in Supabase

##### Google OAuth:
1. In Supabase Dashboard: **Authentication → Providers**
2. Enable **Google**
3. Go to https://console.cloud.google.com/apis/credentials
4. Create OAuth 2.0 Client ID
5. Add redirect URI: `https://YOUR_PROJECT.supabase.co/auth/v1/callback`
6. Copy Client ID and Secret to Supabase
7. For iOS, create another OAuth Client ID (iOS type)
8. Copy iOS Client ID

##### Apple Sign In:
1. Go to https://developer.apple.com/account/resources/identifiers/list
2. Create a Service ID
3. Configure Sign in with Apple
4. Add redirect URI: `https://YOUR_PROJECT.supabase.co/auth/v1/callback`
5. In Supabase: Enable **Apple** provider
6. Enter Service ID, Team ID, and Key ID

#### 4. Configure URL Scheme in iOS

Create or edit `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>stolentee</string>
        </array>
    </dict>
</array>
```

#### 5. Handle OAuth Callbacks

In your `App.swift` or main app file:

```swift
import SwiftUI

@main
struct StolenTeeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Task {
                        try? await OAuthService.shared.handleOAuthCallback(url: url)
                    }
                }
        }
    }
}
```

### Implementation

The `OAuthService` class provides:
- `signInWithGoogle()`: Initiates Google OAuth flow
- `signInWithApple(credential:)`: Handles Apple Sign In
- `handleOAuthCallback(url:)`: Processes OAuth redirects
- Backend sync via `/api/auth/oauth/sync`

### Usage Example

```swift
// Google Sign In
Button("Sign in with Google") {
    Task {
        do {
            let authResponse = try await OAuthService.shared.signInWithGoogle()
            // User is now logged in with JWT from backend
        } catch {
            print("OAuth error: \(error)")
        }
    }
}

// Apple Sign In
SignInWithAppleButton { request in
    request.requestedScopes = [.fullName, .email]
} onCompletion: { result in
    switch result {
    case .success(let authorization):
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            Task {
                let authResponse = try await OAuthService.shared.signInWithApple(credential: credential)
                // User is now logged in
            }
        }
    case .failure(let error):
        print("Apple Sign In failed: \(error)")
    }
}
```

---

## Configuration Setup

### Step-by-Step Configuration

1. **Clone and Open Project**
   ```bash
   cd /Users/brandonshore/stolen.ios
   open Package.swift
   ```

2. **Update Configuration.swift**
   - Add Stripe publishable keys
   - Add Supabase URL and anon key
   - Verify backend API URL

3. **Add Info.plist** (if not exists)
   - Configure URL schemes for OAuth
   - Enable Apple Pay capability

4. **Install Dependencies**
   Swift Package Manager will automatically fetch:
   - Stripe iOS SDK v23.0.0
   - Supabase Swift v2.0.0

5. **Build and Test**
   ```bash
   # Build project
   xcodebuild -scheme StolenTee -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

---

## Testing

### Test Backend Connection
```swift
// Test API health
let response = try await URLSession.shared.data(from: URL(string: "\(Configuration.apiURL)/health")!)
print(String(data: response.0, encoding: .utf8)) // Should print: {"status":"ok"}
```

### Test Stripe
```swift
// Verify Stripe key is set
print(STPAPIClient.shared.publishableKey) // Should print your pk_test_... key
```

### Test Supabase
```swift
// Verify Supabase client initializes
let client = SupabaseClient(
    supabaseURL: URL(string: Configuration.supabaseURL)!,
    supabaseKey: Configuration.supabaseAnonKey
)
print("Supabase initialized: \(client)")
```

---

## Environment Variables Summary

| Service | Variable | Location | Required |
|---------|----------|----------|----------|
| Backend API | `apiURL` | Configuration.swift | ✅ Yes |
| Stripe | `stripePublishableKey` | Configuration.swift | ✅ Yes |
| Supabase | `supabaseURL` | Configuration.swift | ⚠️ For OAuth |
| Supabase | `supabaseAnonKey` | Configuration.swift | ⚠️ For OAuth |
| App URL Scheme | `appURLScheme` | Configuration.swift + Info.plist | ⚠️ For OAuth |

---

## Troubleshooting

### "Invalid Stripe key" error
- Verify your publishable key starts with `pk_test_` or `pk_live_`
- Make sure you're not using the secret key (starts with `sk_`)

### OAuth callback not working
- Verify URL scheme in Info.plist matches `Configuration.appURLScheme`
- Check Supabase redirect URIs include your app's scheme
- Ensure `.onOpenURL` is set up in your app

### Backend connection timeout
- Verify backend is running on port 3001
- Check CORS settings in backend allow iOS app origin
- Test backend health endpoint: `http://localhost:3001/health`

---

## Additional Resources

- [Stripe iOS SDK Documentation](https://stripe.com/docs/payments/accept-a-payment?platform=ios)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Backend API Documentation](../stolen/stolen1/backend/README.md)

---

## Support

For issues or questions:
1. Check backend logs for API errors
2. Use Xcode debugger to inspect network requests
3. Verify all configuration values are correctly set
