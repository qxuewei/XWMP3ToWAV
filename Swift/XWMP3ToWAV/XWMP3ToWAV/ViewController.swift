//
//  ViewController.swift
//  XWMP3ToWAV
//
//  Created by 邱学伟 on 2017/3/13.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.textMP3ToPCM()
    }
}

extension ViewController {
    
    func textMP3ToPCM() {
        guard let mp3FilePath : String = Bundle.main.path(forResource: "NoGoodbye.mp3", ofType: nil) else { print("mp3 资源文建为空"); return }
        let docPath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        // 这里的扩展名'.wav'只是标记了文件的打开方式，实际的编码封装格式由assetWriter的fileType决定
        let pcmFilePath = docPath + "/NoGoodbye.mp3.wav"
        DispatchQueue.global().async {
            XWMP3ToPCM.mp3ToPcm(mp3FilePath: mp3FilePath, pcmFilePath: pcmFilePath)
        }
    }
}

