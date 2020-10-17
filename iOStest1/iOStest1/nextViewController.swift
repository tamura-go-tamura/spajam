//
//  nextViewController.swift
//  iOStest1
//
//  Created by scsendai-000 on 2020/10/17.
//

import UIKit

class nextViewController: UIViewController {
    
    var testtext:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var y:Int  = 100
        
        var testlabel:UILabel = UILabel(frame: CGRect(x: 30, y: y, width: Int(self.view.bounds.width), height: 50))
        
        testlabel.text = testtext
        
        self.view.addSubview(testlabel)
        
        
        
    
        // Do any additional setup after loading the view.
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
