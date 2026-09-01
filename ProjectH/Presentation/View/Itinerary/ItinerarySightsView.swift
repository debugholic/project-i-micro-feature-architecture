import SwiftUI

struct ItinerarySightsView: View {
  let input: any ItineraryViewModelType
  let sights: [ItineraryItem]

  private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("주요 관광 정보")
        .font(.subheadline.weight(.semibold))
        .foregroundColor(.secondary)

      LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
        ForEach(sights) { sight in
          SightChip(input: input, sight: sight)
        }
        AddChip(input: input)
      }
    }
  }

  private struct SightChip: View {
    let input: any ItineraryViewModelType
    let sight: ItineraryItem

    private var isScheduled: Bool { sight.category == .place }

    var body: some View {
      Button {
        input.didSelectItem(sight)
      } label: {
        HStack(spacing: 6) {
          if isScheduled {
            Text(ItineraryFormatter.time(sight.startTime))
              .font(.caption.monospacedDigit().weight(.semibold))
              .foregroundColor(.green)
          }
          Text(sight.title)
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
    let input: any ItineraryViewModelType

    var body: some View {
      Button {
        input.didTapAddSight()
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "plus")
            .font(.caption.weight(.semibold))
          Text("추천에서 담기")
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
