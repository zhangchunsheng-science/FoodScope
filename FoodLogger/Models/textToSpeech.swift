import Foundation
import AVFoundation

struct ELVoiceSettings: Codable {
    let stability: Double
    let similarityBoost: Double
    let useSpeakerBoost: Bool
}

struct ELSpeechRequest: Codable {
    let text: String
    let modelId: String
    let voiceSettings: ELVoiceSettings
}

func generateSpeech(text: String, voice: String) {
    
    let apiKey = "sk_581c067e728b36b1972c293e86ffd36dffa10cd06d0463ba"
    let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voice)")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
    request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
    
    let voiceSettings = ELVoiceSettings(stability: 0.5, similarityBoost: 0.90, useSpeakerBoost: true)
    let speechRequest = ELSpeechRequest(text: text, modelId: voice, voiceSettings: voiceSettings)
    
    guard let httpBody = try? JSONEncoder().encode(speechRequest) else {
        print("Failed to encode request body")
        return
    }
    request.httpBody = httpBody
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Network error: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response type")
            return
        }
        
        print("HTTP Status Code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("HTTP Error: Status Code \(httpResponse.statusCode)")
            if let data = data {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                print("Response Body: \(responseString)")
            }
            return
        }
        
        guard let data = data, !data.isEmpty else {
            print("Received empty data")
            return
        }

        // Debug the MIME type
        if let mimeType = httpResponse.mimeType {
            print("MIME Type: \(mimeType)")
        }

        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let customFolderURL = documentsDirectory.appendingPathComponent("Audios")
        
        // Create the folder if it doesn't exist
        do {
            try fileManager.createDirectory(at: customFolderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
            return
        }
        
        // Define the file URL
        let fileURL = customFolderURL.appendingPathComponent("output.mp3")
        
        // Write data to file
        do {
            try data.write(to: fileURL)
            print("Audio file written to: \(fileURL.path)")
            
            // Play the audio from the file
            playAudio(fileURL: fileURL)
        } catch {
            print("Error writing audio file: \(error.localizedDescription)")
        }
    }
    task.resume()
}

var player : AVAudioPlayer?
func playAudio(fileURL: URL) {

    do {
        player = try AVAudioPlayer(contentsOf: fileURL)
        player!.prepareToPlay()
        player!.play()
        
    } catch let error {
        print(error.localizedDescription)
    }
}
