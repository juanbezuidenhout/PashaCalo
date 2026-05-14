import Foundation
import Supabase

/// Errors thrown by `SupabaseManager` when the backend cannot service a request.
enum SupabaseManagerError: LocalizedError {
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Supabase is not configured. Open Config.swift and set `supabaseURL` to your project's https URL and `supabaseAnonKey` to your anon key."
        }
    }
}

@MainActor
final class SupabaseManager {
    static let shared = SupabaseManager()

    /// True when `Config.supabaseURL` and `Config.supabaseAnonKey` look like real
    /// values (https URL with a host, non-placeholder, non-empty key).
    /// When false, the SDK is *not* initialized and all backend methods throw
    /// `SupabaseManagerError.notConfigured`. This lets the app boot on the
    /// simulator before real credentials are wired in.
    let isConfigured: Bool

    /// Reference to the app's global state. Attached at launch from `PashaCaloApp`.
    /// Held weakly to avoid a retain cycle.
    weak var appState: AppState?

    private let client: SupabaseClient?

    private init() {
        if let validURL = Self.validatedURL(from: Config.supabaseURL),
           Self.isValidAnonKey(Config.supabaseAnonKey) {
            self.client = SupabaseClient(
                supabaseURL: validURL,
                supabaseKey: Config.supabaseAnonKey
            )
            self.isConfigured = true
        } else {
            self.client = nil
            self.isConfigured = false
            #if DEBUG
            print("⚠️ SupabaseManager: running without a configured backend. Update Config.swift to enable auth and data sync.")
            #endif
        }
    }

    // MARK: - Configuration validation

    private static func validatedURL(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !trimmed.uppercased().contains("YOUR_"),
              let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              let host = url.host,
              !host.isEmpty
        else { return nil }
        return url
    }

    private static func isValidAnonKey(_ raw: String) -> Bool {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && !trimmed.uppercased().contains("YOUR_")
    }

    /// Returns the live client or throws `notConfigured` so callers never
    /// dereference a missing backend.
    private func requireClient() throws -> SupabaseClient {
        guard let client else { throw SupabaseManagerError.notConfigured }
        return client
    }

    // MARK: - Session helpers

    /// Convenience accessor for the currently authenticated user's ID.
    /// Consumers can use this without importing the `Supabase` module.
    var currentUserID: UUID? {
        client?.auth.currentUser?.id
    }

    var isSignedIn: Bool {
        client?.auth.currentUser != nil
    }

    // MARK: - Auth

    func signInWithApple(idToken: String, nonce: String) async throws {
        let client = try requireClient()
        _ = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        appState?.setAuthenticated(true)
    }

    func signInWithGoogle(idToken: String) async throws {
        let client = try requireClient()
        _ = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .google, idToken: idToken)
        )
        appState?.setAuthenticated(true)
    }

    func signOut() async throws {
        let client = try requireClient()
        try await client.auth.signOut()
        appState?.setAuthenticated(false)
    }

    // MARK: - Profile

    func saveProfile(_ profile: UserProfile) async throws {
        let client = try requireClient()
        try await client
            .from("profiles")
            .upsert(profile)
            .execute()
    }

    func loadProfile() async throws -> UserProfile? {
        let client = try requireClient()
        guard let userId = client.auth.currentUser?.id else { return nil }
        let profiles: [UserProfile] = try await client
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
        let client = try requireClient()
        try await client
            .from("food_entries")
            .insert(entry)
            .execute()
    }

    func loadTodayEntries() async throws -> [FoodEntry] {
        let client = try requireClient()
        guard let userId = client.auth.currentUser?.id else { return [] }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let startOfDayString = formatter.string(from: startOfDay)

        let entries: [FoodEntry] = try await client
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
        let client = try requireClient()
        guard let userId = client.auth.currentUser?.id else { return }

        try await client
            .from("food_entries")
            .delete()
            .eq("user_id", value: userId)
            .execute()

        try await client
            .from("profiles")
            .delete()
            .eq("id", value: userId)
            .execute()

        try await client.auth.signOut()
        appState?.setAuthenticated(false)
        appState?.setSubscribed(false)
    }
}
