//
//  ImageDetailViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 7/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var imageName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpImageView()
        
    }
    
    func setUpImageView() {
        guard let name = imageName else { return }
        
        if let image = UIImage(named: name) {
            imageView.image = image
        }
    }

}
