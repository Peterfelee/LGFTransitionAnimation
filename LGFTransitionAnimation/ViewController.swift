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
    private var currentView:LGFSlideCell?
    private let buttons:[AnimationStyle] = [.None,.Circle,.BackScale,.Erect,.Tilted,.Scale,.Back,.Cube,.SuckEffect,.OglFlip,.RippleEffect,.PageCurl,.CameralIrisHollowOpen,.TopBack]
    
    private var tableView:UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        tableView = UITableView(frame:UIScreen.main.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LGFSlideCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(LGFSlideCell.classForCoder()))

        tableView.rowHeight = 80
        view.addSubview(tableView)
        
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
        return temp
    }

    
    override func lgf_transitionAnimationView() -> UIView? {
        return currentView
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:LGFSlideCell? = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LGFSlideCell.classForCoder())) as? LGFSlideCell
        if cell == nil{
            cell = LGFSlideCell(style: .default, reuseIdentifier: NSStringFromClass(LGFSlideCell.classForCoder()))
        }
         let temp:AnimationStyle = buttons[indexPath.row]
        cell?.title.text = temp.string
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CircleViewController()
        currentView = tableView.cellForRow(at: indexPath) as? LGFSlideCell
        if indexPath.row > 4
        {
            navigationController?.lgf_pushViewController(viewController: SlideViewController(), style: AnimationStyle(rawValue: UInt(indexPath.row))!)
        }
        else
        {
            vc.isNeedShow = true
            vc.modalPresentationStyle = .custom
            lgf_presentVC(controller: vc, type: AnimationStyle(rawValue: UInt(indexPath.row))!, completion: nil)
        }
    }
    
}


class LGFSlideCell:LGFBaseSlideCell{
    
    private let marginX:CGFloat = 30
    private let marginY:CGFloat = 0
    private let titleHeight:CGFloat = 44
    
    var title:UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        title = UILabel()
        contentView.addSubview(title)
        addButton(title: "new", image: nil) { (btn) in
            
        }
        addButton(title: "old", image: nil) { (btn) in
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        title.setX(x: marginX)
        title.setY(y: frame.height/2 -  titleHeight/2)
        title.setWidth(width: LGF_SCREEN_WIDTH - marginX * 2)
        title.setHeight(height: titleHeight)
    }
    
}

extension UIView{
    
    func setX(x:CGFloat){
        var frame =  self.frame
        frame.origin.x = x
        self.frame = frame
    }
    
    func setY(y:CGFloat){
        var frame =  self.frame
        frame.origin.y = y
        self.frame = frame
    }
    
    func setWidth(width:CGFloat){
        var frame =  self.frame
        frame.size.width = width
        self.frame = frame
    }
    
    func setHeight(height:CGFloat){
        var frame =  self.frame
        frame.size.height = height
        self.frame = frame
    }
    
}

