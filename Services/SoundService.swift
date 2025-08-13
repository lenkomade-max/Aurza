//
//  SoundService.swift
//  AURZA
//

import AVFoundation

class SoundService: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "soundsEnabled")
        }
    }
    
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "soundsEnabled")
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(_ name: String) {
        guard isEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else {
            // Use system sound as fallback
            AudioServicesPlaySystemSound(1104)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    func playCompletionSound() {
        playSound("completion")
    }
    
    func playAchievementSound() {
        playSound("achievement")
    }
    
    func playSelectionSound() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }
}
