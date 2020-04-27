//
//  OthersViewController.swift
//  LGFTransitionAnimation
//
//  Created by peterlee on 2020/4/27.
//  Copyright © 2020 peterlee. All rights reserved.
//

import UIKit

class OthersViewController: UIViewController {
    var imageView:UIImageView!
    var anotherImageView:UIImageView!
    var componotImageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: LGF_SCREEN_WIDTH/2, height: LGF_SCREEN_WIDTH/2))
        view.addSubview(imageView)
        
        anotherImageView = UIImageView(frame: CGRect(x: 0, y: LGF_SCREEN_HEIGHT - LGF_SCREEN_WIDTH, width: LGF_SCREEN_WIDTH/2, height: LGF_SCREEN_WIDTH/2))
        view.addSubview(anotherImageView)
        
        
        componotImageView = UIImageView(frame: CGRect(x: LGF_SCREEN_WIDTH/2, y: LGF_SCREEN_WIDTH/2 , width: LGF_SCREEN_WIDTH/2, height: LGF_SCREEN_WIDTH/2))
        view.addSubview(componotImageView)

        // Do any additional setup after loading the view.
    }
    
    
    private func requestData(imagePath:String,completion:((Data)->())?)
    {
        let url = URL(string: imagePath)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if completion != nil && data != nil
            {
                completion!(data!)
            }
        }
        task.resume()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            test()
    }
}


extension OthersViewController{
    private func test(){
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        print("\(Date())")
        let path1 = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1587977870314&di=a2d7a335ef22af478652beae53fa26d9&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20170912%2F39db4a8dc9034393abdefc7d42cc4b1b.jpeg"
        let path2 = "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3438413553,834879777&fm=26&gp=0.jpg"
        self.requestData(imagePath: path1) { (data) in
            if let image = UIImage(data: data)
            {
                DispatchQueue.main.async {
                    self.imageView.image = image
                    group.leave()
                }
            }
            print("queue1 wakeup\(Date())")
        }
        group.enter()
        self.requestData(imagePath: path2) { (data) in
            if let image = UIImage(data: data)
            {
                DispatchQueue.main.async {
                    self.anotherImageView.image = image
                    group.leave()
                }
            }
            print("queue2 wakeup\(Date())")
        }
        group.enter()
        
        
        //
        //        queue.async(group: group, execute: DispatchWorkItem(block: {
        //            self.requestData(imagePath: path1) { (data) in
        //                if let image = UIImage(data: data)
        //                {
        //                    DispatchQueue.main.async {
        //                        self.imageView.image = image
        //                    }
        //                }
        //                print("queue1 wakeup\(Date())")
        //            }
        //        }))
        //
        //        queue.async(group: group, execute: DispatchWorkItem(block: {
        //            self.requestData(imagePath: path2) { (data) in
        //                if let image = UIImage(data: data)
        //                {
        //                    DispatchQueue.main.async {
        //                        self.anotherImageView.image = image
        //                    }
        //                }
        //                print("queue2 wakeup\(Date())")
        //            }
        //
        //        }))
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                self.componotImageView.image = UIImage.drawImage(onePart: self.imageView.image!, twoPart: self.anotherImageView.image!)
            }
            print("all queue wakeup\(Date())")
            
        }
        
    }
}

extension UIImage{
    
   class func drawImage(onePart:UIImage,twoPart:UIImage) -> UIImage
   {
    let size = CGSize(width: min(onePart.size.width, twoPart.size.width), height: min(onePart.size.height, twoPart.size.height))
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    onePart.draw(at: .zero, blendMode: .normal, alpha: 1)
    twoPart.draw(at: .zero, blendMode: .normal, alpha: 0.1)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image ?? UIImage()
    }
}
