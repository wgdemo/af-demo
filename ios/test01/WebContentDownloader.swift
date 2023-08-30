

import Foundation
import WebKit

struct MimeType {
    var type:String
    var fileExtension:String
}

protocol WebDownloadable: WKDownloadDelegate {
    func downloadDidFinish(fileResultPath: URL)
    func downloadDidFail(error: Error, resumeData: Data?)
}

class WebContentDownloader: NSObject {
    
    private var filePathDestination: URL?
    
    weak var downloadDelegate: WebDownloadable?
    
    func generateTempFile(with suggestedFileName: String?) -> URL {
        let temporaryDirectoryFolder = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return temporaryDirectoryFolder.appendingPathComponent(suggestedFileName ?? ProcessInfo().globallyUniqueString)
    }
    
    func downloadFileOldWay(fileURL: URL, optionSessionCookies: [HTTPCookie]?) {
        // Your classic URL Session Data Task
    }
    
    private func cleanUp() {
        filePathDestination = nil
    }
}

@available(iOS 15.0, *)
extension WebContentDownloader: WKDownloadDelegate {
    
    func downloadDidFinish(_ download: WKDownload) {
        
        guard let filePathDestination = filePathDestination else {
            return
        }
        downloadDelegate?.downloadDidFinish(fileResultPath: filePathDestination)
        cleanUp()
    }
    
    public func download(_ download: WKDownload,
                         didFailWithError error: Error,
                         resumeData: Data?) {
        downloadDelegate?.downloadDidFail(error: error, resumeData: resumeData)
    }
    
    func download(_ download: WKDownload, decideDestinationUsing
                  response: URLResponse, suggestedFilename: String,
                  completionHandler: @escaping (URL?) -> Void) {
        
        filePathDestination = generateTempFile(with: suggestedFilename)
        completionHandler(filePathDestination)
    }
    
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = downloadDelegate
    }
}

