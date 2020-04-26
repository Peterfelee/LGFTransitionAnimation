//
//  MainViewController.swift
//  LGFTransitionAnimation
//
//  Created by peterlee on 2020/4/26.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.navigationController?.navigationBar.isHidden = true
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func transitionViewController(_ sender: UIButton) {
        self.navigationController?.pushViewController(TransitionViewController(), animated: true)
    }
    
    @IBAction func slideViewController(_ sender: Any) {
        self.navigationController?.pushViewController(SlideCellViewController(), animated: true)
    }
    @IBAction func lottieViewController(_ sender: Any) {
        self.navigationController?.pushViewController(LottieViewController(), animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
