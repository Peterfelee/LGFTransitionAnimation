//
//  AnimationOfTransititon.swift
//  LGFTransitionAnimation
//
//  Created by 樱桃李子 on 2020/4/6.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit


class LGFBaseAnimation:NSObject,UIViewControllerAnimatedTransitioning,UIViewControllerInteractiveTransitioning{
   
    enum AnimationType:NSInteger {
        case Begin
        case End
    }
    
    var  animationDuration:TimeInterval = 0.25
    fileprivate var type:AnimationType = .Begin
    
    
    public class func animationOrigin(originPoint:CGPoint = .zero,type:AnimationType) -> LGFBaseAnimation
    {
        let temp = LGFBaseAnimation()
        temp.type = type
        return temp
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return  animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    }
        
    /**交互的手势动画的执行逻辑*/
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
    }
}


class QuadrantRecognise:NSObject{
    enum QuadrantStyle:UInt {
        case None
        case First
        case Second
        case Third
        case Fourth
    }
    
    class func  recogniseWithPoint(touchPoint:CGPoint) -> CGFloat {
        var style = QuadrantStyle.None
        if touchPoint.x >= LGF_SCREEN_WIDTH/2
        {
            if touchPoint.y >= LGF_SCREEN_HEIGHT/2
            {
                style = .Fourth
            }
            else
            {
                style = .First
            }
        }
        else
        {
            if touchPoint.y >= LGF_SCREEN_HEIGHT/2
            {
                style = .Third
            }
            else
            {
                style = .Second
            }
        }
        
        var radius:CGFloat = 0
        switch style {
        case .First:
            radius = sqrt(touchPoint.x * touchPoint.x + (LGF_SCREEN_HEIGHT - touchPoint.y) * (LGF_SCREEN_HEIGHT - touchPoint.y))
        case .Second:
            radius = sqrt((LGF_SCREEN_WIDTH - touchPoint.x) * (LGF_SCREEN_WIDTH -  touchPoint.x) + (LGF_SCREEN_HEIGHT - touchPoint.y) * (LGF_SCREEN_HEIGHT - touchPoint.y))
        case .Third:
            radius = sqrt((LGF_SCREEN_WIDTH - touchPoint.x) * (LGF_SCREEN_WIDTH -  touchPoint.x) + touchPoint.y *  touchPoint.y)
        case .Fourth:
            radius = sqrt(touchPoint.x * touchPoint.x + touchPoint.y *  touchPoint.y)

        default:
            break
        }
        
        return radius
    }
}


class AnimationWave:LGFBaseAnimation,CAAnimationDelegate{
    
    private var originPoint:CGPoint = .zero
    private var transitionContext:UIViewControllerContextTransitioning?
   
    override class func animationOrigin(originPoint: CGPoint,type:AnimationType) -> AnimationWave {
        let waveBegin = AnimationWave()
        waveBegin.originPoint = originPoint
        waveBegin.type = type
        return waveBegin
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        let viewControllerKey:UITransitionContextViewControllerKey = ( type == AnimationType.End ? UITransitionContextViewControllerKey.from: UITransitionContextViewControllerKey.to)
            if let VC  = transitionContext.viewController(forKey: viewControllerKey)
            {
                VC.view.frame = UIScreen.main.bounds
                transitionContext.containerView.addSubview(VC.view)
                
                let initPath = UIBezierPath(ovalIn: CGRect(origin: originPoint, size: .zero))
                let radius = QuadrantRecognise.recogniseWithPoint(touchPoint: originPoint)
                let finalPath = UIBezierPath(ovalIn: CGRect.init(origin: originPoint, size: .zero).insetBy(dx: -radius, dy: -radius))
                
                let maskLayer = CAShapeLayer()
                if type == .End
                {
                    maskLayer.path = initPath.cgPath
                }
                else
                {
                    maskLayer.path = finalPath.cgPath
                }
                VC.view.layer.mask = maskLayer
                
                let basicAnim = CABasicAnimation(keyPath: "path")
                basicAnim.fromValue = (type == .End ? finalPath.cgPath : initPath.cgPath)
                basicAnim.toValue = ( type == .End ? initPath.cgPath : finalPath.cgPath)
                basicAnim.delegate = self
                basicAnim.duration = transitionDuration(using: transitionContext)
                maskLayer.add(basicAnim, forKey: "path")
            }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        flag ? transitionContext?.completeTransition(!transitionContext!.transitionWasCancelled) : nil
    }
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
           return 0.3
       }
       
}



