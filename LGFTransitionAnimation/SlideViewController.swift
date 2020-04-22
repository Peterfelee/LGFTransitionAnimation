//
//  SlideViewController.swift
//  LGFTransitionAnimation
//
//  Created by peterlee on 2020/4/22.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit

/**中间停留时顶部距离*/
let headerViewTop:CGFloat = 248

/**底部停留时底部距离*/
let headerViewBottom:CGFloat = 68

/**弹性间距*/
let headerViewBounce:CGFloat =  150

/**顶部的view滑动时传递的代理*/
protocol SheetScrollDelegate:AnyObject {
    func sheetDidScroll(viewController:UIViewController,didScrollTo contentOffset: CGPoint)
}

//MARK:主要承载页面
class MainView:UIView
{
    /**顶部滑动的view*/
    private var topView:UIView!
    /**底部滑动的view*/
    private var bottomView:UIView!
    
    private weak var controller:UIViewController!
    
    init(bottomView:UIView,topView:UIView, controller:UIViewController)
    {
        super.init(frame: .zero)
        self.bottomView = bottomView
        self.topView = topView
        self.controller = controller
        
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: LGF_SCREEN_WIDTH, height: 100*50), byRoundingCorners: [UIRectCorner.topLeft,UIRectCorner.topRight], cornerRadii: CGSize(width: 28, height: 28)).cgPath
        topView.layer.mask = shape
        addSubview(bottomView)
        addSubview(topView)
        
        
        
        bottomView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        bottomView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        
        topView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        topView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        topView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

//        bottomView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//
//        topView.snp.makeConstraints { (make) in
//            make.top.equalTo(0)
//            make.left.right.bottom.equalTo(0)
//        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let temp:UITableView = topView as? UITableView , point.y + temp.contentOffset.y + 60 > 0
        {
//            if (!controller.customNavgationBar.isHidden && controller.customNavgationBar.bounds.size.height + LEStatusHeight() > point.y) {
//                return controller.customNavgationBar.hitTest(controller.customNavgationBar.convert(point, from: self), with: event)
//            } else {
                return topView.hitTest(topView.convert(point, from: self), with: event)
//            }
            
        }
        return bottomView.hitTest(bottomView.convert(point, from: self), with: event)
    }
}

/**首页*/
class SlideViewController:UIViewController {

    let cellIdentifier:String = "LEAnniversaryCell"
    let maxVisibleContentHeight = headerViewTop
    var sheetDelegate:SheetScrollDelegate?
        
    private var bottomVC:BottomViewController!
    
    
    init() {
       super.init(nibName: nil, bundle: nil)
       self.bottomVC = BottomViewController()
       addChild(self.bottomVC)
    }

    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }


    override func loadView() {
        let mainView = MainView(bottomView: self.bottomVC.view, topView: tableView, controller: self)
       view = mainView
    }

    lazy private var tableView:UITableView = {
        let temp = UITableView(frame: .zero, style: .grouped)
        temp.rowHeight = 50
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = .white
        temp.separatorStyle = .none
        temp.showsVerticalScrollIndicator = false
        temp.contentInset = UIEdgeInsets(top: maxVisibleContentHeight, left: 0, bottom: 38, right: 0)
        return temp
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        bottomVC.didMove(toParent: self)
        view.backgroundColor = UIColor.white
        configDatas()
        configViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sheetDelegate?.sheetDidScroll(viewController: self, didScrollTo: tableView.contentOffset)

    }

    private func configViews(){
        tableView.frame = CGRect(x: 0, y: 20, width: LGF_SCREEN_WIDTH, height: LGF_SCREEN_HEIGHT - 20)
    }




    private func configDatas() {
    }
}

//MARK:tableView的代理事件
extension SlideViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 33
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil
        {
            cell = UITableViewCell()
        }
        cell?.textLabel?.text = "tableViewCell"
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerViewBottom
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .brown
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
            UIView.animate(withDuration: 0.25) {
                cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }
        }
    }
}

