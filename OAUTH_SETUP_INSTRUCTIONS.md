# Apple & Google Login Setup Instructions

## Step 1: Get Your Supabase Credentials

1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to **Settings** → **API**
4. Copy these values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbGc...` (long string)

## Step 2: Update Configuration.swift

Open: `StolenTee APP/StolenTee APP/Utilities/Configuration.swift`

Replace lines 28-29 with your actual values:
```swift
static let supabaseURL = "https://YOUR-PROJECT-ID.supabase.co"
static let supabaseAnonKey = "your_actual_anon_key_here"
```

## Step 3: Configure OAuth Providers in Supabase

### Apple Sign-In Setup:

1. **Supabase Dashboard** → Authentication → Providers → **Apple**
2. Toggle **Apple Enabled** to ON
3. You need an Apple Developer Account ($99/year):
   - Go to https://developer.apple.com/account
   - **Certificates, Identifiers & Profiles** → **Keys**
   - Create a new key with "Sign in with Apple" enabled
   - Download the `.p8` key file
   - Note the **Key ID**
   
4. **Create a Service ID**:
   - Go to **Identifiers** → Click **+** → **Services IDs**
   - Description: "Stolen Tee Sign In"
   - Identifier: `com.stolentee.app.signin`
   - Enable "Sign in with Apple"
   - Configure redirect URL: `https://YOUR-PROJECT.supabase.co/auth/v1/callback`

5. Back in Supabase, enter:
   - **Services ID**: `com.stolentee.app.signin`
   - **Authorized Client IDs**: Your app's bundle ID (e.g., `com.stolentee.app`)
   - **Team ID**: From Apple Developer Account
   - **Private Key**: Contents of the `.p8` file
   - **Key ID**: From step 3

### Google Sign-In Setup:

1. **Supabase Dashboard** → Authentication → Providers → **Google**
2. Toggle **Google Enabled** to ON
3. Go to https://console.cloud.google.com
4. Create a project (or select existing)
5. **APIs & Services** → **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
   - Application type: **iOS**
   - Name: "Stolen Tee iOS"
   - Bundle ID: `com.stolentee.app` (your actual bundle ID)
   
6. Also create a **Web application** OAuth client:
   - Authorized redirect URIs: `https://YOUR-PROJECT.supabase.co/auth/v1/callback`
   
7. Back in Supabase, enter the **Web application** credentials:
   - **Client ID**: `xxxxx.apps.googleusercontent.com`
   - **Client Secret**: `GOCSPX-xxxxx`

## Step 4: Update iOS Info.plist

Add URL scheme for OAuth callbacks:

1. Open Xcode
2. Select your project → **Info** tab
3. Add **URL Types**:
   - **Identifier**: `stolentee`
   - **URL Schemes**: `stolentee`

This allows Supabase to redirect back to your app after OAuth.

## Step 5: Install Google Sign-In SDK (Optional - for better UX)

For a native Google Sign-In experience (recommended):

1. Add to your `Package.swift` or SPM:
   ```
   https://github.com/google/GoogleSignIn-iOS
   ```

2. Or use Supabase's web-based OAuth (simpler, works already with current code)

## Step 6: Test OAuth Flow

1. Run the app in Xcode
2. Go to Login screen
3. Tap "Continue with Apple" or "Continue with Google"
4. You should be redirected to OAuth provider
5. After authentication, you'll be redirected back to the app
6. Your backend will receive the OAuth token and create/login the user

---

## Backend Endpoint Required

Your backend needs to handle the OAuth callback:

**Endpoint**: `POST /api/auth/oauth/sync`

This endpoint should:
1. Receive the Supabase user data from OAuth
2. Find or create a user in your database
3. Return a JWT token for your app

The current backend already has this endpoint configured (Configuration.swift:41)

---

## Quick Start (Minimum Viable):

If you just want to test quickly:

1. Get Supabase URL and anon key
2. Update Configuration.swift
3. Enable Google OAuth in Supabase (easier than Apple)
4. Use the web-based OAuth flow (no extra SDK needed)
5. Test with Google Sign-In button

That's it! The OAuth logic is already in the Supabase Swift SDK.
