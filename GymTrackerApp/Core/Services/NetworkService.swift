//
//  NetworkService.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 10/5/25.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL: URL
    private let requestTimeout: TimeInterval = 30.0
    
    private init() {
        // Safe URL initialization with fallback
        if let url = URL(string: "https://convert-and-get-a76avtriqq-uc.a.run.app") {
            self.baseURL = url
        } else if let fallbackURL = URL(string: "https://example.com") {
            // Fallback URL (should never happen, but prevents crash)
            self.baseURL = fallbackURL
            #if DEBUG
            print("⚠️ Warning: Invalid baseURL, using fallback")
            #endif
        } else {
            // Absolute last resort - this should never happen
            // If this fails, the app will crash, but it's better than a silent failure
            self.baseURL = URL(string: "http://localhost")!
            #if DEBUG
            print("⚠️ Critical: All URL fallbacks failed, using localhost")
            #endif
        }
    }

    func generateInitialPlan(for profile: UserProfile, completion: @escaping (Result<[Workout], Error>) -> Void) {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = requestTimeout

        do {
            let profileData: [String: Any] = [
                "name": profile.name,
                "age": profile.age,
                "gender": profile.gender.rawValue,
                "height": profile.heightInMeters,
                "weight": profile.weightInKilograms,
                "fitnessLevel": profile.fitnessLevel.rawValue,
                "goal": profile.goal.rawValue,
                "daysPerWeek": profile.daysPerWeek,
                "sessionDurationHours": profile.sessionDurationHours,
                "workoutEnvironment": profile.workoutEnvironment.rawValue
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: profileData, options: [])
            
            #if DEBUG
            print("NetworkService: Sending profile data (name, age, gender, etc.)")
            #endif
            
        } catch {
            #if DEBUG
            print("Error encoding user profile: \(error)")
            #endif
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Helper to ensure completion is always called on main thread
            func completeOnMain(_ result: Result<[Workout], Error>) {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            if let error = error {
                #if DEBUG
                print("Network request error: \(error.localizedDescription)")
                #endif
                completeOnMain(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completeOnMain(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                #if DEBUG
                print("Server returned status code: \(httpResponse.statusCode)")
                #endif
                completeOnMain(.failure(URLError(.badServerResponse)))
                return
            }

            guard let data = data else {
                completeOnMain(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let workouts = try decoder.decode([Workout].self, from: data)
                completeOnMain(.success(workouts))
            } catch {
                #if DEBUG
                print("Error decoding workouts: \(error.localizedDescription)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw server response: \(responseString.prefix(200))")
                }
                #endif
                completeOnMain(.failure(error))
            }
        }.resume()
    }
}
