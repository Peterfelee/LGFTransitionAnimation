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
//        view.addSubview(lottieView)
        lottieView.frame = view.bounds
        lottieView.loopMode = .repeatBackwards(5)
        lottieView.play {[weak self] (sucess) in
            self?.navigationController?.popViewController(animated: true)
        }
        // Do any additional setup after loading the view.
    }

    
    deinit {
//        lottieView.stop()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var radius = LGF_SCREEN_HEIGHT/2
        while radius > 0 {
            radius -= 7.5
        }
        
        view.layer.addSublayer(addCirlPath(lineWidth: 5, radius: LGF_SCREEN_WIDTH/2, strokeColor: UIColor.red.cgColor, finishAnimation: {[weak self] in
            self?.view.layer.addSublayer(self!.addCirlPath(lineWidth: 5, radius: LGF_SCREEN_WIDTH/2 - 7.5, strokeColor: UIColor.blue.cgColor, finishAnimation: {
                self?.view.layer.addSublayer(self!.addCirlPath(lineWidth: 5, radius: LGF_SCREEN_WIDTH/2 - 15, strokeColor: UIColor.brown.cgColor, finishAnimation: {
                    self?.view.layer.addSublayer(self!.addCirlPath(lineWidth: 5, radius: LGF_SCREEN_WIDTH/2 - 22.5, strokeColor: UIColor.green.cgColor, finishAnimation: {
                        self?.view.layer.addSublayer(self!.addCirlPath(lineWidth: 5, radius: LGF_SCREEN_WIDTH/2 - 30, strokeColor: UIColor.red.cgColor, finishAnimation: {
                            self?.view.layer.addSublayer(self!.addCirlPath(lineWidth: 5, radius: LGF_SCREEN_WIDTH/2 - 37.5, strokeColor: UIColor.blue.cgColor, finishAnimation: {
                                self?.view.layer.addSublayer(self!.addCirlPath(lineWidth: 5, radius: LGF_SCREEN_WIDTH/2 - 45, strokeColor: UIColor.green.cgColor, finishAnimation: {
                                    
                                }))

                            }))

                        }))

                    }))

                }))

            }))
        }))
        






    }
    
    private func addCirlPath(lineWidth:CGFloat,radius:CGFloat,strokeColor:CGColor,finishAnimation:(()->())?) -> CAShapeLayer {
        let path = UIBezierPath(arcCenter: CGPoint(x: LGF_SCREEN_WIDTH/2, y: LGF_SCREEN_HEIGHT/2), radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        let animation = LGFKeyFrameAnimation(keyPath: "strokeEnd") {
            if finishAnimation != nil
            {
                DispatchQueue.main.async {
                    finishAnimation!()
                }
            }
        }//CAKeyframeAnimation(keyPath: "strokeEnd")
        animation.values = [0,1]
        animation.duration = 3
        animation.isRemovedOnCompletion = false
        let shap = CAShapeLayer()
        shap.frame = view.bounds
        shap.strokeColor = strokeColor
        shap.fillColor = UIColor.gray.cgColor
        shap.path = path.cgPath
        shap.lineWidth = lineWidth
        shap.add(animation, forKey: "shap_\(radius)Animation")
        shap.strokeStart = 0
        return shap
    }

}


class LGFKeyFrameAnimation:CAKeyframeAnimation,CAAnimationDelegate{
    
    private var completion:(()->())?
    
    init(keyPath:String,completion:(()->())?) {
        super.init()
        self.completion = completion
        self.keyPath = keyPath
        self.delegate = self
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if completion != nil{
            completion!()}
    }
    
    
    
    
}
