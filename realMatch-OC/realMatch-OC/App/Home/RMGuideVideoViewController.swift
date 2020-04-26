//
//  RMGuideVideoViewController.swift
//  realMatch-OC
//
//  Created by xulei on 2020/4/26.
//  Copyright © 2020 qingting. All rights reserved.
//

import UIKit

class RMGuideVideoViewController: UIViewController, RouterController {
    required init!(routerParams params: [AnyHashable : Any]!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    func displayStyle() -> DisplayStyle {
        return .push
    }
    
    func animation() -> Bool {
        return true
    }
    
    required init!(command adopter: RouterAdopter!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func shootNow(_ sender: Any) {
        Router.shared()?.router(to: "RMRealVideoViewController", parameter: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
