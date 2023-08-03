import UIKit
import WebKit
import AppsFlyerLib

typealias CourseViewControllerBlock = (Bool) -> Void
typealias WurenBlock = () -> Void

class HYWebController: UIViewController,WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var courseBlock: CourseViewControllerBlock?
    var wurenBlock: WurenBlock?
    private var courseView: WKWebView?
    var shangxin = ""
    @objc init(course: String) {
        super.init(nibName: nil, bundle: nil)
        navigationController?.navigationBar.barTintColor = .systemBlue
        navigationController?.navigationBar.tintColor = .white
        let jinwanButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(lenyuButtonClicked))
        navigationItem.rightBarButtonItem = jinwanButton
        let dengni = WKWebViewConfiguration()
        let dangtianController = WKUserContentController()
        let futoung = "window.jsBridge = {\n    postMessage: function(name, data) {\n        window.webkit.messageHandlers.Course.postMessage({name, data})\n    }\n};\n"
        let youdian = WKUserScript(source: futoung, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        dangtianController.addUserScript(youdian)
        dangtianController.add(self, name: "Course")
        dengni.userContentController = dangtianController
        courseView = WKWebView(frame: view.frame,  configuration: dengni)
        courseView?.navigationDelegate = self
        courseView?.uiDelegate = self
        view.addSubview(courseView!)
        courseView!.load(URLRequest(url: URL(string: course)!))
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.courseView?.frame = self.view.frame
        }, completion: nil)
    }
    
    @objc private func lenyuButtonClicked() {
        wurenBlock?()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CourseManager.shared.isForcePortrait = false
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue|UIInterfaceOrientation.landscapeLeft.rawValue|UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "Course" {
            if let body = message.body as? [String: Any] {
                let yang = body["name"] as? String ?? ""
                let fengzhong = body["data"] as? String ?? ""
                var gang = [String: Any]()
                if let taoyan = fengzhong.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: taoyan, options: []) as? [String: Any] {
                            gang = json
                            if (yang != "openWindow") {
                                shangxin = yang
                                paoying(yang, gang)
                                return
                            }
                            if (shangxin == "rechargeClick") {remind(str: "充值")
                                shangxin = ""
                                return
                            }
                            let ting = gang["url"] as? String ?? "";
                            if (!ting.isEmpty) {
                                wangdiaoyu(ting)
                            }
                        }
                        
                    } catch {
                        paoying(yang, [yang:taoyan])
                    }
                }
            }
        }
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
    
    func paoying(_ zouguo: String, _ lang: Dictionary<String, Any>) {
        if (zouguo == "firstrecharge" || zouguo == "recharge" || zouguo == "withdrawOrderSuccess") {
            let xunh = lang["amount"]
            let zhang = lang["currency"]
            if xunh != nil && zhang != nil {
                if let heng = Double(xunh as! String) {remind(str: "首充，充值，提现")
                    AppsFlyerLib.shared().logEvent(name: zouguo, values: [AFEventParamRevenue: zouguo == "withdrawOrderSuccess" ? -heng: heng,AFEventParamCurrency:zhang!])
                }
            }
        }else {remind(str: "其他")
            AppsFlyerLib.shared().logEvent(zouguo, withValues: lang)
        }
    }
    
    func wangdiaoyu(_ buzhijieguo: String) {
        let wanzhegVC = HYWebController(course: buzhijieguo)
        wanzhegVC.wurenBlock = {
            let heiwo = "window.closeGame();"
            self.courseView?.evaluateJavaScript(heiwo, completionHandler: nil)
        }
        let xueyouController = UINavigationController(rootViewController: wanzhegVC)
        xueyouController.modalPresentationStyle = .fullScreen
        self.present(xueyouController, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if (courseBlock != nil) {
            courseBlock!(false)
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let authentisaMethod = challenge.protectionSpace.authenticationMethod
        if authentisaMethod == NSURLAuthenticationMethodServerTrust {
            var credential: URLCredential? = nil
            if let serverTrust = challenge.protectionSpace.serverTrust {
                credential = URLCredential(trust: serverTrust)
            }
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func animateView(_ view: UIView, duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion)
    }
}


class CourseManager: NSObject {
    static var shared: CourseManager = CourseManager()
    var isForcePortrait: Bool = true
}