class AnimationFade:LGFBaseAnimation,CAAnimationDelegate{
    
    override class func animationOrigin(originPoint: CGPoint = .zero, type: LGFBaseAnimation.AnimationType) -> AnimationFade {
        let temp = AnimationFade()
        temp.type = type
        return temp
    }
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if type == .Begin
        {
            if let toVC = transitionContext.viewController(forKey: .to),let fromVC = transitionContext.viewController(forKey: .from)
            {
                toVC.view.frame = UIScreen.main.bounds
                transitionContext.containerView.addSubview(toVC.view)
                toVC.view.layer.zPosition = CGFloat(MAXFLOAT)
                
                fromVC.view.layer.zPosition = -1
                fromVC.view.layer.frame = CGRect(x: 0, y: LGF_SCREEN_HEIGHT/2, width: LGF_SCREEN_WIDTH, height: LGF_SCREEN_HEIGHT)
                fromVC.view.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
                
                var rotate = CATransform3DIdentity
                rotate.m34 = -1.0/1000
                rotate = CATransform3DRotate(rotate, CGFloat(isIphonex() ? 4:3) * CGFloat(Double.pi/180), 1, 0, 0)
                var scale = CATransform3DIdentity
                scale = CATransform3DScale(scale, isIphonex() ? 0.94:0.95, isIphonex() ? 0.96:0.97, 1)
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    fromVC.view.layer.transform = rotate
                    fromVC.view.alpha = 0.6
                }) { (finished) in
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                        fromVC.view.alpha = 0.5
                        fromVC.view.layer.transform = scale
                    }) { (finish) in
                        transitionContext.completeTransition(true)
                    }
                }
                
            }
        }
        else
        {
            if let toVC = transitionContext.viewController(forKey: .to)
            {
                var rotate = CATransform3DIdentity
                rotate.m34 = -1.0/1000
                rotate = CATransform3DRotate(rotate, 4.0 * CGFloat(Double.pi/180), 1, 0, 0)
                if isIphonex()
                {
                    rotate = CATransform3DTranslate(rotate, 0, -5, 0)
                }
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    toVC.view.layer.transform = rotate
                    toVC.view.alpha = 0.6
                }) { (finish) in
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                        toVC.view.alpha = 1
                        toVC.view.layer.transform = CATransform3DIdentity
                    }) { (finish) in
                        toVC.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                        toVC.view.layer.frame = UIScreen.main.bounds
                        transitionContext.completeTransition(true)
                    }
                }
            }
        }
    }
}

class AnimationErect:LGFBaseAnimation{
    
    private var isInteraction:Bool = false
    
    /** 如果是开始的动画 isSure 一定要传h值 end动画就可以忽略了*/
    class func animationIsInteraction(isSure:Bool = false,type:AnimationType) -> AnimationErect
    {
        let eract = AnimationErect()
        eract.isInteraction = isSure
        eract.type = type
        return eract
    }
    
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if type == .Begin
        {
            if let toView = transitionContext.view(forKey: .to)
            {
                transitionContext.containerView.addSubview(toView)
                toView.frame = transitionContext.containerView.bounds
                toView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
                toView.layer.position = CGPoint(x: toView.frame.width, y: toView.frame.height/2)
                
                if isInteraction == false
                {
                    var identity = CATransform3DIdentity
                    identity.m34 = -1.0/500
                    let rotate = CATransform3DRotate(identity, CGFloat(Double.pi/3), 0, 1, 0)
                    toView.layer.transform = rotate
                }
                
                UIView.animate(withDuration: 0.3, animations: {
                    if self.isInteraction == false
                    {
                        toView.layer.transform = CATransform3DIdentity
                    }
                    toView.layer.position = CGPoint(x: 0, y: toView.frame.height/2)
                }) { (finish) in
                    toView.layer.transform = CATransform3DIdentity
                    toView.layer.position = CGPoint(x: toView.frame.width/2, y: toView.frame.height/2)
                    toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
        }
        else
        {
            if let fromView = transitionContext.view(forKey: .from),
                let snapShot = fromView.snapshotView(afterScreenUpdates: false)

            {
                if let toView = transitionContext.view(forKey: .to)
                {
                    transitionContext.containerView.addSubview(toView)
                }
                transitionContext.containerView.addSubview(snapShot)
                
                snapShot.frame = transitionContext.containerView.bounds
                snapShot.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
                snapShot.layer.position = CGPoint(x: 0, y: snapShot.frame.height/2)
                
                var rotate = CATransform3DRotate(CATransform3DIdentity, -CGFloat(Double.pi/2), 0, 1, 0)
                rotate.m34 = -1.0/500
                fromView.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    snapShot.layer.position = CGPoint(x: snapShot.frame.width, y: snapShot.frame.height/2)
                    snapShot.layer.transform = rotate
                }) { (finish) in
                    fromView.isHidden = false
                    snapShot.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//                    transitionContext.containerView.addSubview(toView)
                }
            }
        }
    }
}


