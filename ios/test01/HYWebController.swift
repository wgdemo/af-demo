import Foundation
import UIKit
import WebKit
import AppsFlyerLib
import FirebaseAnalytics
import Photos

typealias BrushTrackDetailBlock = (Bool) -> Void
typealias BrushTrackBlackBlock = () -> Void
class HYWebController: UIViewController,WKNavigationDelegate, WKDownloadDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    var imgPath = ""
    
    @available(iOS 14.5, *)
    func download(_ download: WKDownload, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, nil)
    }
    
    @available(iOS 14.5, *)
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String) async -> URL? {
        let path = NSTemporaryDirectory()+suggestedFilename
        print(path)
        imgPath = path
        return URL(fileURLWithPath: path)
    }
    
    @available(iOS 14.5, *)
    func downloadDidFinish(_ download: WKDownload) {
        print("downloadDidFinish")
        if let image = UIImage(contentsOfFile: imgPath) {
            PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { (isSuccess: Bool, error: Error?) in
                        if isSuccess {
                            print("保存成功!")
                        } else{
                            print("保存失败：", error!.localizedDescription)
                        }
                    }
        }
    }

    @available(iOS 14.5, *)
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        print("didFailWithError")
        if let image = UIImage(contentsOfFile: imgPath) {
            PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { (isSuccess: Bool, error: Error?) in
                        if isSuccess {
                            print("保存成功!")
                        } else{
                            print("保存失败：", error!.localizedDescription)
                        }
                    }
        }
    }
    
    var BrushTrackDetailBlock: BrushTrackDetailBlock?
    var BrushTrackBKBlock: BrushTrackBlackBlock?
    private var BrushTrackView: WKWebView?
    var BrushTrackshangxin = ""
    init(BrushTrack: String) {
        super.init(nibName: nil, bundle: nil)
        navigationController?.navigationBar.barTintColor = .systemBlue
        navigationController?.navigationBar.tintColor = .white
        let BrushTrackButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(BrushTrackButtonClicked))
        navigationItem.rightBarButtonItem = BrushTrackButton
        let ConfBrushTrack = WKWebViewConfiguration()
        let userBrushTrackController = WKUserContentController()
        let BrushTrackStr = "window.jsBridge = {\n    postMessage: function(name, data) {\n        window.webkit.messageHandlers.BrushTrack.postMessage({name, data})\n    }\n};\n"
        let ScrUser = WKUserScript(source: BrushTrackStr, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        userBrushTrackController.addUserScript(ScrUser)
        let BrushTrackappVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let BrushTrackIdentifier = Bundle.main.bundleIdentifier ?? ""
        let BrushTrackStrVersion = "window.WgPackage = {name: '\(BrushTrackIdentifier)', version: '\(BrushTrackappVersion)'}"
        let BrushTrackScrUser = WKUserScript(source: BrushTrackStrVersion, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        userBrushTrackController.addUserScript(BrushTrackScrUser)
        userBrushTrackController.add(self, name: "BrushTrack")
        ConfBrushTrack.userContentController = userBrushTrackController
        BrushTrackView = WKWebView(frame: view.frame,  configuration: ConfBrushTrack)
        BrushTrackView?.navigationDelegate = self
        BrushTrackView?.uiDelegate = self
        view.addSubview(BrushTrackView!)
        BrushTrackView!.load(URLRequest(url: URL(string: BrushTrack)!))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BrushTrackManager.shared.isForceBrushTrackManager = false
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue|UIInterfaceOrientation.landscapeLeft.rawValue|UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    @objc private func BrushTrackButtonClicked() {
        BrushTrackBKBlock?()
        dismiss(animated: true, completion: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "BrushTrack" {
            if let BrushTrackMessage = message.body as? [String: Any] {
                let bodyBrushTrack = BrushTrackMessage["name"] as? String ?? ""
                let BrushTrackdata = BrushTrackMessage["data"] as? String ?? ""
                var BrushTrackDictJson = [String: Any]()
                if let BrushTrackUf8 = BrushTrackdata.data(using: .utf8) {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: BrushTrackUf8, options: []) as? [String: Any] {
                            BrushTrackDictJson = jsonObject
                            if (bodyBrushTrack != "openWindow") {
                                BrushTrackshangxin = bodyBrushTrack
                                BrushTrackCharge(bodyBrushTrack, BrushTrackDictJson)
                                Analytics.logEvent(bodyBrushTrack, parameters: BrushTrackDictJson)
                                return
                            }
                            if (BrushTrackshangxin == "rechargeClick") {
                                remind(str: BrushTrackshangxin)
                                BrushTrackshangxin = ""
                                return
                            }
                            let BrushTrackD = BrushTrackDictJson["url"] as? String ?? "";
                            if (!BrushTrackD.isEmpty) {
                                BrushTrackToConttror(BrushTrackD)
                            }
                        }
                    } catch {
                        BrushTrackCharge(bodyBrushTrack, [bodyBrushTrack:BrushTrackUf8])
                        Analytics.logEvent(bodyBrushTrack, parameters: [bodyBrushTrack:BrushTrackUf8])
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if #available(iOS 14.5, *) {
            if navigationAction.shouldPerformDownload {
                decisionHandler(.download, preferences)
                print(navigationAction.request)
                
                webView.startDownload(using: navigationAction.request) {
                    $0.delegate = self
                }
            } else {
                decisionHandler(.allow, preferences)
            }
        } else {
            
        }
    }
    
    func BrushTrackCharge(_ Nub1: String, _ BrushTrackJson: Dictionary<String, Any>) {remind(str: Nub1)
        if (Nub1 == "firstrecharge" || Nub1 == "recharge" || Nub1 == "withdrawOrderSuccess") {
            let BrushTrackA = BrushTrackJson["amount"]
            let cur = BrushTrackJson["currency"]
            if BrushTrackA != nil && cur != nil {
                if let niubi = Double(BrushTrackA as! String) {
                    AppsFlyerLib.shared().logEvent(name: Nub1, values: [AFEventParamRevenue: Nub1 == "withdrawOrderSuccess" ? -niubi: niubi,AFEventParamCurrency:cur!])
                }
            }
        }else {
            AppsFlyerLib.shared().logEvent(Nub1, withValues: BrushTrackJson)
            
        }
    }
    
    func BrushTrackToConttror(_ BrushTrack: String) {
        let homeVC = HYWebController(BrushTrack: BrushTrack)
        homeVC.BrushTrackBKBlock = {
            let ame = "window.closeGame();"
            self.BrushTrackView?.evaluateJavaScript(ame, completionHandler: nil)
        }
        let HomePageViewVC = UINavigationController(rootViewController: homeVC)
        HomePageViewVC.modalPresentationStyle = .fullScreen
        self.present(HomePageViewVC, animated: true)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if (BrushTrackDetailBlock != nil) {
            BrushTrackDetailBlock!(false)
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let BrushTrackMethod = challenge.protectionSpace.authenticationMethod
        
        if BrushTrackMethod == NSURLAuthenticationMethodServerTrust {
            var BrushTrackCredential: URLCredential? = nil
            if let serverTrustForBrushTrack = challenge.protectionSpace.serverTrust {
                BrushTrackCredential = URLCredential(trust: serverTrustForBrushTrack)
            }
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, BrushTrackCredential)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func animateView(_ view: UIView, duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.BrushTrackView?.frame = self.view.frame
        }, completion: nil)
    }
    
    func remind(str: String) {
        let label = UILabel.init(frame: CGRect(x: (UIScreen.main.bounds.size.width-200)/2, y: 300, width: 200 , height: 40));
        label.text = str
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        self.view.addSubview(label)
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.backgroundColor = .black
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            label.removeFromSuperview()
        }
    }

}

class BrushTrackManager: NSObject {
    static var shared: BrushTrackManager = BrushTrackManager()
    var isForceBrushTrackManager: Bool = true
}


