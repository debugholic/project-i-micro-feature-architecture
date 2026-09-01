import DomainItineraryInterface
import DomainTripInterface

extension Trip {
  var flightItems: [DayPlanItem] {
    var result: [DayPlanItem] = [
      .flight(outbound, .departure),
      .flight(outbound, .arrival),
    ]
    if let returnLeg {
      result.append(.flight(returnLeg, .departure))
      result.append(.flight(returnLeg, .arrival))
    }
    return result
  }
}
