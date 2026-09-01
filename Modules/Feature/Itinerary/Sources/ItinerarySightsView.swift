import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTripInterface
import SharedCommon
import SwiftUI

struct ItinerarySightsView: View {
  let input: any ItineraryViewModelType
  let plan: DayPlan

  private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("주요 관광 정보")
        .font(.subheadline.weight(.semibold))
        .foregroundColor(.secondary)

      LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
        ForEach(plan.places) { place in
          PlaceChip(
            input: input,
            place: place,
            scheduled: plan.item(for: place)
          )
        }
        AddChip(
          symbol: "square.and.pencil",
          title: "직접 추가"
        ) {
          input.didTapCreateSight()
        }
        AddChip(
          symbol: "plus",
          title: "추천에서 담기"
        ) {
          input.didTapAddSight()
        }
      }
    }
  }

  private struct PlaceChip: View {
    let input: any ItineraryViewModelType
    let place: TripPlace
    let scheduled: ItineraryItem?

    private var isScheduled: Bool { scheduled != nil }

    var body: some View {
      Button {
        input.didSelectPlace(place)
      } label: {
        HStack(spacing: 6) {
          if isScheduled {
            Text(ItineraryFormatter.time(scheduled?.startTime ?? place.date))
              .font(.caption.monospacedDigit().weight(.semibold))
              .foregroundColor(.green)
          }
          Text(place.name)
            .font(.footnote.weight(isScheduled ? .semibold : .regular))
            .foregroundColor(.primary)
            .lineLimit(1)
          Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .fill(isScheduled ? Color.green.opacity(0.16) : Color(.secondarySystemBackground))
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isScheduled ? Color.green.opacity(0.45) : .clear, lineWidth: 1)
            )
        )
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    }
  }

  private struct AddChip: View {
    let symbol: String
    let title: String
    let action: () -> Void

    var body: some View {
      Button {
        action()
      } label: {
        HStack(spacing: 6) {
          Image(systemName: symbol)
            .font(.caption.weight(.semibold))
          Text(title)
            .font(.footnote)
          Spacer(minLength: 0)
        }
        .foregroundColor(.accentColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .strokeBorder(Color.accentColor.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4]))
        )
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    }
  }
}
