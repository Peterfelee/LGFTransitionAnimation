//
//  CircleViewController.swift
//  LGFTransitionAnimation
//
//  Created by 樱桃李子 on 2020/4/6.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit

class CircleViewController: UIViewController {
    
    /**默认是push用的子控制器*/
    var isNeedShow:Bool = false
    
    private var titleLabel:UILabel!
    private var alertLabel:UILabel!
    private var thirdButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1)
        
        titleLabel = UILabel()
        titleLabel.text = "Touch Any Point To Dismiss"
        titleLabel.textColor = UIColor.lightGray
        view.addSubview(titleLabel)
        
        alertLabel = UILabel()
        alertLabel.text = "可侧滑查看效果"
        alertLabel.textColor = UIColor.darkGray
        view.addSubview(alertLabel)
        
        
        thirdButton = UIButton(type: .custom)
        thirdButton.setTitle("destroy", for: .normal)
        thirdButton.setTitleColor(.blue, for: .normal)
        view.addSubview(thirdButton)
        thirdButton.addTarget(self, action: #selector(thirdButtonClick(btn:)), for: .touchUpInside)
        
        if isNeedShow
        {
            titleLabel.isHidden = false
            alertLabel.isHidden = true
        }
        // Do any additional setup after loading the view.
        
        titleLabel.frame =  CGRect(origin: CGPoint(x: 50, y: 50), size: CGSize(width: 100, height: 50))
        alertLabel.frame = CGRect(origin: CGPoint(x: 50, y: 150), size: CGSize(width: 100, height: 50))
        
        thirdButton.frame = CGRect(origin: CGPoint(x: 50, y:200), size: CGSize(width: 100, height: 50))
        
        
    }
    
    @objc private func thirdButtonClick(btn:UIButton)
    {
        
//        self.navigationController?.lgf_pushViewController(viewController: CircleViewController(), style: .Tilted)
        
        if (presentingViewController != nil)
        {
            dismiss(animated: true, completion: nil)
        }
        else
        {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        lgf_dismiss(point: (touch?.location(in: view))!, completion: nil)
    }
    
    deinit {
        print(NSStringFromClass(self.classForCoder))
    }
    
    override func lgf_transitionAnimationView() -> UIView? {
        return thirdButton
    }
}
