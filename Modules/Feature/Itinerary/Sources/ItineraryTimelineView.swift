import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTripInterface
import SharedCommon
import SwiftUI

struct ItineraryTimelineView: View {
  let input: any ItineraryViewModelType
  let plan: DayPlan

  private let itemsByHour: [Int: [DayPlanItem]]

  init(
    input: any ItineraryViewModelType,
    plan: DayPlan
  ) {
    self.input = input
    self.plan = plan
    self.itemsByHour = Dictionary(grouping: plan.timelineItems) { input.hour(of: $0) }
  }

  var body: some View {
    VStack(spacing: 0) {
      ForEach(0..<24, id: \.self) { hour in
        HourRow(
          hour: hour,
          input: input,
          items: itemsByHour[hour] ?? []
        )
        .id(hour)
      }
    }
  }

  private struct HourRow: View {
    let hour: Int
    let input: any ItineraryViewModelType
    let items: [DayPlanItem]

    var body: some View {
      HStack(alignment: .top, spacing: 12) {
        HourLabel(hour: hour, isEmpty: items.isEmpty)

        Rectangle()
          .fill(Color(.opaqueSeparator))
          .frame(width: 1)

        if items.isEmpty {
          EmptySlot(hour: hour, input: input)
        } else {
          VStack(alignment: .leading, spacing: 4) {
            ForEach(items) { item in
              ItineraryRowView(input: input, item: item)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.bottom, 6)
        }
      }
      .frame(minHeight: 32, alignment: .top)
    }
  }

  private struct HourLabel: View {
    let hour: Int
    let isEmpty: Bool

    var body: some View {
      Text(ItineraryFormatter.hourLabel(hour))
        .font(.caption.monospacedDigit().weight(isEmpty ? .medium : .bold))
        .foregroundColor(.primary)
        .opacity(isEmpty ? 0.6 : 1)
        .frame(width: 24, alignment: .trailing)
    }
  }

  private struct EmptySlot: View {
    let hour: Int
    let input: any ItineraryViewModelType

    var body: some View {
      Button {
        input.didTapHour(hour)
      } label: {
        HStack {
          Text("-")
            .font(.footnote)
            .foregroundColor(.secondary)
          Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.bottom, 6)
    }
  }
}