//MARK:处理滚动到指定高度后导航栏出现
extension SlideViewController:UIScrollViewDelegate{
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let contentOffsetY:CGFloat = scrollView.contentOffset.y
//        let contentInsetTop = maxVisibleContentHeight
//        let bottomInsetHeight = LGF_SCREEN_HEIGHT - headerViewBottom
//        if contentOffsetY > -contentInsetTop
//        {
//            if  contentOffsetY > -contentInsetTop && contentOffsetY < 0
//            {
//                scrollView.contentInset = UIEdgeInsets(top: -contentOffsetY, left: 0, bottom: headerViewBottom, right: 0)
//            }
//            else
//            {
//                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: headerViewBottom, right: 0)
//            }
//        }
//        else if contentOffsetY > -bottomInsetHeight
//        {
//            scrollView.contentInset = UIEdgeInsets(top: -contentOffsetY, left: 0, bottom: headerViewBottom, right: 0)
//        }
//    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.y
        let contentoffsetY:CGFloat = scrollView.contentOffset.y
        let pulledUpOffset: CGFloat = 0
        let pulledDownOffset: CGFloat = -maxVisibleContentHeight
        
        if ((-LGF_SCREEN_HEIGHT  + headerViewBottom)...pulledUpOffset).contains(targetOffset) {
            if velocity.y < 0 {//向下滑动
                if pulledDownOffset - contentoffsetY > 0
                {
                    scrollView.contentInset = UIEdgeInsets(top: UIScreen.main.bounds.height-headerViewBottom, left: 0, bottom: 0, right: 0)
                    targetContentOffset.pointee.y =  -UIScreen.main.bounds.height + headerViewBottom
                    
                }
                else if pulledDownOffset - contentoffsetY > -headerViewBounce
                {//在中间的弹性区间
                    scrollView.contentInset = UIEdgeInsets(top: maxVisibleContentHeight, left: 0, bottom: 0, right: 0)

                    targetContentOffset.pointee.y = pulledDownOffset
                }
                else
                {//顶部区域的弹性区间
                    scrollView.contentInset = UIEdgeInsets(top: maxVisibleContentHeight, left: 0, bottom: 0, right: 0)
                    targetContentOffset.pointee.y = pulledUpOffset
                }

            } else {//向上滑动
                if(pulledDownOffset - contentoffsetY > 0)//在中间那个弹性区域以下
                {
                    scrollView.contentInset = UIEdgeInsets(top: maxVisibleContentHeight, left: 0, bottom: 0, right: 0)
                    targetContentOffset.pointee.y = pulledDownOffset
                }
                else//在中间弹性区域以上
                {
                    if (pulledDownOffset - contentoffsetY > -headerViewBounce)
                    {
                        scrollView.contentInset = UIEdgeInsets(top: maxVisibleContentHeight, left: 0, bottom: 0, right: 0)
                        targetContentOffset.pointee.y = pulledDownOffset
                    }
                    else
                    {
                        scrollView.contentInset = UIEdgeInsets(top: maxVisibleContentHeight, left: 0, bottom: 0, right: 0)
                        targetContentOffset.pointee.y = pulledUpOffset
                    }
                }
            }
        }
        else{
            if targetOffset > 0
            {
                if targetOffset > LGF_SCREEN_HEIGHT
                {
                    return
                }
                scrollView.contentInset = UIEdgeInsets(top: maxVisibleContentHeight, left: 0, bottom: 0, right: 0)
                targetContentOffset.pointee.y =  pulledUpOffset
                return
            }
                scrollView.contentInset = UIEdgeInsets(top: UIScreen.main.bounds.height-headerViewBottom, left: 0, bottom: 0, right: 0)
                targetContentOffset.pointee.y =  -UIScreen.main.bounds.height + headerViewBottom
        }
    }
    
}


//MARK:底部的控制器 填充自己想要数据主要在这里
class BottomViewController:UIViewController{
    
    override func viewDidLoad() {
        view.backgroundColor = .lightGray
        let label = UILabel()
        label.text = "label"
        label.textAlignment = .center
        view.addSubview(label)
        label.frame = CGRect(x: 0, y: 15, width: LGF_SCREEN_WIDTH, height: 60)
        
        
        let button = UIButton(type: .custom)
        button.setTitle("back", for: .normal)
        view.addSubview(button)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(closeButton), for: .touchUpInside)
        button.frame = CGRect(x: 15, y: 15, width: 60, height: 60)

    }
    
    @objc private func closeButton(){
        if self.navigationController != nil
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}
