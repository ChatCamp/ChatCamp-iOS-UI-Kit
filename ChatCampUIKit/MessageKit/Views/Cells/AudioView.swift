//
//  AudioView.swift
//  ChatCamp Demo
//
//  Created by Saurabh Gupta on 12/06/18.
//  Copyright © 2018 iFlyLabs Inc. All rights reserved.
//

import UIKit
import AVFoundation

class AudioView: UIView {
    
    var audioFileURL: URL!
    var audioPlayer: AVAudioPlayer?
    
    func playAudio(_ audioUrl: URL) {
        do {
            if #available(iOS 10.0, *) {
                try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            } else {
                // fallback method for older iOS versions. Unfortunately there is none. Please update the device to iOS 10.0 +
            }
            
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            print("Could not load file")
        }
    }
}

extension AudioView: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
        print("finished playing")
    }
}
