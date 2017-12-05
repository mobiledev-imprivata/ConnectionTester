//
//  ViewController.swift
//  ConnectionTester
//
//  Created by Jay Tucker on 12/4/17.
//  Copyright © 2017 Imprivata. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var connectionLabel: UILabel!
    
    private var bluetoothManager: BluetoothManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        bluetoothManager = BluetoothManager()
        bluetoothManager.delegate = self
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [unowned self] _ in
            self.connectionLabel.text = "Searching..."
            self.connectionLabel.textColor = .orange
            self.bluetoothManager.go()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: BluetoothManagerDelegate {
    
    func didConnect() {
        log(#function)
        connectionLabel.text = "Connected"
        connectionLabel.textColor = .green
    }
    
    func didDisconnect() {
        log(#function)
        connectionLabel.text = "Disconnected"
        connectionLabel.textColor = .purple
    }
    
    func didTimeout() {
        log(#function)
        connectionLabel.text = "Timed out"
        connectionLabel.textColor = .red
    }

}

