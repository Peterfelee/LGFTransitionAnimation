//
//  LGFBaseSlideCell.swift
//  LGFTransitionAnimation
//
//  Created by peterlee on 2020/4/17.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit

class LGFBaseSlideCell: UITableViewCell {
    
    /**默认的按钮的宽度 ，可修改 */
    var LGF_ButtonMargin:CGFloat = 50{
        didSet
        {
            setNeedsLayout()
        }
    }
   
    private var LGF_slideView:UIView?
    private var originalLGF_slideViewX:CGFloat = 0
    
    /**弹性长度*/
    private var bounceDistance:CGFloat = 50
    
    
    /**按钮的事件*/
    private var action:((UIButton)->())?
    
    private var tempTableView:UITableView?
    
    /**总共的按钮的长度*/
    private var LGF_totalButtonWidth:CGFloat = 0
    
    private var isShow:Bool = false
    {
        didSet{
            if self.isShow
            {
                tableView.LGF_showCellIndexPath = self.indexPath.row
            }
        }
    }
    
    private lazy var LGF_containerView:UIView = {
        let temp = UIView()
        temp.frame = CGRect(x: 0, y: 0, width: LGF_SCREEN_WIDTH, height: 50)
        return temp
    }()
    
    private var slideX:CGFloat = 0 {
        didSet{
            if self.slideX == 0
            {
                return
            }
            if self.slideX > 0
            {
                hidden(animation: true)
                return
            }
            LGF_containerView.setX(x: self.slideX)
            if LGF_containerView.frame.maxX > originalLGF_slideViewX
            {
                LGF_slideView?.setX(x: LGF_SCREEN_WIDTH)
            }
            else
            {
                LGF_slideView?.setX(x: originalLGF_slideViewX + self.slideX)
            }
        }
    }
    
    private var tableView:UITableView {
        if tempTableView != nil
        {
            return tempTableView!
        }
        tempTableView = UITableView()
        if let view = self.superview
        {
            if view.isKind(of: UITableView.classForCoder())
            {
                tempTableView = view as? UITableView
            }
            else if (view.superview?.isKind(of: UITableView.classForCoder()))!
            {
                tempTableView = view.superview as? UITableView
            }
        }
        return tempTableView!
    }
    private var indexPath:IndexPath{
        return tableView.indexPathsForRows(in: self.frame)?.last ?? IndexPath(row: 0, section: 0)
    }
    override var contentView: UIView{
        return LGF_containerView
    }

