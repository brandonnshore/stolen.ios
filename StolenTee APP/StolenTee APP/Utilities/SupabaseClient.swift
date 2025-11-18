import Foundation
import Supabase

/// Shared Supabase client for OAuth authentication
enum SupabaseManager {
    static let shared: SupabaseClient = {
        return SupabaseClient(
            supabaseURL: URL(string: Configuration.supabaseURL)!,
            supabaseKey: Configuration.supabaseAnonKey
        )
    }()
}