class AnimationScale:LGFBaseAnimation{
    
    override class func animationOrigin(originPoint: CGPoint = .zero, type: LGFBaseAnimation.AnimationType) -> AnimationScale {
           let temp = AnimationScale()
           temp.type = type
           return temp
       }
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromVC = transitionContext.viewController(forKey: .from),let toVC = transitionContext.viewController(forKey: .to)
        {
            //TODO:finger
            if responseToSel(array: [fromVC,toVC]) == false
            {
                transitionContext.completeTransition(true)
                return
            }
            let containerViewColor = transitionContext.containerView.backgroundColor
            transitionContext.containerView.backgroundColor = .white
            transitionContext.containerView.addSubview(toVC.view)
            
            let fromView = fromVC.view
            let toView = toVC.view
            if type == .End
            {
                toView?.frame = transitionContext.containerView.bounds
            }
            let sourceView = fromVC.lgf_transitionAnimationView()
            let destinationView = toVC.lgf_transitionAnimationView()
            if sourceView == nil || destinationView == nil
            {
                transitionContext.completeTransition(true)
                return
            }
            
            let sourcePoint:CGPoint = sourceView!.convert(.zero, to: nil)
            let destinationPoint:CGPoint = destinationView!.convert(.zero, to: nil)
            
            let snapShot:UIView = sourceView!.snapshotView(afterScreenUpdates: true)!
            transitionContext.containerView.addSubview(snapShot)
            snapShot.frame.origin = sourcePoint
            
            let originFrame = (type == .End ? toView?.frame:fromView?.frame)
            
            
            let heightScale = destinationView!.frame.height/sourceView!.frame.height
            let widthScale = destinationView!.frame.width/sourceView!.frame.width
            
            if type == .End
            {
                let originalHeightScale = sourceView!.frame.height/destinationView!.frame.height
                let originalWidthScale = sourceView!.frame.width/destinationView!.frame.width
                toView?.transform = CGAffineTransform.init(scaleX: originalWidthScale, y: originalHeightScale)
                toView?.frame.origin = CGPoint(x: (sourcePoint.x
                - destinationPoint.x)*originalWidthScale, y: (sourcePoint.y - destinationPoint.y)*originalHeightScale)
                toView?.alpha = 0
                fromView?.isHidden = true
                destinationView?.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    snapShot.transform = CGAffineTransform.init(scaleX: widthScale, y: heightScale)
                    snapShot.frame.origin = destinationPoint
                    toView?.alpha = 1
                    toView?.transform = CGAffineTransform.identity
                    toView?.frame = originFrame!
                    
                }) { (finish) in
                    transitionContext.containerView.backgroundColor = containerViewColor
                    fromView?.isHidden = false
                    destinationView?.isHidden = false
                    snapShot.removeFromSuperview()
                    toView?.transform = CGAffineTransform.identity
                    toView?.alpha = 1
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    
                }
                
            }
            else
            {
                toView?.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    snapShot.transform = CGAffineTransform.init(scaleX: widthScale, y: heightScale)
                    snapShot.frame.origin = destinationPoint
                    fromView?.alpha = 0
                    fromView?.transform = snapShot.transform
                    fromView?.frame.origin = CGPoint(x: (destinationPoint.x
                        - sourcePoint.x)*widthScale, y: (destinationPoint.y - sourcePoint.y)*heightScale)
                }) { (finish) in
                    transitionContext.containerView.backgroundColor = containerViewColor
                    snapShot.removeFromSuperview()
                    toView?.isHidden = false
                    fromView?.alpha = 1
                    fromView?.transform = CGAffineTransform.identity
                    fromView?.frame = originFrame!
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
                
            }
            
        }
        
        
        
        
    }
    
    private func responseToSel(array:[UIViewController]) -> Bool
    {
        if array.count > 0
        {
            for viewController in array {
                if viewController.responds(to: #selector(UIViewController.lgf_transitionAnimationView)) == false
                {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    
}

class AnimationTilt:LGFBaseAnimation{
  
    override class func animationOrigin(originPoint: CGPoint = .zero, type: LGFBaseAnimation.AnimationType) -> AnimationTilt {
           let temp = AnimationTilt()
           temp.type = type
           return temp
       }
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            if type == .End
            {
                if let fromView = transitionContext.view(forKey: .from),let snapShot = fromView.snapshotView(afterScreenUpdates: false)
                {
                    if let toView = transitionContext.view(forKey: .to)
                    {
                transitionContext.containerView.addSubview(toView)
                    }
                transitionContext.containerView.addSubview(snapShot)
                snapShot.frame = transitionContext.containerView.bounds
                snapShot.layer.anchorPoint = CGPoint(x: 0.5, y: 1.5)
                snapShot.layer.position = CGPoint(x: snapShot.bounds.width/2, y: snapShot.bounds.height * 1.5)
                snapShot.transform = .identity
                fromView.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    snapShot.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/4))
                }) { (finish) in
                    fromView.isHidden = false
                    snapShot.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
                }
            }
            else
            {
                if let toView = transitionContext.view(forKey: .to)
                {
                    toView.frame = transitionContext.containerView.bounds
                    toView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.5)
                    toView.layer.position = CGPoint(x: toView.bounds.width/2, y: toView.bounds.height * 1.5)
                    transitionContext.containerView.addSubview(toView)
                    toView.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/4))
                    UIView.animate(withDuration: 0.3, animations: {
                        toView.transform = CGAffineTransform.identity
                    }) { (finish) in
                        toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                        toView.layer.position = CGPoint(x: toView.bounds.width/2, y: toView.bounds.height/2)
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    }
                }
            }
    }
}


