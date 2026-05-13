import Foundation
import Supabase

@MainActor
final class SupabaseManager {
    static let shared = SupabaseManager()

    let supabase: SupabaseClient

    /// Reference to the app's global state. Attached at launch from `PashaCaloApp`.
    /// Held weakly to avoid a retain cycle.
    weak var appState: AppState?

    private init() {
        guard let url = URL(string: Config.supabaseURL) else {
            fatalError("Invalid Supabase URL in Config.swift. Replace YOUR_SUPABASE_URL with a real project URL.")
        }
        self.supabase = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Config.supabaseAnonKey
        )
    }

    // MARK: - Session helpers

    /// Convenience accessor for the currently authenticated user's ID.
    /// Consumers can use this without importing the `Supabase` module.
    var currentUserID: UUID? {
        supabase.auth.currentUser?.id
    }

    var isSignedIn: Bool {
        supabase.auth.currentUser != nil
    }

    // MARK: - Auth

    func signInWithApple(idToken: String, nonce: String) async throws {
        _ = try await supabase.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        appState?.setAuthenticated(true)
    }

    func signInWithGoogle(idToken: String) async throws {
        _ = try await supabase.auth.signInWithIdToken(
            credentials: .init(provider: .google, idToken: idToken)
        )
        appState?.setAuthenticated(true)
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
        appState?.setAuthenticated(false)
    }

    // MARK: - Profile

    func saveProfile(_ profile: UserProfile) async throws {
        try await supabase
            .from("profiles")
            .upsert(profile)
            .execute()
    }

    func loadProfile() async throws -> UserProfile? {
        guard let userId = supabase.auth.currentUser?.id else { return nil }
        let profiles: [UserProfile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value
        return profiles.first
    }

    // MARK: - Food entries

    func saveFoodEntry(_ entry: FoodEntry) async throws {
        try await supabase
            .from("food_entries")
            .insert(entry)
            .execute()
    }

    func loadTodayEntries() async throws -> [FoodEntry] {
        guard let userId = supabase.auth.currentUser?.id else { return [] }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let startOfDayString = formatter.string(from: startOfDay)

        let entries: [FoodEntry] = try await supabase
            .from("food_entries")
            .select()
            .eq("user_id", value: userId)
            .gte("logged_at", value: startOfDayString)
            .order("logged_at", ascending: false)
            .execute()
            .value
        return entries
    }

    // MARK: - Account lifecycle

    func deleteAccount() async throws {
        guard let userId = supabase.auth.currentUser?.id else { return }

        try await supabase
            .from("food_entries")
            .delete()
            .eq("user_id", value: userId)
            .execute()

        try await supabase
            .from("profiles")
            .delete()
            .eq("id", value: userId)
            .execute()

        try await supabase.auth.signOut()
        appState?.setAuthenticated(false)
        appState?.setSubscribed(false)
    }
}
