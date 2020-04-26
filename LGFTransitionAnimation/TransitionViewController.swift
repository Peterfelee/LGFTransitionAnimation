//
//  TransitionViewController.swift
//  LGFTransitionAnimation
//
//  Created by peterlee on 2020/4/26.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit
import SwipeCellKit

class TransitionViewController: UIViewController {
    private var touchPoint:CGPoint = .zero
    private var currentView:LGFSlideCell?
    private let buttons:[AnimationStyle] = [.None,.Circle,.BackScale,.Erect,.Tilted,.Scale,.Back,.Cube,.SuckEffect,.OglFlip,.RippleEffect,.PageCurl,.CameralIrisHollowOpen,.TopBack]
    
    private var tableView:UITableView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        tableView = UITableView(frame:UIScreen.main.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransitionCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(TransitionCell.classForCoder()))

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

extension TransitionViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:TransitionCell? = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TransitionCell.classForCoder())) as? TransitionCell
        if cell == nil{
            cell = TransitionCell(style: .default, reuseIdentifier: NSStringFromClass(TransitionCell.classForCoder()))
        }
         let temp:AnimationStyle = buttons[indexPath.row]
        cell?.textLabel!.text = temp.string
        cell?.delegate = self
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

extension TransitionViewController:SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        let eidt = SwipeAction(style: .default, title: "Edit") { (action, indexPath) in
            
        }
        
        let delete = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
        }
        if orientation == .right
        {
            return [eidt,delete]
        }
        return nil
    }
    
    
}


class TransitionCell:SwipeTableViewCell{
    
}
