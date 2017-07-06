//
//  DetailViewController.swift
//  PlannerPlus
//
//  Created by jackson on 7/4/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var projectNavigationItem: UINavigationItem!
    @IBOutlet weak var projectInfo: UITextView!
    

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let textView = projectInfo, detail.projectInfo != nil
            {
                textView.text = detail.projectInfo
            }
            if let navigationItem = projectNavigationItem, detail.name != nil
            {
                navigationItem.title = detail.name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        detailItem!.projectInfo = projectInfo.text
        
        (UIApplication.shared.delegate as! AppDelegate).syncEngine?.addToLocalChanges(withUUID: detailItem!.uuid!, withChangeType: .update)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Project? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

