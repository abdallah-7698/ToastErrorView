//
//  Toasts.swift
//  ErrorView
//
//  Created by name on 07/07/2025.
//

import SwiftUI

struct Toast: Identifiable {
  private(set) var id: String = UUID().uuidString
  var content: AnyView
  
  // the id is used to identify the toast so we can remove it
  init(@ViewBuilder content: @escaping (String) -> some View) {
    self.content = .init(content(id))
  }
  
  /// View Proberties
  var offset: CGFloat = 0
  var isDeleting: Bool = false
}

extension View {
  @ViewBuilder
  func interactiveToast(_ toasts: Binding<[Toast]>) -> some View {
    self
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        ToastsView(toasts: toasts)
      }
  }
}

fileprivate struct ToastsView: View {
  
  @Binding var toasts: [Toast]
  @State private var isExpeneded: Bool = false
  var body: some View {
    ZStack(alignment: .bottom) {
      if isExpeneded {
        Rectangle()
          .fill(.ultraThinMaterial)
          .ignoresSafeArea()
          .onTapGesture {
            isExpeneded = false
          }
      }
      let layout = isExpeneded ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(ZStackLayout())
      
      layout {
        ForEach($toasts) { $toast in
          let index = (toasts.count - 1) - (toasts.firstIndex(where: { $0.id == toast.id }) ?? 0)
          toast.content
            .offset(x: toast.offset)
            .gesture(
              DragGesture()
                .onChanged{ value in
                  let xOffset = value.translation.width < 0 ? value.translation.width : 0
                  toast.offset = xOffset
                }
                .onEnded{ value in
                  let xOffset = value.translation.width + (value.velocity.width / 2)
                  
                  if -xOffset > 200 {
                    /// remove the toast
                    $toasts.delete(toast.id)
                  } else {
                    /// reset toast to the initial place
                    toast.offset = 0
                  }
                  
                }
            )
            .visualEffect { [isExpeneded] content, proxy in
              content
                .scaleEffect( isExpeneded ? 1 : scale(index), anchor: .bottom)
                .offset(y: isExpeneded ? 0 :  offsetY(index))
            }
            .zIndex(toast.isDeleting ? 1000:0)
            .frame(maxWidth: .infinity)
            .transition(.asymmetric(insertion: .offset(y: 100), removal: .move(edge: .leading)))
          
          
        }
      }
      .onTapGesture {
        isExpeneded.toggle()
      }
    }
    .animation(.bouncy, value: isExpeneded)
    .padding(.bottom, 15)
    .onChange(of: toasts.isEmpty) { oldValue, newValue in
      if newValue {
        isExpeneded = false
      }
    }
  }
  
  nonisolated func offsetY(_ index: Int) -> CGFloat {
    let offset: CGFloat = min(CGFloat(index) * 15, 30)
    return -offset
  }
  
  nonisolated func scale(_ index: Int) -> CGFloat {
    let scale: CGFloat = min(CGFloat(index) * 0.1, 1)
    return 1-scale
  }
  
}


extension Binding<[Toast]> {
  func delete(_ id: String) {
    if let toast = first(where: { $0.id == id }) {
      toast.wrappedValue.isDeleting = true
    }
    withAnimation(.bouncy) {
      self.wrappedValue.removeAll { $0.id == id }
    }
  }
}

#Preview {
  ContentView()
}
