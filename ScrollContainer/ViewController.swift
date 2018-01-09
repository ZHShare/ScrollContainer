//
//  ViewController.swift
//  ScrollContainer
//
//  Created by YE on 2018/1/9.
//  Copyright © 2018年 Eter. All rights reserved.
//

import UIKit

class ViewController: ScrollContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let arr = ["红色": .red,"蓝色": .blue,"黄色": .yellow, "紫色": .purple,"黑色": .black,"白色": UIColor.white]
        viewControllers = arr.map { (title, color) -> UIViewController in
            let vc = UIViewController()
            vc.view.backgroundColor = color
            vc.title = title
            return vc
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController: ScrollContainerDelegate
{
    func didShowViewController(at index: Int) {
        print(index)
    }
}

