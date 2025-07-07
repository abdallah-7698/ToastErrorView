//
//  ContentView.swift
//  ErrorView
//
//  Created by name on 07/07/2025.
//

import SwiftUI

struct ContentView: View {
  
  @State private var toasts = [Toast]()
  
    var body: some View {
      NavigationStack {
        List {
          Text("Dummy List Row Views")
        }
        .navigationTitle(Text("Toasts"))
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button("show", action: showToast)
          }
        }
      }
      .interactiveToast($toasts)
    }
  
  func showToast() {
    withAnimation(.bouncy) {
      let toast = Toast { id in
        ToastView(id)
      }
      
      toasts.append(toast)
      
    }
  }
  
  /// Custom Toast View
  @ViewBuilder
  func ToastView(_ id: String) -> some View {
    HStack (spacing: 12) {
      Image(systemName: "square.and.arrow.up.fill")
      
      Text("Hello World")
        .font(.callout)

      Spacer(minLength: 0)
      
      
      Button {
        $toasts.delete(id)
      } label: {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
      }
    }
    .foregroundStyle(Color.primary)
      .padding(.vertical, 12)
      .padding(.leading, 15)
      .padding(.trailing, 10)
      .background {
        Capsule()
          .fill(.background)
          .shadow(color: .black.opacity(0.06),radius: 3, x: -1, y: -3)
          .shadow(color: .black.opacity(0.06),radius: 2, x: 1, y: 3)
      }
      .padding(.horizontal, 15 )
  }
  
}

#Preview {
    ContentView()
}
