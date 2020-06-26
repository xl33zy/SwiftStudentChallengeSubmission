//
//  AudioPlayer.swift
//  G'aryshker
//
//  Created by Баубек on 3/11/20.
//  Copyright © 2020 BaubekZh. All rights reserved.
//

import Foundation
import AVFoundation

public struct AudioPlayer {
    static var audioPlayer = AVAudioPlayer()
    
    static func turnOnBacgkroundMusic() {
        initBackgroundAudio()
        audioPlayer.play()
    }
    
    static func initBackgroundAudio() {
        let assortedMusics = URL(fileReferenceLiteralResourceName: "bensound-slowmotion.mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: assortedMusics as URL)
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = -1
    }
}
