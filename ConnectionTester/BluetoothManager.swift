//
//  BluetoothManager.swift
//  ConnectionTester
//
//  Created by Jay Tucker on 12/4/17.
//  Copyright © 2017 Imprivata. All rights reserved.
//

import Foundation
import CoreBluetooth

final class BluetoothManager: NSObject {
    
    private let serviceUUID                  = CBUUID(string: "16884184-C1C4-4BD1-A8F1-6ADCB272B18B")
    private let readCharacteristicUUID       = CBUUID(string: "0246FAC2-1145-409B-88C4-F43D4E05A8C5")
    private let subscribedCharacteristicUUID = CBUUID(string: "2031019E-0380-4F27-8B12-E572858FE928")

    private let timeoutInSecs = 5.0
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic!
    
    private var isPoweredOn = false
    private var scanTimer: Timer!
    private var isBusy = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate:self, queue:nil)
    }
    
    func go() {
        log("go")
        guard isPoweredOn else {
            log("not powered on")
            return
        }
        guard !isBusy else {
            log("busy, ignoring request")
            return
        }
        isBusy = true
        startScanForPeripheral(serviceUuid: serviceUUID)
    }
    
    private func startScanForPeripheral(serviceUuid: CBUUID) {
        log("startScanForPeripheral")
        centralManager.stopScan()
        scanTimer = Timer.scheduledTimer(timeInterval: timeoutInSecs, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
        centralManager.scanForPeripherals(withServices: [serviceUuid], options: nil)
    }
    
    // can't be private because called by timer
    @objc func timeout() {
        log("timed out")
        centralManager.stopScan()
        isBusy = false
    }
    
    private func disconnect() {
        log("disconnect")
        centralManager.cancelPeripheralConnection(peripheral)
        peripheral = nil
        characteristic = nil
        isBusy = false
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var caseString: String!
        switch central.state {
        case .unknown:
            caseString = "unknown"
        case .resetting:
            caseString = "resetting"
        case .unsupported:
            caseString = "unsupported"
        case .unauthorized:
            caseString = "unauthorized"
        case .poweredOff:
            caseString = "poweredOff"
        case .poweredOn:
            caseString = "poweredOn"
        }
        log("centralManagerDidUpdateState \(caseString!)")
        isPoweredOn = centralManager.state == .poweredOn
        if isPoweredOn {
            go()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        log("centralManager didDiscoverPeripheral")
        scanTimer.invalidate()
        centralManager.stopScan()
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("centralManager didConnectPeripheral")
        self.peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let message = "peripheral didDiscoverServices " + (error == nil ? "ok" :  ("error " + error!.localizedDescription))
        log(message)
        guard error == nil else { return }
        for service in peripheral.services! {
            log("service \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let message = "peripheral didDiscoverCharacteristicsFor service " + (error == nil ? "\(service.uuid) ok" :  ("error " + error!.localizedDescription))
        log(message)
        guard error == nil else { return }
        for characteristic in service.characteristics! {
            log("characteristic \(characteristic.uuid)")
            if characteristic.uuid == readCharacteristicUUID {
                log("found readCharacteristicUUID")
                self.characteristic = characteristic
                peripheral.readValue(for: characteristic)
            } else if characteristic.uuid == subscribedCharacteristicUUID {
                log("found subscribedCharacteristicUUID")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let message = "peripheral didUpdateValueFor characteristic " + (error == nil ? "\(characteristic.uuid) ok" :  ("error " + error!.localizedDescription))
        log(message)
        defer {
            disconnect()
        }
        guard error == nil else { return }
        let response = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
        log("\(response)")
    }
    
}
