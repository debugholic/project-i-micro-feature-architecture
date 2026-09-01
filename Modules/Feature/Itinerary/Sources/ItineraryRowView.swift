import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTripInterface
import SharedCommon
import SwiftUI

struct ItineraryRowView: View {
  let input: any ItineraryViewModelType
  let item: DayPlanItem

  var body: some View {
    if let custom = item.itineraryItem {
      Button {
        input.didSelectItem(custom)
      } label: {
        RowLabel(item: item)
      }
      .buttonStyle(.plain)
    } else {
      RowLabel(item: item)
    }
  }

  private struct RowLabel: View {
    let item: DayPlanItem

    var body: some View {
      HStack(alignment: .top, spacing: 8) {
        Image(systemName: symbol)
          .font(.caption.weight(.semibold))
          .foregroundColor(tint)
          .frame(width: 18)
          .padding(.top, 1)

        VStack(alignment: .leading, spacing: 2) {
          HStack(spacing: 6) {
            Text(ItineraryFormatter.time(item.startTime))
              .font(.caption.monospacedDigit().weight(.semibold))
              .foregroundColor(tint)
            Text(ItineraryFormatter.title(item))
              .font(.subheadline.weight(.semibold))
              .foregroundColor(.primary)
          }
          if let subtitle = ItineraryFormatter.subtitle(item) {
            Text(subtitle)
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

        Spacer(minLength: 0)
      }
      .padding(.vertical, 6)
      .padding(.horizontal, 10)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(tint.opacity(0.16))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(tint.opacity(0.45), lineWidth: 1)
          )
      )
      .contentShape(Rectangle())
    }

    private var symbol: String {
      switch item {
      case let .custom(item): return ItineraryFormatter.symbol(item)
      case .flight: return "airplane"
      }
    }

    private var tint: Color {
      switch item {
      case .flight: return .blue
      case let .custom(item):
        return item.mealSlot == nil ? .green : .orange
      }
    }
  }
}
