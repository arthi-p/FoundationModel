/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main function for the FoundationModelsTripPlanner app.
*/

import SwiftUI
import Playgrounds
import FoundationModels

@main
struct FoundationModelsTripPlannerApp: App {
    
    var body: some Scene {
        WindowGroup {
            ChatView()
                //.environment(modelData)
                .onAppear {
                    Task {
                        
                    }
                }
        }
    }
    
}

import Foundation

@Generable
struct PortfolioResponse: Codable, Equatable {
    let data: PortfolioData
}

@Generable
struct PortfolioData: Codable, Equatable {
    @Guide(description: "list of account in user's portfolio")
    let accounts: [Account]
}

@Generable
struct Account: Codable, Equatable {
    let accountId: String
    let accountNickName: String
    let accountTotalValue: Double
    let totalDayChange: Double
    let totalDayChangePercent: Double

    @Guide(description: "equity positions in user's portfolio")
    let equityPositions: PositionCategory?
    @Guide(description: " etfs in user's portfolio")
    let etfPositions: PositionCategory?
    @Guide(description: " mutual funds in user's portfolio")
    let mutualFundPositions: TotalsOnlyCategory?
    @Guide(description: " option postions in user's portfolio")
    let optionsPositions: TotalsOnlyCategory?
    @Guide(description: " fixed income positions in user's portfolio")
    let fixedIncomePositions: TotalsOnlyCategory?
    @Guide(description: " cash positions in user's portfolio")
    let cashPositions: CashPositionCategory?
    let otherPositions: TotalsOnlyCategory?
    let totals: Totals
}

@Generable
struct PositionCategory: Codable, Equatable {
    let positions: [Position]
    let totals: Totals
}

@Generable
struct TotalsOnlyCategory: Codable, Equatable {
    let totals: Totals
}

@Generable
struct CashPositionCategory: Codable, Equatable {
    let positions: [Position]?
    let totals: Totals
}

@Generable
struct Position: Codable, Equatable {
    let quantity: Double
    let asset: Asset
    let price: ValueChange
    let marketValue: ValueChange
    let costBasis: CostBasis
    let gainLoss: GainLoss
    let lotRef: String
    let isLongTerm: Bool
    let itemIssueId: String
}

@Generable
struct Asset: Codable, Equatable {
    let description: String
    let shortName: String
    let symbol: String
    let quoteEligible: Bool
}

@Generable
struct ValueChange: Codable, Equatable {
    let value: Double
    let dayChange: Double
    let dayChangePercent: Double?
    let displayCode: Int
    let changeDisplayCode: Int?
}

@Generable
struct CostBasis: Codable, Equatable {
    let value: Double
    let costPerShare: Double
    let averageCostPerShare: Double
    let displayCode: Int
    let displayCodeAverageCPS: Int
}

@Generable
struct GainLoss: Codable, Equatable {
    @Guide(description: "This is total gain or loss of that stock")
    let value: Double
    let percent: Double
    @Guide(description: "This is avarage gain or loss of per stock")
    let averagePerShare: Double
    let averagePerSharePercent: Double
    let displayCodePercent: Int
    let displayCodeValue: Int
    let displayCodeAPSPercent: Int
    let displayCodeAPSValue: Int
}

@Generable
struct Totals: Codable, Equatable {
    let marketValueTotals: MarketValueTotal
    let costBasisTotals: CostBasisTotal
    let gainLossTotals: GainLossTotal
}

@Generable
struct MarketValueTotal: Codable, Equatable {
    let value: Double
    let dayChange: Double
    let dayChangePercent: Double?
    let fullyKnown: Bool
    let footNotes: [FootNote]?
}

@Generable
struct CostBasisTotal: Codable, Equatable {
    let blendedValue: Double
    let costFullyKnown: Bool
    let footNotes: [FootNote]?
}

@Generable
struct GainLossTotal: Codable, Equatable {
    let blendedValue: Double
    let blendedPercent: Double?
    let fullyKnown: Bool
    let footNotes: [FootNote]?
}

@Generable
struct FootNote: Codable, Equatable {
    let footNoteType: String
    let footNoteNumber: String
}

@Generable
struct AccountResponse: Codable {
    let data: AccountData
}
@Generable
struct AccountData: Codable {
    let hasMore: Bool
    let accountTotalValue: String
    let totalDayChange: Double
    let totalDayChangePercent: Double
    let transactions: [Transaction]
}
@Generable
struct Transaction: Codable {
    let transactionDate: String
    let shortDescription: String
    let transactionAmount: Double?
    @Guide(description: "Transaction type, it could stock buy,sell, cash transfer")
    let transactionType: String
    let longDescription: String
    let symbol:String?
    let tradeTransactionDetails: TradeTransactionDetails?

    enum CodingKeys: String, CodingKey {
        case transactionDate, shortDescription, transactionAmount, transactionType, longDescription, symbol,tradeTransactionDetails
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        transactionDate = try container.decode(String.self, forKey: .transactionDate)
        shortDescription = try container.decode(String.self, forKey: .shortDescription)
        transactionType = try container.decode(String.self, forKey: .transactionType)
        longDescription = try container.decode(String.self, forKey: .longDescription)
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        tradeTransactionDetails = try container.decodeIfPresent(TradeTransactionDetails.self, forKey: .tradeTransactionDetails)

        // Parse amount (e.g. "$130.00" or "-$130.00" or "$-130.00")
        let amountString = try container.decodeIfPresent(String.self, forKey: .transactionAmount) ?? "$0.00"
        let cleanAmount = amountString.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)
        
        transactionAmount = Double(cleanAmount) ?? 0.0
    }
}

@Generable
struct TradeTransactionDetails: Codable {
    let description: String
    let settleDate: String
    let securityNumber: String
    let principal: String
    let commission: String
}
