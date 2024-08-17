//
//  Chatbot.swift
//  FoodLogger
//
//  Created by Prasanna Kunisetty on 8/9/24.
//

import Foundation
import GoogleGenerativeAI

let apiKey = "AIzaSyAVFekMeJXuvGMziy5ApRjVkbzLodtPSrQ"

let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey)

func generateResponse(text: String) async -> String?  {

    let prompt = "Respond to the text in quotes. Keep your answer concise and do not use any special charactars in your response\" \(text) \""
    
    do {
        // Generate content using the model
        let response = try await model.generateContent(prompt)
        


        let outputText = response.candidates[0].content.parts[0].text

        if outputText == nil {
            print("Error: No Message Generated")
            return("Error in Message Generation. Please try again. ")
        }
        return(outputText)
    } catch {
        print("Error generating content: \(error.localizedDescription)")
        return("Error in Message Generation. Please try again")

    }

}
