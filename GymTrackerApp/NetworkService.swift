//
//  NetworkService.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 10/5/25.
//

import Foundation

class NetworkService {
    // A shared instance for easy access, like a singleton
    static let shared = NetworkService()
    
    // The URL for your deployed Cloud Function
    private let baseURL = URL(string: "https://us-central1-gymtrackerapp-70bdc.cloudfunctions.net/generate_initial_plan")!

    private init() {}

    // This function will take a UserProfile, send it to your backend,
    // and return the AI-generated workout plan.
    func generateInitialPlan(for profile: UserProfile, completion: @escaping (Result<[Workout], Error>) -> Void) {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            // Create a dictionary to hold the JSON data
            let profileData: [String: Any] = [
                "name": profile.name,
                "age": profile.age,
                "gender": profile.gender.rawValue,
                "height": profile.heightInMeters, // Use the converted value
                "weight": profile.weightInKilograms, // Use the converted value
                "fitnessLevel": profile.fitnessLevel.rawValue,
                "goal": profile.goal.rawValue,
                "daysPerWeek": profile.daysPerWeek,
                "sessionDurationHours": profile.sessionDurationHours
            ]
            
            // Encode the dictionary into JSON data
            request.httpBody = try JSONSerialization.data(withJSONObject: profileData, options: [])
            
        } catch {
            print("Error encoding user profile: \(error)")
            completion(.failure(error))
            return
        }

        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network request error: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received from server.")
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                // Decode the JSON response from the server into our Swift Workout models
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let workouts = try decoder.decode([Workout].self, from: data)
                
                // Success! Send the workouts back.
                DispatchQueue.main.async {
                    completion(.success(workouts))
                }
            } catch {
                print("Error decoding workouts: \(error)")
                // Log the raw response to see what the server sent
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw server response: \(responseString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
