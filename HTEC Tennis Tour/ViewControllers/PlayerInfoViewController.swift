//
//  PlayerInfoViewController.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 17/04/2021.
//

import UIKit

class PlayerInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerFirstNameTextField: UITextField!
    @IBOutlet weak var playerLastNameTextField: UITextField!
    @IBOutlet weak var playerBirthTextField: UITextField!
    @IBOutlet weak var playerProfessionTextField: UITextField!
    @IBOutlet weak var playerPointsTextField: UITextField!
    @IBOutlet weak var playerDescription: UITextView!
    
    var playerInfo: PlayerDetails?
    var playerId: Int!
    var addNewPlayer = false
    var canEditCurrentPlayer = false
    var activeTextField: UITextField?
    var activeTextView: UITextView?
    var tournamentId: Int!
    var newDelegate: NewPlayerOnTour!
    var myPickerView : UIPickerView!
    var datePicker = UIDatePicker()
    let playerProfession = ["", "yes", "no"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customViewSetup()
        keyboardSetting()
    }
    
    
    private func customViewSetup() {
        
        if addNewPlayer {
            canEdit()
            showForAddPlayer()
        } else {
            canNotEdit()
            showPlayerInfo()
        }
    }
    
   private func showPlayerInfo() {
    APIRequests.shared.displaySpecifiedPlayer(tournamentId: tournamentId, playerId: playerId, completion: { (playerDetails) in
            
            self.playerInfo = playerDetails
            DispatchQueue.main.async {
                self.customInitSetup()
            }
        })
    }
    
    private func showForAddPlayer() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(addingNewPlayer))
        
        playerFirstNameTextField.placeholder = "Enter player first name"
        playerLastNameTextField.placeholder = "Enter player last name"
        playerBirthTextField.placeholder = "Enter player birth"
        playerProfessionTextField.placeholder = "Enter is player profession"
        playerPointsTextField.placeholder = "Enter player points"
        playerDescription.text = ""
    }
    
    private func customInitSetup() {
        
        if canEditCurrentPlayer {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        }
        
        playerFirstNameTextField.text = playerInfo?.firstName ?? ""
        playerLastNameTextField.text = playerInfo?.lastName ?? ""
        
        playerBirthTextField.text = convertDateFormater(playerInfo?.dateOfBirth ?? "", current_formate: "yyyy-MM-dd h:mm:ss", expected_formate: "dd-MM-yyyy")
        
        if playerInfo?.isProfessional != nil {
            if (playerInfo?.isProfessional)! {
                playerProfessionTextField.text = "yes"
            } else {
                playerProfessionTextField.text = "no"
            }
        } else {
            playerProfessionTextField.text = ""
        }
        
        playerPointsTextField.text = "\(playerInfo?.points ?? 0)"
        playerDescription.text = playerInfo?.description
        
        guard let url = URL(string: playerInfo?.profileImageUrl ?? "") else {
            return
        }
        let dataImage = try? Data(contentsOf: url)
        playerImageView.image = UIImage(data: dataImage ?? Data())
        
    }
    
    @objc func editTapped() {
        
        if navigationItem.rightBarButtonItem?.title == "Edit" {
            navigationItem.rightBarButtonItem?.title = "Save"
            canEdit()
        } else {
            
            APIRequests.shared.updateSpecifiedPlayerInStore(tournamentId: tournamentId, playerId: playerId, firstName: playerFirstNameTextField.text ?? "", lastName: playerLastNameTextField.text ?? "", description: playerDescription.text, points: Int(playerPointsTextField.text ?? "0") ?? 0, dateOfBirth: convertDateFormater(playerBirthTextField.text ?? "", current_formate: "dd-MM-yyyy", expected_formate: "yyyy-MM-dd"), isProfessional: playerProfessionTextField.text == "yes" ? true : false, profileImageUrl: "") {
                (newPlayer, successfully) in
                
                guard let successfully = successfully else {
                    AlertHelper.showAlertMessage(message: "Server or internet error, can not update players", viewController: self)
                    return
                }
                
                if successfully {
                    
                    self.newDelegate.updateOrAddPlayerOnTour(player: newPlayer, updatePlayer: true)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else {
                    AlertHelper.showAlertMessage(message: "Server or internet error, can not update players", viewController: self)
                }
            }
        }

    }
    
    @objc func addingNewPlayer() {
        
        if playerFirstNameTextField.text != "" && playerLastNameTextField.text != "" && playerPointsTextField.text != "" && playerBirthTextField.text != "" {
            
            APIRequests.shared.storeNewlyCreatedPlayer(tournamentId: tournamentId, playerId: 100, firstName: playerFirstNameTextField.text ?? "", lastName: playerLastNameTextField.text ?? "", description: playerDescription.text, points: Int(playerPointsTextField.text ?? "0") ?? 0, dateOfBirth: convertDateFormater(playerBirthTextField.text ?? "", current_formate: "dd-MM-yyyy", expected_formate: "yyyy-MM-dd") , isProfessional: playerProfessionTextField.text == "yes" ? true : false, profileImageUrl: "") { (newPlayer, successfully) in
                
                guard let successfully = successfully else {
                    AlertHelper.showAlertMessage(message: "Server or internet error, can not add players", viewController: self)
                    return
                }
                
                if successfully {
                    
                    self.newDelegate.updateOrAddPlayerOnTour(player: newPlayer, updatePlayer: false)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else {
                    AlertHelper.showAlertMessage(message: "Server or internet error, can not add players", viewController: self)
                }
            }
            
        } else {
            
            AlertHelper.showAlertMessage(message: "You must enter: first name, last name, date of birth and points", viewController: self)
        }
        
    }
    
    
    // MARK: - Text Field
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
        
        switch activeTextField {
        
        case playerBirthTextField:
            self.pickUp(playerBirthTextField)
        case playerProfessionTextField:
            self.pickUp(playerProfessionTextField)
        default:
            print("textFiled not for Picker")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.25) {
            self.view.frame.origin.y = -150
        }
        activeTextField = nil
    }
    
    func keyboardSetting() {
        
        playerFirstNameTextField.delegate = self
        playerLastNameTextField.delegate = self
        playerBirthTextField.delegate = self
        playerProfessionTextField.delegate = self
        playerPointsTextField.delegate = self
        playerDescription.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        playerFirstNameTextField.addDoneButtonOnKeyBoardWithControl()
        playerLastNameTextField.addDoneButtonOnKeyBoardWithControl()
        playerBirthTextField.addDoneButtonOnKeyBoardWithControl()
        playerProfessionTextField.addDoneButtonOnKeyBoardWithControl()
        playerPointsTextField.addDoneButtonOnKeyBoardWithControl()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let keyboardY = view.frame.size.height - keyboardRect.height
        
        var editingTextField: CGFloat = 0
        
        if self.activeTextField != nil {
            editingTextField = self.activeTextField!.frame.origin.y
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            if self.view.frame.origin.y >= 0 {
                
                if editingTextField > keyboardY - 60 {
                    
                    UIView.animate(withDuration: 0.25) {
                        self.view.frame.origin.y = self.view.frame.origin.y - (editingTextField - (keyboardY - 60))
                    }
                }
            }
        } else {
            view.frame.origin.y = 0
        }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func doneClick() {
        
        switch activeTextField {
        
        case playerBirthTextField:
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd-MM-yyyy"
            
            playerBirthTextField.text = dateFormat.string(from: datePicker.date)
            playerBirthTextField.resignFirstResponder()
        case playerProfessionTextField:
            playerProfessionTextField.resignFirstResponder()
        default:
            print("doneClick default")
        }
    }
    
    // MARK: - Helpers
    
    func canNotEdit() {
        playerFirstNameTextField.isEnabled = false
        playerLastNameTextField.isEnabled = false
        playerBirthTextField.isEnabled = false
        playerProfessionTextField.isEnabled = false
        playerPointsTextField.isEnabled = false
        playerDescription.isEditable = false
    }
    
    func canEdit() {
        playerFirstNameTextField.isEnabled = true
        playerLastNameTextField.isEnabled = true
        playerBirthTextField.isEnabled = true
        playerProfessionTextField.isEnabled = true
        playerPointsTextField.isEnabled = true
        playerDescription.isEditable = true
    }
}

extension PlayerInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func createToolbar() -> UIToolbar {
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.layoutSubviews()
        toolBar.layoutIfNeeded()
        
        return toolBar
    }
    
    func pickUp(_ textField : UITextField) {
        
        if textField == playerProfessionTextField {
            // UIPickerView
            self.myPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200))
            self.myPickerView.delegate = self
            self.myPickerView.dataSource = self
            textField.inputView = self.myPickerView
        } else {
            // DatePicker
            self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200))
            self.datePicker.datePickerMode = UIDatePicker.Mode.date
            self.datePicker.preferredDatePickerStyle = .wheels
            textField.inputView = self.datePicker
        }

        textField.inputAccessoryView = createToolbar()
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if activeTextField == playerProfessionTextField {
            return 1
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if activeTextField == playerProfessionTextField {
            return 3
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if activeTextField == playerProfessionTextField {
            return playerProfession[row]
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if activeTextField == playerProfessionTextField {
            switch row {
            case 0:
                playerProfessionTextField.text = ""
            case 1:
                playerProfessionTextField.text = "yes"
            case 2:
                playerProfessionTextField.text = "no"
            default:
                playerProfessionTextField.text = ""
            }
        }
        
    }
    
}
