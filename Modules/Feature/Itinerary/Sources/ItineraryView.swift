import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTripInterface
import FeatureReservationInterface
import SharedCommon
import SwiftUI

struct ItineraryView: View {
  @ObservedObject private var viewModel: ItineraryViewModel

  init(viewModel: ItineraryViewModel) {
    _viewModel = ObservedObject(wrappedValue: viewModel)
  }

  var body: some View {
    VStack(spacing: 0) {
      DayChips(
        input: viewModel,
        plans: viewModel.dayPlans,
        selectedDate: viewModel.selectedDate
      )
      .padding(.horizontal, 16)
      .padding(.vertical, 16)

      Divider()

      ScrollViewReader { proxy in
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            if let plan = viewModel.selectedPlan {
              ItineraryTimelineView(input: viewModel, plan: plan)
              ItinerarySightsView(input: viewModel, plan: plan)
              ItinerarySummaryView(input: viewModel, plan: plan)
            }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 16)
        }
        .onChange(of: viewModel.selectedDate) { _ in
          scrollToFirstItem(proxy)
        }
        .onChange(of: viewModel.firstItemHour) { _ in
          scrollToFirstItem(proxy)
        }
      }
    }
    .navigationTitle(ReservationFormatter.cityName(viewModel.trip.destination))
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: editorBinding) { editorViewModel in
      ItineraryEditorView(viewModel: editorViewModel)
    }
    .sheet(item: recommendationBinding) { recommendationViewModel in
      ItineraryRecommendationView(viewModel: recommendationViewModel)
    }
  }

  private var editorBinding: Binding<ItineraryEditorViewModel?> {
    Binding(
      get: { viewModel.editorViewModel },
      set: { if $0 == nil { viewModel.didDismissEditor() } }
    )
  }

  private var recommendationBinding: Binding<ItineraryRecommendationViewModel?> {
    Binding(
      get: { viewModel.recommendationViewModel },
      set: { if $0 == nil { viewModel.didDismissRecommendations() } }
    )
  }

  private func scrollToFirstItem(_ proxy: ScrollViewProxy) {
    guard let hour = viewModel.firstItemHour else { return }
    withAnimation {
      proxy.scrollTo(hour, anchor: .top)
    }
  }

  private struct DayChips: View {
    let input: any ItineraryViewModelType
    let plans: [DayPlan]
    let selectedDate: Date?

    var body: some View {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(plans) { plan in
            DayChip(
              input: input,
              isSelected: plan.date == selectedDate,
              plan: plan
            )
          }
        }
      }
    }
  }

  private struct DayChip: View {
    let input: any ItineraryViewModelType
    let isSelected: Bool
    let plan: DayPlan

    var body: some View {
      Button {
        input.didSelectDate(plan.date)
      } label: {
        VStack(spacing: 3) {
          Text(ItineraryFormatter.dayLabel(plan.date))
            .font(.subheadline.weight(.semibold))
            .foregroundColor(isSelected ? .white : .primary)
          Text(ItineraryFormatter.route(plan))
            .font(.caption.weight(.medium))
            .foregroundColor(.primary)
            .opacity(isSelected ? 1 : 0.7)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
          isSelected ? Color.accentColor : Color(.secondarySystemBackground),
          in: RoundedRectangle(cornerRadius: 14)
        )
      }
      .buttonStyle(.plain)
    }
  }
}
