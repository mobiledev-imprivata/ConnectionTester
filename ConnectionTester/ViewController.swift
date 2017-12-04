//
//  ViewController.swift
//  ConnectionTester
//
//  Created by Jay Tucker on 12/4/17.
//  Copyright © 2017 Imprivata. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var bluetoothManager: BluetoothManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        bluetoothManager = BluetoothManager()
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.bluetoothManager.go()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

