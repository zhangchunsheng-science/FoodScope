/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI
import AVFoundation

var outputText = ""


let voices: [String:String] = [
    "Adam": "pNInz6obpgDQGcFmaJgB",
    "Alice": "Xb7hH8MSUJpSbSDYk0k2",
    "Charlie": "IKne3meq5aSn9XLyUdCD",
    "Glinda": "z9fAnlkpzviPz146aGWa"
]
var currentVoice = voices["Adam"]

struct STTView: View {
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    
    var body: some View {
        
        VStack {
            
            Button("Record Button") {
                startRecording()
            }
            .padding(10)
            .border(.green, width: 4)
            .padding(.bottom, 65)
            
            Button ("End Record") {
                endRecording()
            }
            .padding(10)
            .border(.red, width:4)
            
            
                        
            if speechRecognizer.transcript != ""{
                Text(speechRecognizer.transcript)
                    .padding(10)
                    .background(.teal)
                    .padding(.top, 20)
                    .font(.title)
                    .bold()

                }
            
                Menu("Choose Voice \(Character(Unicode.Scalar(9660)!))"){
                    ForEach(voices.keys.sorted(), id:\.self) { key in
                        Button(key){
                            setVoice(voiceId:voices[key]!)
                        }
                    }
    
                }
                .padding(10)
                .border(Color.black, width: 3)
            


        }

        .onDisappear {
            if isRecording == true {
                print(isRecording)
                endRecording()
            }
        }
    }
    
    private func startRecording() {

        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
    }
    
    private func endRecording() {
        speechRecognizer.stopTranscribing()
        isRecording = false
        print(speechRecognizer.transcript)
        Task {
            await outputText =  generateResponse(text:speechRecognizer.transcript) ?? "No message Generated"
            
            generateSpeech(text: outputText, voice: currentVoice!)

                        
            
        }
        

    }
    

}

func setVoice ( voiceId: String){
    currentVoice = voiceId
    
}
