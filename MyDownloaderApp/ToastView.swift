//
//  ToastView.swift
//  MyDownloaderApp
//
//  Created by Rreuno Velasco on 5/16/23.
//

import SwiftUI

struct ToastView: View {
   let toast: Toast
   @Binding var show: Bool
   
    var body: some View {
       VStack {
          HStack {
             Image(systemName: toast.image)
             Text(toast.title)
          }
          .font(.headline)
          .foregroundColor(.primary)
          .padding(.horizontal, 40)
          .padding(.vertical, 20)
          .background(.gray.opacity(0.4), in: Capsule())
          Spacer()
       }
       .frame(width: UIScreen.main.bounds.width / 1.25)
       .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
       .onTapGesture {
          withAnimation {
             self.show = false
          }
       }
       .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 3){
             withAnimation {
                self.show = false
             }
          }
       }
    }
}

//try to remove this and see the change with zstack
struct Overlay<T: View>: ViewModifier{
   @Binding var show: Bool
   let overlayView: T
   
   func body(content: Content) -> some View {
      ZStack {
         content
         if show {
            overlayView
         }
      }
   }
}

extension View {
   func overlay<T: View>(overlayView: T, show: Binding<Bool>) -> some View {
      self.modifier(Overlay(show: show, overlayView: overlayView))
   }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
       ToastView(toast: Toast(title: "No connection", image: "wifi.slash"), show: .constant(true))
    }
}
