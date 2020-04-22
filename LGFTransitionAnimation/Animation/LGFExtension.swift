//
//  LGFExtension.swift
//  LGFTransitionAnimation
//
//  Created by 樱桃李子 on 2020/4/6.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit
/*
 AnimationStyleNone = 0,
 AnimationStyleCircle,//for present
 AnimationStyleBackScale,//for present
 AnimationStyleErect,//common
 AnimationStyleTilted,//common
 AnimationStyleScale,//for push
 AnimationStyleBack,//for push
 AnimationStyleCube,//for push
 AnimationStyleSuckEffect,//for push
 AnimationStyleOglFlip,//for push
 AnimationStyleRippleEffect,//for push
 AnimationStylePageCurl,//for push
 AnimationStyleCameralIrisHollowOpen,//for push
 AnimationStyleTopBack,//for push

 */

/**转场动画类型*/
public enum AnimationStyle:UInt {
    /**无*/
    case None = 0
    /** present*/
    case Circle
    /** present*/
    case BackScale
    /** common*/
    case Erect
    /** present*/
    case Tilted
    /** push*/
    case Scale
    /** push*/
    case Back
    /** push*/
    case Cube
    /** push*/
    case SuckEffect
    /** push*/
    case OglFlip
    /** push*/
    case RippleEffect
    /** push*/
    case PageCurl
    /** push*/
    case CameralIrisHollowOpen
    /** push*/
    case TopBack
    
    /**转为对应的文字*/
    var string:String {
        var str = "None"
        switch self {
        case .Circle:
            str = "Circle"
        case .BackScale:
            str = "BackScale"
        case .Erect:
            str = "Erect"
        case .Tilted:
             str = "Tilted"
        case .Scale:
            str = "Scale"
        case .Back:
            str = "Back"
        case .Cube:
            str = "Cube"
        case .SuckEffect:
            str = "SuckEffect"
        case .OglFlip:
            str = "OglFlip"
        case .RippleEffect:
            str = "RippleEffect"
        case .PageCurl:
            str = "PageCurl"
        case .CameralIrisHollowOpen:
            str = "CameralIrisHollowOpen"
        case .TopBack:
            str = "opBack:"
        default:
            break
        }
        return str
    }
   
}

var LGF_interactionDelegateKey = "LGF_interactionDelegateKey";
var LGF_transitionDelegateKey  = "LGF_transitionDelegateKey";
var LGF_animationStyleKey      = "LGF_animationStyleKey";
let LGF_SCREEN_WIDTH = UIScreen.main.bounds.width
let LGF_SCREEN_HEIGHT = UIScreen.main.bounds.height


public func isIphonex() -> Bool {
    return max(LGF_SCREEN_WIDTH, LGF_SCREEN_HEIGHT) >= 812
}

/**interaction*/
class VCInteractionDelegate:UIPercentDrivenInteractiveTransition
{
    var animationStyle:AnimationStyle = .None
    
    weak var navigation:UINavigationController?
    weak var delegate:UINavigationControllerDelegate?
    