    private var hasGesture:Bool = false
    {
        didSet{
            if self.hasGesture
            {
                let tap = UITapGestureRecognizer(target: self, action: #selector(gestureClick(gesture:)))
                tap.delegate = self
                addGestureRecognizer(tap)
                
                let pan = UIPanGestureRecognizer(target: self, action: #selector(gestureClick(gesture:)))
                pan.delegate = self
                addGestureRecognizer(pan)
            }
        }
    }
    
    //MARK:method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.removeFromSuperview()
        addSubview(LGF_containerView)

        LGF_slideView = UIView()
        LGF_slideView?.backgroundColor = .blue
        originalLGF_slideViewX = LGF_SCREEN_WIDTH
        insertSubview(LGF_slideView!, at: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if self.indexPath.row == tableView.LGF_showCellIndexPath
        {
            isShow = true
            LGF_containerView.setX(x: -LGF_totalButtonWidth - bounceDistance)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (LGF_slideView?.subviews.count)! <= 0 || CGSize.zero.equalTo((LGF_slideView?.frame.size)!) == false
        {
            
        }
        else
        {
            let temp = LGF_slideView!.subviews.count
            LGF_slideView?.frame = CGRect(x: LGF_SCREEN_WIDTH, y: 0, width: LGF_ButtonMargin * CGFloat(temp) + bounceDistance, height: bounds.height)
            LGF_containerView.frame = self.bounds

            LGF_slideView!.subviews.enumerated().forEach { (index,view) in
                view.frame = CGRect(x:LGF_ButtonMargin * CGFloat(temp - 1 - index), y: 0, width: LGF_ButtonMargin , height: frame.height)                
            }
        }
        
        if self.indexPath.row == tableView.LGF_showCellIndexPath
        {
            isShow = true
            slideX = -LGF_totalButtonWidth
        }
    }
    
   
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture:UIPanGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,abs(gesture.velocity(in: self).x) > abs(gesture.velocity(in: self).y)
        {
            if isShow == false
            {
                tableView.LGF_hiddenAllCell()
            }
            return true
        }
        else if gestureRecognizer.isKind(of: UITapGestureRecognizer.classForCoder())
        {
            if isShow
            {
                return isShow
            }
            
            tableView.LGF_hiddenAllCell()
            return false
        }
        return false
    }
}

//MARK:private method
extension LGFBaseSlideCell{
    @objc private func buttonClick(btn:UIButton){
        if action != nil
        {
            action!(btn)
        }
    }
    
    @objc private func gestureClick(gesture:UIGestureRecognizer){
        
        if let temp:UIPanGestureRecognizer =  gesture as? UIPanGestureRecognizer
        {
            if gesture.state == .began
            {
                if isShow
                {
                    slideX = 0
                    temp.setTranslation(CGPoint(x: -LGF_totalButtonWidth, y: 0), in: self)
                }
                else
                {
                    slideX = 0
                    temp.setTranslation(.zero, in: self)
                }
            }
            else if gesture.state == .changed
            {
//                if temp.translation(in: self).x < -LGF_totalButtonWidth - bounceDistance
//                {
//                    slideX = -LGF_totalButtonWidth - bounceDistance
//                }
//                else
//                {
                    if temp.translation(in: self).x > -LGF_totalButtonWidth//正常移动的
                    {
                        slideX = temp.translation(in: self).x
                    }
                    else//弹性的难拉
                    {
                        var distance = -LGF_totalButtonWidth - temp.translation(in: self).x
                        if distance > bounceDistance
                        {
                            distance = bounceDistance
                        }
                        print("distance----\(distance)")
                        let a = 1.0/(8 * bounceDistance)
                        let realDistance =  distance - a * 0.5 * distance * distance
                        slideX = -LGF_totalButtonWidth - realDistance //sqrt(distance)
                        print("sqrt----\(realDistance)")
                    }
//                }
            }
            else if gesture.state == .ended
            {
                
                if slideX < -50
                {
                    slideX = -LGF_totalButtonWidth
                    isShow = true
                }
                else
                {
                    slideX = 0
                    hidden(animation: true)
                }
            }
        }
        else if gesture.isKind(of: UITapGestureRecognizer.classForCoder())
        {
            if isShow
            {
                hidden(animation: true)
            }
        }
        
    }
}

//MARK:public method
extension LGFBaseSlideCell{
    /**添加按钮*/
    func addButton(title:String?,image:String?,action:@escaping((UIButton)->())){
        LGF_totalButtonWidth += LGF_ButtonMargin
        if !hasGesture
        {
            hasGesture = true
        }
        let button = UIButton(frame: .zero)
        button.setTitle(title, for: .normal)
        if let imageStr = image, let temp = UIImage(named: imageStr)
        {
            button.setImage(temp, for: .normal)
        }
        button.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        self.action = action
        button.backgroundColor = [UIColor.gray,UIColor.purple].randomElement()
        LGF_slideView?.addSubview(button)
    }
    
    func hidden(animation:Bool = false)
    {
        if animation
        {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.LGF_containerView.setX(x: 0)
                self.LGF_slideView?.setX(x: self.originalLGF_slideViewX)
            }) { (finish) in
                
            }
        }
        else
        {
            LGF_containerView.setX(x: 0)
            LGF_slideView?.setX(x: originalLGF_slideViewX)
        }
        isShow = false
    }
}




extension UITableView{
    private struct LGF_UITableView {
        static var showIndexPathKey:String = "LGFShowIndexPath"
    }
    
    var LGF_showCellIndexPath:Int?{
        set{
            if self.LGF_showCellIndexPath != nil && newValue != self.LGF_showCellIndexPath
            {
                LGF_hiddenCellForIndex(index: self.LGF_showCellIndexPath!)
            }
            objc_setAssociatedObject(self, &LGF_UITableView.showIndexPathKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get{
            return  objc_getAssociatedObject(self, &LGF_UITableView.showIndexPathKey) as? Int
        }
    }
    
    func LGF_hiddenAllCell(){
        if self.LGF_showCellIndexPath != nil
        {
            LGF_hiddenCellForIndex(index: self.LGF_showCellIndexPath!)
            LGF_showCellIndexPath = nil
        }
    }
    
    
    private func LGF_hiddenCellForIndex(index:Int){
        if let cell:LGFBaseSlideCell = self.cellForRow(at: IndexPath(row: index, section: 0)) as? LGFBaseSlideCell
        {
            cell.hidden(animation: true)
        }
    }
}

