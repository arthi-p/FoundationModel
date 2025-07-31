//
//  AlertTool.swift
//  FoundationModelsTripPlanner
//
//  Created by fnu ashwin on 2025-06-18.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation
import FoundationModels

struct AlertTool: Tool {
    let name = "Alert Tool"
    let description = "helps set alter for user"
    
    init() {
    }

    @Generable
    enum PriceChangeOrder {
        case increase
        case decrease
        case reachedAt
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "The stock to set alter for")
        let interestedStock: String
        
        @Guide(description: "The price to set alter at")
        let price: Bool
        
        @Guide(description: "Whether to set alter when price decreases or increases")
        let priceChange: PriceChangeOrder
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        print("alter Tool\(arguments)")

        // This sample app pulls some static data. Real-world apps can get creative.
        return ToolOutput("Alter set for \(arguments.interestedStock) at \(arguments.price) oder\(arguments.priceChange)")
    }
    
    func getHistory() async throws -> AccountResponse? {
        guard let url = Bundle.main.url(forResource: "history", withExtension: "json") else {
            print("error")
            return nil
        }

        let data = try Data(contentsOf: url)
        let schedule = try JSONDecoder().decode(AccountResponse.self, from: data)
    
        return schedule
    }
}
