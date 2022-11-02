//
//  NetworkServices.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 24/10/2022.
//

import Foundation
import Network


protocol NetworkServicesDelegate{
    
    func didUpdateNetwork(connected: Bool)
}

struct NetworkServices{
    
    let monitor = NWPathMonitor()
    var delegate: NetworkServicesDelegate?
    
    func startMonitoring(){
        
        monitor.pathUpdateHandler = { path in
            if path.status != .unsatisfied{
                
                delegate?.didUpdateNetwork(connected: true)
                
            }else if path.status != .satisfied{
                
                delegate?.didUpdateNetwork(connected: false)
                
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}


