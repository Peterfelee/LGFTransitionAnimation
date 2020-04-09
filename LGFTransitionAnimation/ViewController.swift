//
//  ViewController.swift
//  LGFTransitionAnimation
//
//  Created by 樱桃李子 on 2020/4/6.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var touchPoint:CGPoint = .zero
    private var currentButton:UIButton?
    private let buttons:[AnimationStyle] = [.None,.Circle,.BackScale,.Erect,.Tilted,.Scale,.Back,.Cube,.SuckEffect,.OglFlip,.RippleEffect,.PageCurl,.CameralIrisHollowOpen,.TopBack]
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        buttons.enumerated().forEach { (index,type) in
            let temp = createButton(title: type.string, tag: UInt(index + 1))
            view.addSubview(temp)
            temp.frame = CGRect(origin: CGPoint(x: LGF_SCREEN_WIDTH/2 - 50, y: CGFloat(index) * 60 + 45), size: CGSize(width: 100, height: 50))
        }
        // Do any additional setup after loading the view.
        touchPoint = CGPoint(x: LGF_SCREEN_WIDTH/2, y: 80)
    }

    private func createButton(title:String,tag:UInt) -> UIButton{
        let temp = UIButton(type: .custom)
        temp.layer.cornerRadius = 15
        temp.setTitle(title, for: UIControl.State.normal)
        temp.setTitleColor(.white, for: .normal)
        temp.backgroundColor = .darkGray
        temp.tag = Int(tag)
        temp.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        return temp
    }
    
    @objc private func buttonClick(btn:UIButton)
    {
        currentButton = btn
        let vc = CircleViewController()
        if btn.tag > 5
        {
            navigationController?.lgf_pushViewController(viewController: vc, style: AnimationStyle(rawValue: UInt(btn.tag - 1))!)
        }
        else
        {
            vc.isNeedShow = true
            vc.modalPresentationStyle = .custom
            lgf_presentVC(controller: vc, type: AnimationStyle(rawValue: UInt(btn.tag - 1))!, completion: nil)
        }
    }
    
    override func lgf_transitionAnimationView() -> UIView? {
        return currentButton
    }
}

