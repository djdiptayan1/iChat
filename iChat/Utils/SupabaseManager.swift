import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://wwjdsmkcfotltjvawqra.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3amRzbWtjZm90bHRqdmF3cXJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM3MzA1OTcsImV4cCI6MjAyOTMwNjU5N30.qRylrlbwrsjwwPFYOmExJN-2af3t1T5krC1pAY5ZFMg"
)

struct User: Decodable {
    let user_id: Int
    let username: String
    let email: String
    let password: String
    let created_at: String
    let date_of_birth: String
}

struct AddressType: Decodable {
    let address: String
    let address_type: String
}

struct ApplicationSettings: Decodable {
    let setting_id: Int
    let user_id: Int
    let theme_preference: String
    let sound_preference: String
    let notification_preference: String
}

struct AuthenticationLog: Decodable {
    let log_id: Int
    let user_id: Int
    let timestamp: String
    let log_type: String
}

struct Messages: Decodable {
    let message_id: Int
    let sender_time: String
    let receiver_time: String
    let message_size: Int
    let timestamp: String
}

struct UserAdress: Decodable {
    let address_id: Int
    let user_id: Int
    let address: String
}

struct UserHobbies: Decodable {
    let user_id: Int
    let hobby: String
}
