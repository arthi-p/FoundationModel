//
//  GainLossIntent.swift
//  FoundationModelsTripPlanner
//
//  Created by fnu ashwin on 2025-06-17.
//  Copyright © 2025 Apple. All rights reserved.
//

import AppIntents
import Foundation
import FoundationModels

struct HistoryTool: Tool {
    let name = "History Tool"
    let description = "gives user's trsaction hisotry."
    
    init() {
    }

    @Generable
    struct Arguments {
        @Guide(description: "The stock detail user is looking for")
        let interestedStock: String
        
        @Guide(description: "Does require all history")
        let allHistory: Bool
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        print("History Tool\(arguments)")

        // This sample app pulls some static data. Real-world apps can get creative.
        let data = try await getHistory()!
        if !arguments.interestedStock.isEmpty {
            let filteredData = data.data.transactions.filter({ $0.shortDescription.localizedCaseInsensitiveContains(arguments.interestedStock)})
            return ToolOutput(filteredData.generatedContent)
        }
        else{
            if arguments.allHistory == true {
                print("All Data")
            }
            return ToolOutput(data.generatedContent)
        }
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
struct GainLossTool: Tool {
    let name = "Gain Loss Tool"
    let description = "gives user's stock gain loss data."
    
    init() {
    }


    @Generable
    struct Arguments {
        @Guide(description: "The stock detail user is looking for")
        let interestedStock: String
       
    }
    func call(arguments: Arguments) async throws -> ToolOutput {
        print("GainLoss Tool\(arguments)")
        // This sample app pulls some static data. Real-world apps can get creative.
        let data = try await perform1()!
        if !arguments.interestedStock.isEmpty {
            let filteredData = data.data.accounts[0].equityPositions?.positions
                .filter { $0.asset.shortName.localizedCaseInsensitiveContains(arguments.interestedStock)           }
            return ToolOutput(filteredData.generatedContent)
        }
        else{
            return ToolOutput(data.generatedContent)
        }
    }
    
    func perform() async throws -> String? {
        guard let url = Bundle.main.url(forResource: "gainLoss", withExtension: "json") else {
            print("error")
            return nil
        }

        let data = try Data(contentsOf: url)
        let schedule = try JSONDecoder().decode(PortfolioResponse.self, from: data)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(schedule)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        return jsonString
    }
    
    func perform1() async throws -> PortfolioResponse? {
        guard let url = Bundle.main.url(forResource: "gainLoss", withExtension: "json") else {
            print("error")
            return nil
        }

        let data = try Data(contentsOf: url)
        let schedule = try JSONDecoder().decode(PortfolioResponse.self, from: data)
    
        return schedule
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
//struct GainLossIntent: Tool {
//    
//    typealias Arguments = <#type#>
//    
//    var description: String
//    
//    var parameters: GenerationSchema
//    
//    static let title: LocalizedStringResource = "Load gainLoss from JSON"
//
//        func perform() async throws -> some IntentResult {
//            guard let url = Bundle.main.url(forResource: "gainLoss", withExtension: "json") else {
//                throw ScheduleError.fileNotFound
//            }
//
//            let data = try Data(contentsOf: url)
//           // let schedule = try JSONDecoder().decode(DaySchedule.self, from: data)
//
//            let summary = String(data: data, encoding: .utf8) ?? "nil"
//
//            return .result(value: summary)
//        }
//    
//    func perform1() async throws -> String {
//        guard let url = Bundle.main.url(forResource: "gainLoss", withExtension: "json") else {
//            throw ScheduleError.fileNotFound
//        }
//
//        let data = try Data(contentsOf: url)
//        let schedule = try JSONDecoder().decode(PortfolioResponse.self, from: data)
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        let jsonData = try encoder.encode(schedule)
//        let jsonString = String(data: jsonData, encoding: .utf8)!
//        
//        return jsonString
//    }
//    
//    func perform2() async throws -> AccountResponse {
//        guard let url = Bundle.main.url(forResource: "history", withExtension: "json") else {
//            throw ScheduleError.fileNotFound
//        }
//
//        let data = try Data(contentsOf: url)
//        let schedule = try JSONDecoder().decode(AccountResponse.self, from: data)
//        return schedule
//    }
//    
//    enum ScheduleError: Error, CustomLocalizedStringResourceConvertible {
//            case fileNotFound
//
//            var localizedStringResource: LocalizedStringResource {
//                switch self {
//                case .fileNotFound: return "Could not find schedule.json in the app bundle."
//                }
//            }
//        }
//}
