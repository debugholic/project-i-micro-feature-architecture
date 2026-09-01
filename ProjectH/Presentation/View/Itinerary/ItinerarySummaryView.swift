import SwiftUI

struct ItinerarySummaryView: View {
  let input: any ItineraryViewModelType
  let plan: DayPlan

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      CardSection(title: "숙소 정보") {
        LodgingCard(input: input, item: plan.lodging)
      }

      CardSection(title: "식사 정보") {
        ForEach(MealSlot.allCases, id: \.self) { slot in
          MealRow(input: input, item: plan.meal(slot), slot: slot)
        }
      }
    }
  }

  private struct CardSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        Text(title)
          .font(.subheadline.weight(.semibold))
          .foregroundColor(.secondary)

        VStack(spacing: 0) {
          content
        }
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
      }
    }
  }

  private struct LodgingCard: View {
    let input: any ItineraryViewModelType
    let item: ItineraryItem?

    var body: some View {
      Button {
        input.didTapLodging()
      } label: {
        VStack(spacing: 0) {
          RowLabel(detail: nil, title: "숙소", value: item?.title)
          if let item {
            RowLabel(detail: nil, title: "지역", value: item.location)
            if let endTime = item.endTime {
              RowLabel(
                detail: ItineraryFormatter.dayRange(from: item.startTime, to: endTime),
                title: "기간",
                value: nil
              )
            }
            RowLabel(detail: ItineraryFormatter.dayTime(item.startTime), title: "체크인", value: nil)
            if let endTime = item.endTime {
              RowLabel(detail: ItineraryFormatter.dayTime(endTime), title: "체크아웃", value: nil)
            }
          }
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    }
  }

  private struct MealRow: View {
    let input: any ItineraryViewModelType
    let item: ItineraryItem?
    let slot: MealSlot

    var body: some View {
      Button {
        input.didTapMeal(slot)
      } label: {
        RowLabel(
          detail: nil,
          title: ItineraryFormatter.mealName(slot),
          value: item?.title
        )
      }
      .buttonStyle(.plain)
    }
  }

  private struct RowLabel: View {
    let detail: String?
    let title: String
    let value: String?

    var body: some View {
      HStack(alignment: .top, spacing: 12) {
        Text(title)
          .font(.footnote.weight(.medium))
          .foregroundColor(.secondary)
          .frame(width: 56, alignment: .leading)

        Text(value ?? detail ?? "-")
          .font(.subheadline.weight(value == nil && detail == nil ? .regular : .medium))
          .foregroundColor(value == nil && detail == nil ? .secondary : .primary)

        Spacer(minLength: 0)

        if value == nil, detail == nil {
          Image(systemName: "plus")
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
        }
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .contentShape(Rectangle())
    }
  }
}
