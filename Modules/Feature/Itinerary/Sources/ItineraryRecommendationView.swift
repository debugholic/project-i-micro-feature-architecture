import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTripInterface
import SharedCommon
import SwiftUI

struct ItineraryRecommendationView: View {
  @ObservedObject private var viewModel: ItineraryRecommendationViewModel

  init(viewModel: ItineraryRecommendationViewModel) {
    _viewModel = ObservedObject(wrappedValue: viewModel)
  }

  var body: some View {
    NavigationView {
      Group {
        if viewModel.isLoading {
          ProgressView()
        } else if viewModel.areas.isEmpty {
          Empty(city: viewModel.city)
        } else {
          List {
            ForEach(viewModel.areas, id: \.name) { area in
              Section(area.name) {
                ForEach(area.places, id: \.name) { place in
                  PlaceRow(
                    isPicked: viewModel.pickedNames.contains(place.name),
                    place: place,
                    viewModel: viewModel
                  )
                }
              }
            }
          }
          .listStyle(.insetGrouped)
        }
      }
      .navigationTitle(viewModel.city)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("완료") { viewModel.didTapClose() }
        }
      }
    }
  }

  private struct PlaceRow: View {
    let isPicked: Bool
    let place: RecommendedPlace
    let viewModel: ItineraryRecommendationViewModel

    var body: some View {
      Button {
        viewModel.didTapPlace(place)
      } label: {
        HStack(spacing: 10) {
          Image(systemName: symbol)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(width: 18)
          Text(place.name)
            .foregroundColor(.primary)
          Spacer(minLength: 0)
          Image(systemName: isPicked ? "checkmark.circle.fill" : "plus.circle")
            .foregroundColor(isPicked ? .accentColor : .secondary)
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    }

    private var symbol: String {
      switch place.category {
      case .food: return "fork.knife"
      case .shopping: return "bag"
      case .sight: return "camera"
      }
    }
  }

  private struct Empty: View {
    let city: String

    var body: some View {
      VStack(spacing: 6) {
        Text("\(city)의 추천 목록이 아직 없어요.")
          .font(.subheadline)
        Text("이름을 직접 입력해 일정을 넣을 수 있습니다.")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding()
    }
  }
}
