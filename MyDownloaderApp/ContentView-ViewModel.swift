//
//  ContentView-ViewModel.swift
//  MyDownloaderApp
//
//  Created by Rreuno Velasco on 5/10/23.
//

import Foundation
import Network
import SystemConfiguration


extension ContentView {
   @MainActor class ViewModel: NSObject, ObservableObject, URLSessionDownloadDelegate {
      @Published var isDownload = false
      @Published var isPaused = false
      @Published var isConnected = false
      @Published private var downloadData: Data!
      @Published var progressDownload: Float = 0.0
      @Published var showToast = false
      @Published var toastMessage = ""
      @Published var toastImage = ""
      
      private var downloadTask: URLSessionDownloadTask!
      private var url: String = ""
      private var fileURL: URL?
      private lazy var urlSession = URLSession(configuration: .default,
                                               delegate: self,
                                               delegateQueue: OperationQueue())
      //connection monitoring
      let monitor = NWPathMonitor()
      let queue = DispatchQueue.main
      
      let urlTest = "http://ipv4.download.thinkbroadband.com:8080/5MB.zip"
      //   "https://www.tutorialspoint.com/swift/pdf/index.pdf"
      
      func urlSession(
         _ session: URLSession,
         downloadTask: URLSessionDownloadTask,
         didFinishDownloadingTo location: URL
      ) {
         guard let url = downloadTask.currentRequest?.url else {
            print("no url for request")
            return
         }
         
         let docsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
         let destinationPath = docsPath.appendingPathComponent(url.lastPathComponent)
         try? FileManager.default.removeItem(at: destinationPath)
         
         do {
            try FileManager.default.copyItem(at: location, to: destinationPath) //tmp file released when connection is lost
         } catch {
            print("Copy Error: \(error.localizedDescription)")
         }
      }
      
      func urlSession(
         _ session: URLSession,
         task: URLSessionTask,
         didCompleteWithError error: Error?
      ) {
         guard let error = error else {
            return
         }
         
         //TODO: - try to save session or task?
         let userInfo = (error as NSError).userInfo
         if let resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            DispatchQueue.main.async {
               self.downloadData = resumeData
            }
         }
      }
      
      func urlSession(
         _ session: URLSession,
         downloadTask: URLSessionDownloadTask,
         didWriteData bytesWritten: Int64,
         totalBytesWritten: Int64,
         totalBytesExpectedToWrite: Int64
      ) {
         if downloadTask == downloadTask {
            let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
               self.progressDownload = calculatedProgress * 100
               
               //show toast when at 100%
               if self.progressDownload == 100.0 {
                  self.isDownload = false
                  self.showToast(message: Constants.NetworkEnum.DOWNLOAD_COMPLETE, image: Constants.NetworkEnum.TOAST_DOWNLOAD_COMPLETE)
               }
            }
         }
      }
      
      
      func download(from urlString: String){
         if !self.isConnected {
            self.showToast(message: Constants.NetworkEnum.NO_CONNECTION, image: Constants.NetworkEnum.TOAST_NO_CONNECTION)
         } else {
            guard let url = URL(string: urlString) else {
               showToast(message: Constants.NetworkEnum.NO_URL, image: Constants.NetworkEnum.TOAST_NO_URL)
               return
            }
            
            self.fileURL = url
            self.downloadTask = self.urlSession.downloadTask(with: url)
            self.downloadTask.resume()
            self.isDownload = true 
         }
      }
      
      func pauseDownload(){
         if !self.isPaused {
            self.isPaused = true
            self.downloadTask?.cancel { resumeDataOrNil in
               guard let resumeData = resumeDataOrNil else {
                  return
               }
               
               Task { @MainActor in
                  //resumeData set when manually paused
                  self.downloadData = resumeData
                  self.downloadTask = nil
               }
            }
         }
      }
      
      func resumeDownload(){
         if self.isPaused {
            guard let resumeData = self.downloadData else {
               //inform the user the download can't be resumed
               showToast(message: Constants.NetworkEnum.DOWNLOAD_FAILED, image: Constants.NetworkEnum.TOAST_DOWNLOAD_FAILED)
               return
            }
            let downloadTask = self.urlSession.downloadTask(withResumeData: resumeData)
            downloadTask.resume()
            self.downloadTask = downloadTask
            
            self.isPaused = false
         }
      }
      
      func stopDownload(){
         self.downloadTask?.cancel()
         self.downloadData = nil
         self.downloadTask = nil
         self.isDownload = false
         self.isPaused = false
         self.progressDownload = 0.0
         
         objectWillChange.send()
      }
      
      func checkConnection() {
         monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
               //disable resume button
               self.isConnected = false
               
               //show toast
               self.showToast(message: Constants.NetworkEnum.NO_CONNECTION, image: Constants.NetworkEnum.TOAST_NO_CONNECTION)
               
               //pause download
               self.isDownload ? self.pauseDownload() : nil
            } else {
               //enable resume button
               self.isConnected = true
               
               //show toast
               self.showToast(message: Constants.NetworkEnum.IS_CONNECTED, image: Constants.NetworkEnum.TOAST_IS_CONNECTED)
               
               //resume download if data is present
               self.resumeDownload()
            }
            
            self.showToast = true
         }
         monitor.start(queue: queue)
      }
      
      func showToast(message: String, image: String){
         self.toastMessage = message
         self.toastImage = image
         self.showToast = true
      }
   }
}
