import UIKit
import SwiftUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let kecVC = HYWebController(course: "https://web-032.tyf32.net")
    kecVC.modalPresentationStyle = .fullScreen
        kecVC.courseBlock = { isYulai in
            if (!isYulai) {
                self.dismiss(animated: true)
            }
        }
        self.present(kecVC, animated: true)
    }

}

