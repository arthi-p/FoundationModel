//
//  TradeTool.swift
//  FoundationModelsTripPlanner
//
//  Created by fnu ashwin on 2025-06-18.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation
import PDFKit
import FoundationModels

struct TradeTool: Tool {
    let name = "TradeTool"
    let description = "Provides user's trading details such as gain/loss, history, alerts, or quantity for a specific stock."

    init() {
    }
    
    @Generable()
    enum TransactionType: String {
        case buy
        case sell
        case transfer
    }

    @Generable()
    enum DetailOn {
        case history
        case gain
        case loss
        case quantity
    }
    @Generable
    struct Arguments {
        @Guide(description: "The stock the user is asking about, such as the company name or ticker symbol.")
        let interestedStock: String
        @Guide(description: "The type of detail the user is requesting about the stock.")
        let detailOn: DetailOn
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        print("report Tool\(arguments)")

        switch arguments.detailOn {
        case .history:
            let history = try await getHistory()!
            let typeFiltered = history.data.transactions.filter { trans in
              // return trans.transactionType.localizedCaseInsensitiveContains(transactionType.rawValue)
                return true
            }
            
            if !arguments.interestedStock.isEmpty {
                let filteredData = typeFiltered.filter({ $0.shortDescription.localizedCaseInsensitiveContains(arguments.interestedStock)  || ($0.symbol?.caseInsensitiveCompare(arguments.interestedStock) == .orderedSame)  })
                print(filteredData)
                return ToolOutput(filteredData.generatedContent)
            }
        case .gain, .loss, .quantity:
                let data = try await getGainLoss()!
                if !arguments.interestedStock.isEmpty {
                    let filteredData = data.data.accounts[0].equityPositions?.positions
                        .filter { $0.asset.shortName.localizedCaseInsensitiveContains(arguments.interestedStock) || ($0.asset.symbol.caseInsensitiveCompare(arguments.interestedStock) == .orderedSame)
                        }
                    return ToolOutput(filteredData.generatedContent)
                } else {
                    return ToolOutput(data.data.accounts[0].generatedContent)
                }
        }


        return ToolOutput("no data")
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
    
    func getGainLoss() async throws -> PortfolioResponse? {
        guard let url = Bundle.main.url(forResource: "gainLoss", withExtension: "json") else {
            print("error")
            return nil
        }

        let data = try Data(contentsOf: url)
        let schedule = try JSONDecoder().decode(PortfolioResponse.self, from: data)
    
        return schedule
    }
    
    func setAlert(){
        
    }
    
    func extractText(from url: URL) -> String {
        guard let pdf = PDFDocument(url: url) else { return "" }

        var fullText = ""
        for pageIndex in 0..<pdf.pageCount {
            if let page = pdf.page(at: pageIndex),
               let text = page.string {
                fullText += text + "\n"
            }
        }
        return fullText
    }
    
    func getReportData()-> String{
        let pdfURL = Bundle.main.url(forResource: "1", withExtension: "pdf")!
        let textContent = extractText(from: pdfURL)
        return textContent
    }
}


struct ReportTool: Tool {
    let name = "Research Report Tool"
    let description = "Provides the research report on market"
    
    init() {
    }

    @Generable
    struct Arguments {
        @Guide(description: "user looking for")
    let lookingFor: String
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        print("report Tool\(arguments)")

        // This sample app pulls some static data. Real-world apps can get creative.
        let reportContent = getReportData()
        return ToolOutput(reportContent)
    }
    
    
    func extractText(from url: URL) -> String {
        guard let pdf = PDFDocument(url: url) else { return "" }

        var fullText = ""
        for pageIndex in 1..<pdf.pageCount {
            if let page = pdf.page(at: pageIndex),
               let text = page.string {
                fullText += text + "\n"
            }
        }
        return fullText
    }
    
    func getReportData()-> String{
        let pdfURL = Bundle.main.url(forResource: "2", withExtension: "pdf")!
        let textContent = extractText(from: pdfURL)
        return textContent
    }
}
