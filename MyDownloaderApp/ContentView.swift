//
//  ContentView.swift
//  MyDownloaderApp
//
//  Created by Rreuno Velasco on 5/10/23.
//

import SwiftUI

struct ContentView: View {
   @StateObject private var viewModel = ViewModel()
   @State private var myURL = ""
   
    var body: some View {
        VStack {
           HStack {
              TextField("Enter URL of file to download", text: self.$myURL)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
              Button {
                 viewModel.download(from: self.myURL)
              } label: {
                 Image(systemName: "arrow.down.circle.fill")
                    .font(.title)
              }
              .disabled(viewModel.isDownload)
           }
           
           ProgressView("", value: viewModel.progressDownload, total: 100)
              .padding(.bottom, 20)
        }
        .padding()
        .onAppear() {
           viewModel.checkConnection()
           self.myURL = viewModel.urlTest
        }
        .overlay(overlayView: ToastView(toast: Toast(title: viewModel.toastMessage, image: viewModel.toastImage), show: $viewModel.showToast), show: $viewModel.showToast)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
