# Stolen Tee - iOS App

A native iOS app for extracting logos from shirts using AI and creating custom apparel designs.

## Features

- 🤖 **AI-Powered Logo Extraction** - Upload a shirt photo, Gemini AI extracts the logo
- 🎨 **Design Customizer** - Interactive canvas with drag, pinch, rotate gestures
- 🛍️ **E-Commerce** - Browse products, customize, add to cart, checkout
- 💳 **Payments** - Stripe integration with Apple Pay support
- 👤 **Authentication** - Email/password + Google/Apple Sign In
- 💾 **Saved Designs** - Save and load your custom designs
- 📦 **Order Tracking** - Track your orders from payment to shipping

## Architecture

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI + UIKit (for canvas)
- **Minimum iOS**: 17.0
- **Architecture**: MVVM
- **Networking**: URLSession with async/await
- **Dependencies**: Swift Package Manager

## Project Structure

```
StolenTee/
├── Models/          # Data models matching backend API
├── Services/        # API clients and business logic
├── ViewModels/      # MVVM view models with @Published state
├── Views/           # SwiftUI screens and components
└── Utilities/       # Helpers, extensions, constants
```

## Setup Instructions

### 1. Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- Backend API running (see `stolen/backend`)

### 2. Configure API Endpoints

Open `StolenTee/Utilities/Configuration.swift` and update:

```swift
// For local development
static let apiURL = "http://localhost:3001"

// For production
static let apiURL = "https://raspberrymerch.com"
```

### 3. Add API Keys

#### Stripe
Get your publishable key from [Stripe Dashboard](https://dashboard.stripe.com/apikeys):

```swift
// In Configuration.swift
static let stripePublishableKey = "pk_test_YOUR_KEY_HERE"
```

#### Supabase (for OAuth)
Get credentials from [Supabase Dashboard](https://supabase.com/dashboard):

```swift
// In Configuration.swift
static let supabaseURL = "https://YOUR_PROJECT.supabase.co"
static let supabaseAnonKey = "YOUR_ANON_KEY"
```

### 4. Install Dependencies

Dependencies are managed via Swift Package Manager and defined in `Package.swift`:

- Stripe iOS SDK
- Supabase Swift SDK

Xcode will automatically resolve these when you open the project.

### 5. Configure OAuth Providers

#### Apple Sign In
1. In Xcode, select the project target
2. Go to "Signing & Capabilities"
3. Click "+ Capability" and add "Sign in with Apple"

#### Google Sign In
1. Create OAuth credentials in [Google Cloud Console](https://console.cloud.google.com)
2. Add redirect URI: `stolentee://auth/callback`
3. Configure in Supabase Dashboard

### 6. Build and Run

1. Open `StolenTee.xcodeproj` in Xcode
2. Select a simulator or connected device
3. Press `Cmd + R` to build and run

## Testing

### Test Accounts

For testing, you can create an account via:
- Email/password registration
- Sign in with Apple (sandbox)
- Sign in with Google

### Test Cards (Stripe)

Use these test cards in checkout:
- Success: `4242 4242 4242 4242`
- Requires authentication: `4000 0025 0000 3155`
- Declined: `4000 0000 0000 9995`

Any future expiry date and any 3-digit CVC.

### Test AI Extraction

1. Upload a photo of a shirt with a visible logo
2. Wait for extraction (uses Gemini AI via backend)
3. Logo should appear on canvas automatically

## Key Components

### Services
- `AuthService` - Login, register, JWT management
- `ProductService` - Fetch products and variants
- `OrderService` - Create orders, track status
- `UploadService` - Upload images, AI extraction polling
- `DesignService` - Save/load custom designs
- `PricingService` - Calculate dynamic pricing
- `OAuthService` - Google & Apple authentication
- `StripePaymentService` - Payment processing

### Views
- `HomeView` - Landing page with hero
- `ProductsView` - Product grid with filters
- `ProductDetailView` - Product detail with variant selection
- `CustomizerView` - Full customization interface
- `DesignCanvasView` - Interactive canvas with gestures
- `CartView` - Shopping cart with swipe actions
- `CheckoutView` - Payment with Apple Pay
- `DashboardView` - Saved designs
- `OrderTrackingView` - Order status timeline

### ViewModels
- `AuthViewModel` - Authentication state
- `CartViewModel` - Cart with UserDefaults persistence
- `ProductsViewModel` - Product browsing logic
- `CustomizerViewModel` - Canvas state & extraction

## Documentation

- `API_INTEGRATION_GUIDE.md` - API setup and configuration
- `INTEGRATION_STATUS.md` - Complete API audit report
- `CANVAS_IMPLEMENTATION.md` - Canvas architecture deep dive
- `INTEGRATION_GUIDE.md` - Canvas integration instructions

## Development Workflow

### Running Locally

1. Start backend server:
   ```bash
   cd ../stolen/backend
   npm run dev
   ```

2. Start Redis (for job queue):
   ```bash
   redis-server
   ```

3. Run iOS app in Xcode

### Common Issues

**Issue**: API calls fail with "Network error"
- **Solution**: Ensure backend is running on `localhost:3001`
- Check `Configuration.swift` has correct API URL

**Issue**: "Unauthorized" errors
- **Solution**: JWT token may be expired, log out and log back in

**Issue**: Photo upload fails
- **Solution**: Check backend upload size limit (default 10MB)

**Issue**: Extraction times out
- **Solution**: Check Redis is running, check Gemini API key in backend settings

## Production Deployment

### Before App Store Submission

1. ✅ Update `CFBundleVersion` in Info.plist
2. ✅ Change API URL to production in Configuration.swift
3. ✅ Add production Stripe keys
4. ✅ Remove `NSAllowsArbitraryLoads` from Info.plist
5. ✅ Add app icons to Assets.xcassets
6. ✅ Add launch screen
7. ✅ Enable App Transport Security
8. ✅ Test on physical devices (iPhone, iPad)
9. ✅ Complete App Store Connect setup

### App Store Requirements

- [ ] App icon (1024x1024)
- [ ] Screenshots (all required sizes)
- [ ] Privacy policy URL
- [ ] App description and keywords
- [ ] Age rating questionnaire

## Backend Integration

This iOS app connects to the same backend as the web app:

**Repository**: https://github.com/brandonnshore/stolen.git
**Backend Location**: `stolen/backend`

The iOS app uses the same API endpoints, data models, and business logic as the React web app.

## License

Copyright © 2024 Stolen Tee

## Support

For issues or questions:
- Check documentation in the `/Documentation` folder
- Review agent reports for comprehensive integration details
- Open an issue in the GitHub repository
