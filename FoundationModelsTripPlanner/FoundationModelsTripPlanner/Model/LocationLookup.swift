/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class used to fetch the weather for a location using MapKit and WeatherKit.
*/
import MapKit
import WeatherKit
import Playgrounds
import FoundationModels

@Generable
struct DaySchedule {
    @Guide(description: "list of time of day like morning, noon")
    var timeOfDay: [String]
    @Guide(description: "dictionary with time of day and activity")
    
    var activity:DayActivity
}
@Generable
struct DayActivity {
    @Guide(description: "dictionary with time of day and activity")
    var tasks: [String]
}


//#Playground{
//    let data = try await GainLossIntent().perform1()
//
//    let session = LanguageModelSession{
//        data
//    }
////    let response = try await session.respond(to: "tell my gain loss on tesla stock")
////    print(response)
//    let response2 = try await session.respond(to: "how much is 2 plus 2")
//    print(response2)
//    
//}

@Observable @MainActor
final class LocationLookup {
    private(set) var item: MKMapItem?
    private(set) var temperatureString: String?

    func performLookup(location: String) {
        Task {
            let item = await self.mapItem(atLocation: location)
            if let location = item?.placemark.location {
                self.temperatureString = await self.weather(atLocation: location)
            }
        }
    }
    
    private func mapItem(atLocation location: String) async -> MKMapItem? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location
        
        let search = MKLocalSearch(request: request)
        do {
            return try await search.start().mapItems.first
        } catch {
            Logging.general.error("Failed to look up location: \(location). Error: \(error)")
        }
        return nil
    }
    
    private func weather(atLocation location: CLLocation) async -> String {
        do {
            let weather = try await WeatherService.shared.weather(
                for: location,
                including: .current
            )
            let temperature = weather.temperature
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .providedUnit
            formatter.numberFormatter.maximumFractionDigits = 1
            return formatter.string(from: temperature)
        } catch {
            Logging.general.error("Couldn't fetch weather: \(error.localizedDescription)")
            return "unavailable"
        }
    }
}
