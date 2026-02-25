//
//  SettingsViewController.swift
//  iQuiz
//
//  Created by Joseph Tran on 2/24/26.
//

import Foundation
import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsDidRequestRefresh()
}

final class SettingsViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!

    weak var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"

        urlTextField.text = AppSettings.quizURLString
        urlTextField.keyboardType = .URL
        urlTextField.autocapitalizationType = .none
        urlTextField.autocorrectionType = .no
        urlTextField.clearButtonMode = .whileEditing
    }

    @IBAction func didTapCheckNow(_ sender: Any) {
        let urlString = (urlTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !urlString.isEmpty, URL(string: urlString) != nil else {
            showAlert(title: "Invalid URL", message: "Enter a valid URL.")
            return
        }

        AppSettings.quizURLString = AppSettings.normalizedURLString(urlTextField.text ?? "")
        delegate?.settingsDidRequestRefresh()
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
