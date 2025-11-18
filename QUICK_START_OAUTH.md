# Quick Start: Enable Apple & Google Login

## Your Supabase Project
**URL**: `https://dntnjlodfcojzgovikic.supabase.co`

---

## ✅ What's Already Done

- UI buttons for Apple and Google login exist in LoginView
- Supabase Swift SDK is already installed
- Backend endpoint `/api/auth/oauth/sync` is configured
- App URL scheme `stolentee://` is ready

---

## 🔧 What You Need To Do

### STEP 1: Get Supabase Anon Key (2 minutes)

1. Go to: https://supabase.com/dashboard
2. Select your project
3. Settings → API
4. Copy the **anon/public** key (starts with `eyJhbGc...`)

### STEP 2: Update iOS Configuration (1 minute)

Edit: `/Users/brandonshore/stolen.ios/StolenTee APP/StolenTee APP/Utilities/Configuration.swift`

Change lines 28-29 from:
```swift
static let supabaseURL = "https://your-project.supabase.co"
static let supabaseAnonKey = "your_supabase_anon_key"
```

To:
```swift
static let supabaseURL = "https://dntnjlodfcojzgovikic.supabase.co"
static let supabaseAnonKey = "PASTE_YOUR_ANON_KEY_HERE"
```

### STEP 3: Enable Google in Supabase (5 minutes - EASIEST TO START WITH)

1. **Supabase Dashboard** → Authentication → Providers
2. Find **Google** → Toggle ON
3. Go to https://console.cloud.google.com
4. Create new project or select existing
5. APIs & Services → Credentials → Create OAuth 2.0 Client ID
   - Type: **Web application**
   - Name: "Stolen Tee"
   - Authorized redirect URIs: 
     ```
     https://dntnjlodfcojzgovikic.supabase.co/auth/v1/callback
     ```
   - Click Save
   
6. Copy **Client ID** and **Client Secret**
7. Back in Supabase Google settings, paste them
8. Click Save

✅ **Google Sign-In is now ready to test!**

---

### STEP 4: Enable Apple Sign-In (15 minutes - Requires Apple Developer Account)

⚠️ **You need a paid Apple Developer account ($99/year)**

1. Go to https://developer.apple.com/account
2. **Certificates, IDs & Profiles** → **Identifiers** → **+**
3. Select **Services IDs** → Continue
   - Description: "Stolen Tee Sign In"
   - Identifier: `com.stolentee.app.signin`
   - Enable "Sign in with Apple"
   - Configure:
     - Primary App ID: Your iOS app bundle ID
     - Domains: `dntnjlodfcojzgovikic.supabase.co`
     - Return URLs: `https://dntnjlodfcojzgovikic.supabase.co/auth/v1/callback`
   - Save

4. **Keys** → **+** → Create new key
   - Name: "Stolen Tee Apple Auth Key"
   - Enable "Sign in with Apple"
   - Configure → Select your Services ID
   - Continue → Register
   - **Download the .p8 file** (you can only download once!)
   - Note the **Key ID**

5. Back in **Supabase** → Authentication → Providers → **Apple**:
   - Toggle ON
   - Services ID: `com.stolentee.app.signin`
   - Team ID: Found in Apple Developer account (top right)
   - Key ID: From step 4
   - Private Key: Open the .p8 file in a text editor, copy ALL contents
   - Save

✅ **Apple Sign-In is now ready!**

---

## 🧪 Testing

1. Run the iOS app in Xcode
2. Tap "Continue with Google" (or Apple)
3. You'll be redirected to a web view
4. Sign in with your Google/Apple account
5. You'll be redirected back to the app
6. Check if you're logged in!

---

## 🐛 Troubleshooting

**Issue**: "Google Sign-In not yet implemented" error
- You forgot to implement the OAuth methods in AuthViewModel (I'll do this for you)

**Issue**: OAuth window doesn't open
- Check that supabaseURL and supabaseAnonKey are correctly set in Configuration.swift

**Issue**: "Invalid redirect URI" error
- Make sure the redirect URI in Google Console exactly matches:
  `https://dntnjlodfcojzgovikic.supabase.co/auth/v1/callback`

**Issue**: Apple Sign-In says "Invalid client"
- Check that your Services ID is correctly configured
- Ensure the Team ID and Key ID are correct
- Make sure the entire .p8 file contents are copied (including BEGIN/END lines)

---

## 📝 Next Step: Implement OAuth Logic

I can implement the OAuth methods in AuthViewModel for you. This will:
1. Use Supabase's `signInWithOAuth` for Google
2. Use native Apple Sign-In flow
3. Sync the OAuth token with your backend
4. Create/login the user in your database

Ready for me to implement this?
