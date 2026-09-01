import DomainItineraryInterface
import SwiftUI

struct ItineraryEditorView: View {
  @ObservedObject private var viewModel: ItineraryEditorViewModel

  init(viewModel: ItineraryEditorViewModel) {
    _viewModel = ObservedObject(wrappedValue: viewModel)
  }

  var body: some View {
    NavigationView {
      Form {
        if !viewModel.unscheduledPlaces.isEmpty {
          Section("담아둔 곳") {
            PlacePicker(places: viewModel.unscheduledPlaces, viewModel: viewModel)
          }
        }

        Section {
          TextField("이름", text: $viewModel.title)

          switch viewModel.target {
          case .item(let mealSlot):
            if mealSlot == nil {
              DatePicker("시각", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
            }
          case .lodging:
            TextField("지역", text: $viewModel.location)
            DatePicker("체크인", selection: $viewModel.startTime)
            DatePicker("체크아웃", selection: $viewModel.endTime)
          case .place:
            EmptyView()
          }
        } footer: {
          if !viewModel.isHourAvailable {
            Text("그 시간대엔 이미 일정이 있어요.")
              .foregroundColor(.red)
          } else if !viewModel.isRangeValid {
            Text("체크아웃이 체크인보다 빨라요.")
              .foregroundColor(.red)
          }
        }

        if viewModel.isEditing {
          Section {
            if viewModel.canUnschedule {
              Button("시간표에서 빼기") { viewModel.didTapUnschedule() }
                .frame(maxWidth: .infinity)
            }
            Button("삭제", role: .destructive) { viewModel.didTapDelete() }
              .frame(maxWidth: .infinity)
          } footer: {
            if viewModel.canUnschedule {
              Text("빼면 시간표에서만 사라지고 주요 관광 정보에는 남습니다.")
            }
          }
        }
      }
      .navigationTitle(navigationTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("취소") { viewModel.didTapCancel() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(viewModel.isEditing ? "저장" : "추가") { viewModel.didTapSave() }
            .disabled(!viewModel.canSave)
        }
      }
    }
  }

  private var navigationTitle: String {
    let name: String
    switch viewModel.target {
    case .item(let mealSlot):
      name = mealSlot.map(ItineraryFormatter.mealName) ?? "장소"
    case .lodging:
      name = "숙소"
    case .place:
      name = "관광지"
    }
    return viewModel.isEditing ? "\(name) 수정" : "\(name) 추가"
  }

  private struct PlacePicker: View {
    let places: [TripPlace]
    let viewModel: ItineraryEditorViewModel

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]

    var body: some View {
      LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
        ForEach(places) { place in
          Chip(
            isSelected: viewModel.title == place.name,
            title: place.name
          ) {
            viewModel.didSelectPlace(place)
          }
        }
      }
      .padding(.vertical, 4)
    }
  }

  private struct Chip: View {
    let isSelected: Bool
    let title: String
    let onTap: () -> Void

    var body: some View {
      Button(action: onTap) {
        Text(title)
          .font(.footnote.weight(isSelected ? .semibold : .regular))
          .foregroundColor(isSelected ? .white : .primary)
          .lineLimit(1)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .frame(maxWidth: .infinity)
          .background(
            isSelected ? Color.accentColor : Color(.secondarySystemBackground),
            in: Capsule()
          )
      }
      .buttonStyle(.plain)
    }
  }
}