class AnimationBack:LGFBaseAnimation{
    
    override class func animationOrigin(originPoint: CGPoint = .zero, type: LGFBaseAnimation.AnimationType) -> AnimationBack {
           let temp = AnimationBack()
           temp.type = type
           return temp
       }
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toView = transitionContext.view(forKey: .to),let fromView = transitionContext.view(forKey: .from)
        {
            toView.frame = transitionContext.containerView.bounds
            transitionContext.containerView.addSubview(toView)
            
            if type == .End
            {
                
                transitionContext.containerView.addSubview(fromView)
                toView.transform = CGAffineTransform.init(scaleX: 0.93, y: 0.93)
                let origin = fromView.frame
                UIView.animate(withDuration: 0.3, animations: {
                    fromView.frame.origin.x = fromView.frame.width
                    toView.transform = .identity
                }) { (finish) in
                    fromView.frame = origin
                    toView.transform = .identity
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
                
            }
            else
            {
                
                toView.frame.origin.x = toView.frame.width
                UIView.animate(withDuration: 0.3, animations: {
                    toView.frame.origin.x = 0
                    fromView.transform = CGAffineTransform.init(scaleX: 0.93, y: 0.93)
                }) { (finish) in
                    toView.frame.origin.x = 0
                    fromView.transform = CGAffineTransform.identity
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
            
        }
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if let toView = transitionContext.view(forKey: .to),let fromView = transitionContext.view(forKey: .from)
        {
            toView.frame = transitionContext.containerView.bounds
            transitionContext.containerView.addSubview(toView)
            
            if type == .End
            {
                let speed = (self as UIViewControllerInteractiveTransitioning).completionSpeed
                print(speed as Any)
//                transitionContext.containerView.addSubview(fromView)
//                let origin = fromView.frame
//                fromView.frame.origin.x = fromView.frame.width
//
//                UIView.animate(withDuration: 0.3, animations: {
//                    fromView.frame.origin.x = fromView.frame.width
//                    toView.transform = .identity
//                }) { (finish) in
//                    fromView.frame = origin
//                    toView.transform = .identity
//                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//                }
                
            }
            else
            {
                
                toView.frame.origin.x = toView.frame.width
                UIView.animate(withDuration: 0.3, animations: {
                    toView.frame.origin.x = 0
                    fromView.transform = CGAffineTransform.init(scaleX: 0.93, y: 0.93)
                }) { (finish) in
                    toView.frame.origin.x = 0
                    fromView.transform = CGAffineTransform.identity
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
            
        }
    }
}


class AnimationTopBackImageView:UIImageView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configInitialInfo()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configInitialInfo(){
        let image = captureCurrentPicture()
        let coverView = UIView()
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        coverView.frame = UIScreen.main.bounds
        addSubview(coverView)
        self.image = image
    }
    
    
    private func captureCurrentPicture() -> UIImage{
        let topWindow = UIApplication.shared.keyWindow
        let rect = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        topWindow?.drawHierarchy(in: rect, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
}



class AnimationTopBack:LGFBaseAnimation{
    
    override class func animationOrigin(originPoint: CGPoint = .zero, type: LGFBaseAnimation.AnimationType) -> AnimationTopBack {
           let temp = AnimationTopBack()
           temp.type = type
           return temp
       }
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromVC = transitionContext.viewController(forKey: .from),let navVC = fromVC.navigationController,let fromView = transitionContext.view(forKey: .from),let toView = transitionContext.view(forKey: .to)
        {
            if type == .Begin
            {
                if let firstView = navVC.view.subviews.first
                {
                    if firstView.isKind(of: AnimationTopBackImageView.self)
                    {
                        firstView.removeFromSuperview()
                    }
                    
                    let tempImageView:AnimationTopBackImageView = AnimationTopBackImageView(frame: .zero)
                    tempImageView.frame = UIScreen.main.bounds
                    navVC.view.insertSubview(tempImageView, at: 0)
                    if isIphonex()
                    {
                        tempImageView.transform = CGAffineTransform.init(scaleX: 0.92, y: 0.9)
                    }
                    else
                    {
                        tempImageView.transform = CGAffineTransform.init(scaleX: 0.92, y: 0.94)
                    }
                    
                    toView.frame = UIScreen.main.bounds
                    transitionContext.containerView.addSubview(toView)
                    toView.frame.origin.y = UIScreen.main.bounds.height
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        toView.frame.origin.y = 0
                        if isIphonex()
                        {
                            fromView.transform = CGAffineTransform.init(scaleX: 0.92, y: 0.9)
                        }
                        else
                        {
                            fromView.transform = CGAffineTransform.init(scaleX: 0.92, y: 0.94)
                        }
                    }) { (finish) in
                        toView.frame.origin.y = 0
                        fromView.transform = .identity
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    }
                }
            }
            else
            {
             
                fromView.frame = UIScreen.main.bounds
                toView.frame = UIScreen.main.bounds
                transitionContext.containerView.addSubview(toView)
                transitionContext.containerView.bringSubviewToFront(fromView)
                if isIphonex()
                {
                    toView.transform = CGAffineTransform.init(scaleX: 0.92, y: 0.9)
                }
                else
                {
                    toView.transform = CGAffineTransform.init(scaleX: 0.92, y: 0.94)
                }
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    fromView.frame = UIScreen.main.bounds
                    fromView.frame.origin.y = UIScreen.main.bounds.height
                    toView.transform = .identity
                }) { (finish) in                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    toView.transform = .identity
                    fromView.frame = UIScreen.main.bounds
                    fromView.frame.origin.y = 0

                }
            }
        }
    }
}