     var isPop:Bool = false
     var isInteraction:Bool = false
     var isCATransition:Bool = false

    
    private func interactionControllerForAnimationController(navgation:UINavigationController,transitioning:UIViewControllerAnimatedTransitioning)-> UIViewControllerInteractiveTransitioning?{
        return isInteraction ? isPop ? self : nil : nil
    }
    
    
    private func animationControllerForOperation(navigationController:UINavigationController,
                                                 operation:UINavigationController.Operation,
                                                 fromViewController fromVC:UIViewController,
                                                 toViewController toVC:UIViewController)-> UIViewControllerAnimatedTransitioning?
    {
        var objc:UIViewControllerAnimatedTransitioning? = nil
        if operation == .push
        {
            isPop = false
            if toVC.interactionDelegate == nil
            {
                return nil
            }
            switch toVC.interactionDelegate!.animationStyle {
            case .Scale:
                
                objc = AnimationScale.animationOrigin(type: .Begin)
                
            case .Tilted:
                objc = AnimationTilt.animationOrigin(type: .Begin)
            case .Erect:
                objc = AnimationErect.animationIsInteraction(isSure: true, type: .Begin)
            case .Back:
                objc = AnimationBack.animationOrigin(type: .Begin)
            case .Cube,.SuckEffect,.OglFlip,.RippleEffect,.PageCurl,.CameralIrisHollowOpen:
                isCATransition = true
                objc = AnimationTransition.animationStyle(style: toVC.interactionDelegate!.animationStyle, type: .Begin)
                
            case .TopBack:
                objc = AnimationTopBack.animationOrigin(type: .Begin)
            default:
                break
            }
        }
        else if operation == .pop
        {
            isPop = true
            if fromVC.interactionDelegate == nil
            {
                isPop = false
                return nil
            }
            switch fromVC.interactionDelegate!.animationStyle {
            case .Scale:
                
                objc = AnimationScale.animationOrigin(type: .End)
            case .Tilted:
                objc = AnimationTilt.animationOrigin(type: .End)
            case .Erect:
                objc = AnimationErect.animationIsInteraction(type: .End)
            case .Back:
                objc = AnimationBack.animationOrigin(type: .End)
            case .Cube,.SuckEffect,.OglFlip,.RippleEffect,.PageCurl,.CameralIrisHollowOpen:
                isCATransition = true
                objc = AnimationTransition.animationStyle(style: fromVC.interactionDelegate!.animationStyle, type: .End)
                
            case .TopBack:
                objc = AnimationTopBack.animationOrigin(type: .End)
            default:
                isPop = false
                break
            }
        }
        return objc
    }
    
    private func edgePanAction(gesture:UIScreenEdgePanGestureRecognizer){
        let rate = gesture.translation(in: UIApplication.shared.keyWindow).x/LGF_SCREEN_WIDTH
        let velocity = gesture.velocity(in: UIApplication.shared.keyWindow).x
        switch gesture.state {
        case .began:
            isInteraction = true
            navigation?.popViewController(animated: true)
        case .changed:
            isInteraction = false
            update(rate)
        case .ended:
            completionCurve = .easeInOut
            isInteraction = false
            if isCATransition
            {
                finish()
                self.navigation?.delegate = delegate
                return
            }
            if rate >= 0.3
            {
                finish()
               if let firstView = self.navigation?.view.subviews.first,
                firstView.isKind(of: UIImageView.classForCoder())
               {
                firstView.removeFromSuperview()
                }
                self.navigation?.delegate = delegate
            }
            else
            {
                if velocity > 700
                {
                    finish()
                    if let firstView = self.navigation?.view.subviews.first,firstView.isKind(of: UIImageView.classForCoder())
                    {
                        firstView.removeFromSuperview()
                    }
                    self.navigation?.delegate = delegate
                }
                else
                {
                    cancel()
                }
            }
        default:
            isInteraction = false
            cancel()
        }
    }
    
    deinit {
        if delegate != nil
        {
            self.navigation?.delegate = delegate
        }
    }
    
}

