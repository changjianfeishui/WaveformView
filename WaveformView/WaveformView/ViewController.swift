//
//  ViewController.swift
//  WaveformView
//
//  Created by XB on 16/8/10.
//  Copyright © 2016年 XB. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    
        @IBOutlet weak var keysWaveformView: WaveformView!
        
        @IBOutlet weak var beatWaveformView: WaveformView!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let keysURL = Bundle.main.url(forResource: "keys", withExtension: "mp3")!
            let beatURL = Bundle.main.url(forResource: "beat", withExtension: "aiff")!

            
            keysWaveformView.waveColor = UIColor.blueWave()
            keysWaveformView.backgroundColor = UIColor.blueBackground()
            keysWaveformView.asset = AVURLAsset(url: keysURL)
            
            beatWaveformView.waveColor = UIColor.greenWave()
            beatWaveformView.backgroundColor = UIColor.greenBackground()
            beatWaveformView.asset = AVURLAsset(url: beatURL)
            
        }


}

extension UIColor {
    
    static func greenWave() -> UIColor {
        return UIColor(red: 0.714, green: 1.0, blue: 0.816, alpha: 1.0)
    }
    
    static func blueWave() -> UIColor {
        return UIColor(red: 0.749, green: 0.861, blue: 0.994, alpha: 1.0)
    }
    
    static func greenBackground() -> UIColor {
        return UIColor(red: 0.122, green: 0.618, blue: 0.240, alpha: 1.0)
    }
    
    static func blueBackground() -> UIColor {
        return UIColor(red: 0.142, green: 0.270, blue: 0.438, alpha: 1.0)
    }
    
}