class AnimationTransition:LGFBaseAnimation,CAAnimationDelegate{
    
    private var transitionContext:UIViewControllerContextTransitioning?
    private var style:AnimationStyle!
    class func animationStyle(style:AnimationStyle,type:AnimationType) -> AnimationTransition{
        let animation = AnimationTransition()
        animation.style = style
        animation.type = type
        return animation
    }
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toView = transitionContext.view(forKey: .to)
        {
            toView.frame = UIScreen.main.bounds
            transitionContext.containerView.addSubview(toView)
            self.transitionContext = transitionContext
            let animation = CATransition()
            animation.delegate = self
            animation.duration = transitionDuration(using: transitionContext)
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            switch style {
            case .Cube:
                animation.type = CATransitionType(rawValue: "cube")
                animation.subtype = (type == AnimationType.End ? .fromLeft : .fromRight)
            case .SuckEffect:
                animation.type = CATransitionType(rawValue: "suckEffect")
            case .OglFlip:
                animation.type = CATransitionType(rawValue: "oglFlip")
                animation.subtype = (type == AnimationType.End ? .fromRight:.fromLeft)
            case .RippleEffect:
                animation.type = CATransitionType(rawValue: "rippleEffect")
            case .PageCurl:
                animation.type = CATransitionType(rawValue: (type == AnimationType.End ? "pageCurl":"pageUnCurl"))
                animation.subtype = .fromLeft
            case .CameralIrisHollowOpen:
                animation.type = CATransitionType(rawValue: "cameralIrisHollowOpen")
                if type == .Begin
                {
                    animation.subtype = .fromLeft
                }
            default:
                break
            }
            
            transitionContext.containerView.layer.add(animation, forKey: "aniamtionTransition")
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        flag ?  transitionContext?.completeTransition(!transitionContext!.transitionWasCancelled):nil
    }
}
