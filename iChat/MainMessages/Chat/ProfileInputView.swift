import Supabase
import SwiftUI

struct ProfileInputView: View {
    let soundOptions = ["On", "Off"]
    let notificationOptions = ["Email", "Push"]
    let themeOptions = ["Light", "Dark"]

    @State private var displayName: String = ""
    @State private var address: String = ""
    @State private var hobbies: String = ""
    @State var soundIsOn = true
    @State var notificationIsEmail = true
    @State var selectedTheme = 0

    var body: some View {
        VStack {
            Text("Profile Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            // Address
            TextField("Address", text: $address)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 10)

            // Hobbies
            TextField("Hobbies", text: $hobbies)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 10)

            Spacer()

            // Toggle for sound preference
            Toggle(isOn: $soundIsOn) {
                Text("Sound Preference")
            }
            .padding(.bottom, 10)

            // Toggle for notification preference
            Toggle(isOn: $notificationIsEmail) {
                Text("Notification Preference")
            }
            .padding(.bottom, 10)

            // Toggle for theme preference
            Text("Theme Preference")
            Picker("Theme Preference", selection: $selectedTheme) {
                ForEach(0 ..< themeOptions.count, id: \.self) {
                    Text(self.themeOptions[$0])
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Spacer()

            Button(action: {
                Task {
                    do {
                        try await Profile_supa()
                    } catch {
                        print("Failed to fetch user: \(error)")
                    }
                }
            }) {
                Text("Save Changes")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    func Profile_supa() async throws {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // ISO 8601 format
            let currentDateString = dateFormatter.string(from: Date()) // Format the current date

            // Insert into user_address
            try await supabase.database
                .from("user_address")
                .insert([
                    "user_id": FirebaseManager.shared.auth.currentUser?.uid,
                    "address": address,
                ])
                .execute()

            // Insert into user_hobbies
            try await supabase.database
                .from("user_hobbies")
                .insert([
                    "user_id": FirebaseManager.shared.auth.currentUser?.uid,
                    "hobby": hobbies,
                ])
                .execute()

            // Insert into application_settings
            try await supabase.database
                .from("application_settings")
                .insert([
                    "user_id": FirebaseManager.shared.auth.currentUser?.uid,
                    "sound_preference": soundIsOn ? "On" : "Off",
                    "notification_preference": notificationIsEmail ? "Email" : "Push",
                    "theme_preference": themeOptions[selectedTheme]
                ])
                .execute()

            print("INSERTED INTO SUPABASE DB")
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
}
