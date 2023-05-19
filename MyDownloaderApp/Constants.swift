//
//  Constants.swift
//  MyDownloaderApp
//
//  Created by Rreuno Velasco on 5/18/23.
//

import Foundation

struct Constants {
   enum NetworkEnum {
      static let NO_URL: String = "Please input URL"
      
      static let IS_CONNECTED: String = "Connected to the internet"
      static let NO_CONNECTION: String = "No internet connection"
      
      static let DOWNLOAD_COMPLETE: String = "Download complete"
      static let DOWNLOAD_FAILED: String = "Download failed"
      
      static let TOAST_NO_URL: String = "hand.raised"
      static let TOAST_IS_CONNECTED: String = "wifi"
      static let TOAST_NO_CONNECTION: String = "wifi.slash"
      static let TOAST_DOWNLOAD_COMPLETE: String = "checkmark.circle.fill"
      static let TOAST_DOWNLOAD_FAILED: String = "exclamationmark.triangle"
   }
}