extension VCInteractionDelegate:UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if delegate != nil && delegate!.isEqual(self) == false && delegate!.responds(to: #selector(UINavigationControllerDelegate.navigationController(_:willShow:animated:)))
        {
            delegate!.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if delegate != nil && delegate!.isEqual(self) == false && delegate!.responds(to: #selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
        {
            delegate!.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
    }
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        if delegate != nil && delegate!.isEqual(self) == false && delegate!.responds(to: #selector(UINavigationControllerDelegate.navigationControllerSupportedInterfaceOrientations(_:)))
        {
            return delegate!.navigationControllerSupportedInterfaceOrientations!(navigationController)
        }
        return .portrait
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        if delegate != nil && delegate!.isEqual(self) == false && delegate!.responds(to: #selector(UINavigationControllerDelegate.navigationControllerPreferredInterfaceOrientationForPresentation(_:)))
        {
            return delegate!.navigationControllerPreferredInterfaceOrientationForPresentation!(navigationController)
        }
        return .unknown
    }
}


/**transition*/
class VCTransitionDelegate:NSObject
{
    var animationStyle:AnimationStyle = .None
    var  touchPoint:CGPoint = .zero
//    private func animationControllerForPresentedController(presented:UIViewController,presenting:UIViewController,source:UIViewController) -> UIViewControllerAnimatedTransitioning?
//    {
//        var objc:UIViewControllerAnimatedTransitioning? = nil
//        switch presented.animationStyle {
//        case .BackScale:
//            objc = AnimationFade.animationOrigin(type: .Begin)
//        case .Circle:
//            objc = AnimationWave.animationOrigin(originPoint: touchPoint, type: .Begin)
//        case .Erect:
//            objc = AnimationErect.animationIsInteraction(isSure: false, type: .Begin)
//        case .Tilted:
//            objc = AnimationTilt.animationOrigin(type: .Begin)
//        default:
//            break
//        }
//        return objc
//    }
//
//
//    private func animationControllerForDismissedController(dismissed:UIViewController) -> UIViewControllerAnimatedTransitioning?
//    {
//        var objc:UIViewControllerAnimatedTransitioning? = nil
//        switch dismissed.animationStyle {
//        case .BackScale:
//            objc = AnimationFade.animationOrigin(type: .End)
//        case .Circle:
//            objc = AnimationWave.animationOrigin(originPoint: touchPoint, type: .End)
//        case .Erect:
//            objc = AnimationErect.animationIsInteraction(type: .End)
//        case .Tilted:
//            objc = AnimationTilt.animationOrigin(type: .End)
//        default:
//            break
//        }
//        return objc
//    }
}



extension UIViewController{
    
    typealias Completion = () -> Void
    
     var interactionDelegate:VCInteractionDelegate?{
        set{
            objc_setAssociatedObject(self, &LGF_interactionDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &LGF_interactionDelegateKey) as? VCInteractionDelegate
        }
    }
    
    
    private var transitionDelegate:VCTransitionDelegate?{
        set{
            objc_setAssociatedObject(self, &LGF_transitionDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &LGF_transitionDelegateKey) as? VCTransitionDelegate
        }
    }
    
    
    public class func swizzlingMethodOnce(){
        
        DispatchQueue.once(token: "swizzlingMethodOnce") {
            if self != UIViewController.self
            {
                return
            }
            //处理交换方法
            let originalMethod = class_getInstanceMethod(self.classForCoder(), #selector(UIViewController.dismiss(animated:completion:)))
            let swizzledMethod = class_getInstanceMethod(self.classForCoder(), #selector(UIViewController.lgf_dismiss(animated:completion:)))
            let didAddMethod = class_addMethod(self.classForCoder(), #selector(UIViewController.dismiss(animated:completion:)), method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
            if didAddMethod
            {
                class_replaceMethod(self.classForCoder(), #selector(UIViewController.lgf_dismiss(animated:completion:)), method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            }
            else
            {
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
        }
    }
    
    
    func lgf_presentVC(controller:UIViewController,type:AnimationStyle,completion:Completion?)
    {
        lgf_presentVC(controller: controller, type: type, point: .zero, completion: completion)
    }
    
    func lgf_presentCircleVC(controller:UIViewController,point:CGPoint,completion:Completion?)
    {
        lgf_presentVC(controller: controller, type: .Circle, point:point , completion: completion)
    }
  
    
    func  lgf_dismiss(point:CGPoint,completion:Completion?) {
        let transitionDelegate:VCTransitionDelegate? = self.transitionDelegate
        transitionDelegate?.touchPoint = point
        dismiss(animated: true, completion: completion)
    }
    
    /**必须重写的方法 不可以直接使用的*/
   @objc func lgf_transitionAnimationView() -> UIView? {
        return nil
    }
    
    
      private func lgf_presentVC(controller:UIViewController,type:AnimationStyle,point:CGPoint,completion:Completion?)
      {
        self.transitionDelegate = VCTransitionDelegate()
        self.transitionDelegate?.touchPoint = point
        self.transitionDelegate?.animationStyle = type
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = self
        controller.transitionDelegate = self.transitionDelegate
        self.present(controller, animated: true, completion: completion)
      }
      
      
      @objc private func lgf_dismiss(animated:Bool,completion:Completion?)
      {
          if !animated
          {
            self.presentingViewController?.resetInitialInfo()
        }
        lgf_dismiss(animated: animated, completion: completion)
      }
    
    private func resetInitialInfo(){
        if __CGPointEqualToPoint(view.layer.anchorPoint, CGPoint(x: 0.5, y: 0.5))
        {
            return
        }
        view.alpha = 1
        view.layer.transform = CATransform3DIdentity
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.layer.frame = UIScreen.main.bounds
    }
    

}

extension UIViewController:UIViewControllerTransitioningDelegate{
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var objc:UIViewControllerAnimatedTransitioning? = nil
        if presented.transitionDelegate == nil
        {
            return objc
        }
        switch presented.transitionDelegate!.animationStyle {
        case .BackScale:
            objc = AnimationFade.animationOrigin(type: .Begin)
        case .Circle:
            objc = AnimationWave.animationOrigin(originPoint: self.transitionDelegate!.touchPoint, type: .Begin)
        case .Erect:
            objc = AnimationErect.animationIsInteraction(isSure: false, type: .Begin)
        case .Tilted:
            objc = AnimationTilt.animationOrigin(type: .Begin)
        default:
            break
        }
        return objc
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var objc:UIViewControllerAnimatedTransitioning? = nil
        if dismissed.transitionDelegate == nil
        {
            return objc
        }
        switch dismissed.transitionDelegate!.animationStyle {
        case .BackScale:
            objc = AnimationFade.animationOrigin(type: .End)
        case .Circle:
            objc = AnimationWave.animationOrigin(originPoint: self.transitionDelegate!.touchPoint, type: .End)
        case .Erect:
            objc = AnimationErect.animationIsInteraction(type: .End)
        case .Tilted:
            objc = AnimationTilt.animationOrigin(type: .End)
        default:
            break
        }
        return objc
    }
}


extension UINavigationController{
    
    func lgf_pushViewController(viewController:UIViewController,style:AnimationStyle)
    {
        let interaction = VCInteractionDelegate()
        interaction.navigation = self
//        interaction.delegate = self.delegate
        interaction.animationStyle = style
        viewController.interactionDelegate = interaction
        let edgePan = UIScreenEdgePanGestureRecognizer(target: viewController, action: #selector(UIViewController.edgePanAction(gesture:)))
        edgePan.edges = .left
//        viewController.view.addGestureRecognizer(edgePan)
        self.delegate = viewController
        pushViewController(viewController, animated: true)
    }
    
}

extension UIViewController:UINavigationControllerDelegate{
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var objc:UIViewControllerAnimatedTransitioning? = nil
        if operation == .push
        {
            interactionDelegate?.isPop = false
            if toVC.interactionDelegate == nil
            {
                return nil
            }
            switch toVC.interactionDelegate!.animationStyle {
            case .Scale:
                
                objc = AnimationScale.animationOrigin(type: .Begin)
                
            case .Tilted:
                objc = AnimationTilt.animationOrigin(type: .Begin)
            case .Erect:
                objc = AnimationErect.animationIsInteraction(isSure: true, type: .Begin)
            case .Back:
                objc = AnimationBack.animationOrigin(type: .Begin)
            case .Cube,.SuckEffect,.OglFlip,.RippleEffect,.PageCurl,.CameralIrisHollowOpen:
                interactionDelegate?.isCATransition = true
                objc = AnimationTransition.animationStyle(style: toVC.interactionDelegate!.animationStyle, type: .Begin)
                
            case .TopBack:
                objc = AnimationTopBack.animationOrigin(type: .Begin)
            default:
                break
            }
        }
        else if operation == .pop
        {
            interactionDelegate?.isPop = true
            if fromVC.interactionDelegate == nil
            {
                interactionDelegate?.isPop = false
                return nil
            }
            switch fromVC.interactionDelegate!.animationStyle {
            case .Scale:
                
                objc = AnimationScale.animationOrigin(type: .End)
            case .Tilted:
                objc = AnimationTilt.animationOrigin(type: .End)
            case .Erect:
                objc = AnimationErect.animationIsInteraction(type: .End)
            case .Back:
                objc = AnimationBack.animationOrigin(type: .End)
            case .Cube,.SuckEffect,.OglFlip,.RippleEffect,.PageCurl,.CameralIrisHollowOpen:
                interactionDelegate?.isCATransition = true
                objc = AnimationTransition.animationStyle(style: fromVC.interactionDelegate!.animationStyle, type: .End)
                
            case .TopBack:
                objc = AnimationTopBack.animationOrigin(type: .End)
            default:
                interactionDelegate?.isPop = false
                break
            }
        }
        return objc
    }
    
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactionDelegate?.isInteraction == false
        {
            return nil
        }
        var objc:UIViewControllerAnimatedTransitioning? = nil
        if interactionDelegate?.isPop == false
        {
            switch interactionDelegate!.animationStyle {
            case .Scale:
                
                objc = AnimationScale.animationOrigin(type: .Begin)
                
            case .Tilted:
                objc = AnimationTilt.animationOrigin(type: .Begin)
            case .Erect:
                objc = AnimationErect.animationIsInteraction(isSure: true, type: .Begin)
            case .Back:
                objc = AnimationBack.animationOrigin(type: .Begin)
            case .Cube,.SuckEffect,.OglFlip,.RippleEffect,.PageCurl,.CameralIrisHollowOpen:
                interactionDelegate?.isCATransition = true
                objc = AnimationTransition.animationStyle(style: interactionDelegate!.animationStyle, type: .Begin)
                
            case .TopBack:
                objc = AnimationTopBack.animationOrigin(type: .Begin)
            default:
                break
            }
        }
        else
        {
            if interactionDelegate == nil
            {
                interactionDelegate?.isPop = false
                return nil
            }
            switch interactionDelegate!.animationStyle {
            case .Scale:
                
                objc = AnimationScale.animationOrigin(type: .End)
            case .Tilted:
                objc = AnimationTilt.animationOrigin(type: .End)
            case .Erect:
                objc = AnimationErect.animationIsInteraction(type: .End)
            case .Back:
                objc = AnimationBack.animationOrigin(type: .End)
            case .Cube,.SuckEffect,.OglFlip,.RippleEffect,.PageCurl,.CameralIrisHollowOpen:
                interactionDelegate?.isCATransition = true
                objc = AnimationTransition.animationStyle(style: interactionDelegate!.animationStyle, type: .End)
                
            case .TopBack:
                objc = AnimationTopBack.animationOrigin(type: .End)
            default:
                interactionDelegate?.isPop = false
                break
            }
        }
        return objc as? UIViewControllerInteractiveTransitioning
    }
    
    
    @objc func edgePanAction(gesture:UIScreenEdgePanGestureRecognizer){
        let rate = gesture.translation(in: UIApplication.shared.keyWindow).x/LGF_SCREEN_WIDTH
        let velocity = gesture.velocity(in: UIApplication.shared.keyWindow).x
        switch gesture.state {
        case .began:
            interactionDelegate!.isInteraction = true
            interactionDelegate!.navigation?.popViewController(animated: true)
        case .changed:
            interactionDelegate!.isInteraction = false
            interactionDelegate!.update(rate)
        case .ended:
            interactionDelegate!.completionCurve = .easeInOut
            interactionDelegate!.isInteraction = false
            if interactionDelegate!.isCATransition
            {
                interactionDelegate!.finish()
                interactionDelegate!.navigation?.delegate = interactionDelegate?.delegate
                return
            }
            if rate >= 0.3
            {
                interactionDelegate!.finish()
                if let firstView = interactionDelegate?.navigation?.view.subviews.first,
                firstView.isKind(of: UIImageView.classForCoder())
               {
                firstView.removeFromSuperview()
                }
                interactionDelegate!.navigation?.delegate = interactionDelegate?.delegate
            }
            else
            {
                if velocity > 700
                {
                    interactionDelegate!.finish()
                    if let firstView = interactionDelegate?.navigation?.view.subviews.first,firstView.isKind(of: UIImageView.classForCoder())
                    {
                        firstView.removeFromSuperview()
                    }
                    interactionDelegate!.navigation?.delegate = interactionDelegate?.delegate
                }
                else
                {
                    interactionDelegate!.cancel()
                }
            }
        default:
            interactionDelegate!.isInteraction = false
            interactionDelegate!.cancel()
        }
    }
    
    
    
}


extension DispatchQueue{
    private static var onceToken = [String]()
    class func once(token:String,block:(()->())) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        if onceToken.contains(token)
        {return}
        onceToken.append(token)
        block()
    }
    
}

