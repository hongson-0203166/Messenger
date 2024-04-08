//
//  TabbarViewController.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 24/03/2024.
//

import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let vc1 = UINavigationController(rootViewController: MessengeViewController())
        let vc2 = UINavigationController(rootViewController: ProfileViewController())
        
        // Thiết lập tên và icon cho từng tab bar item
        vc1.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message"), selectedImage: UIImage(systemName: "message.fill"))
        vc2.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        setViewControllers([vc1,vc2], animated: true)
    }
}
