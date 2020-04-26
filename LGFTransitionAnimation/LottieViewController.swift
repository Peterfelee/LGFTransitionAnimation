//
//  InteractionViewController.swift
//  LGFTransitionAnimation
//
//  Created by peterlee on 2020/4/8.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit
import Lottie

class LottieViewController: UIViewController {
    var lottieView:AnimationView!
    let json = ["menu","spraying","star","trackingapp","wordpress"]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let path = Bundle.main.path(forResource: json.randomElement()!, ofType: "json")
        lottieView = AnimationView(filePath: path!)
        view.addSubview(lottieView)
        lottieView.frame = view.bounds
        lottieView.loopMode = .repeatBackwards(5)
        lottieView.play {[weak self] (sucess) in
            self?.navigationController?.popViewController(animated: true)
        }
        // Do any additional setup after loading the view.
    }

    
    deinit {
        lottieView.stop()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let path = Bundle.main.path(forResource: "menu.json", ofType: nil)
        let activity = UIActivityViewController(activityItems: [path as Any], applicationActivities: nil)
        self.present(activity, animated: true) {
            
        }
    }
}
