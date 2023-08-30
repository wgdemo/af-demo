import UIKit
import SwiftUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let kecVC = HYWebController(BrushTrack: "https://web2023web.cg.vin")
    kecVC.modalPresentationStyle = .fullScreen
        kecVC.BrushTrackDetailBlock = { isYulai in
            if (!isYulai) {
                self.dismiss(animated: true)
            }
        }
        self.present(kecVC, animated: true)
    }

}

