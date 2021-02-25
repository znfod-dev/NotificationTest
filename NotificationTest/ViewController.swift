//
//  ViewController.swift
//  NotificationTest
//
//  Created by ParkJonghyun on 2021/02/24.
//

import UIKit


struct ModelNotification {
    var uuid:UUID
    var title:String
    var content:String
    var date:Date
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contenttextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    var identifierList = Array<UUID>()
    var notificationList = Array<ModelNotification>()
    
    var datePicker:UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        initUI()
        
        userNotificationCenter.delegate = AppDelegate.shared
        requestNotificationAuthorization()
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd, HH:mm"
        let date =  Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        
        let timeString = dateFormat.string(from: date)
        self.dateTextField.text = timeString
        print("timeString : \(timeString)")
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationInBackground), name: NSNotification.Name("ApplicationInBackground"), object: nil)
    }
    
    func initUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let screenWidth = UIScreen.main.bounds.width
        self.datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        self.datePicker.preferredDatePickerStyle = .wheels
        datePicker.timeZone = NSTimeZone.local
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .dateAndTime
        self.dateTextField.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneBtnClicked))
        toolBar.setItems([flexible, done], animated: false)
        self.dateTextField.inputAccessoryView = toolBar
    }
    
    @objc func applicationInBackground(_ notification:Notification) {
        for notification in self.notificationList {
            self.removeNotification(notification)
        }
        self.tableView.reloadData()
    }
    
    @objc func doneBtnClicked() {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd, HH:mm"
        let timeString = dateFormat.string(from: self.datePicker.date)
        self.dateTextField.text = timeString
        self.view.endEditing(true)
        
    }
    
    
    @IBAction func addBtnClicked(_ sender:UIButton) {
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd, HH:mm"
        guard let dateText = self.dateTextField.text, let date = dateFormat.date(from: dateText) else {
            return
        }
        self.contenttextField.text = "Content"
        guard let content = self.contenttextField.text else {
            return
        }
        if content == "" {
            return
        }
        self.titleTextField.text = "Title"
        guard let title = self.titleTextField.text else {
            return
        }
        if title == "" {
            return
        }
        let notification = ModelNotification(uuid: UUID.init(), title: title, content: content, date: date)
        self.sendNotification(notification)
        self.tableView.reloadData()
    }

    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error : \(error)")
            }
        }
    }
    
    func sendNotification(_ notification:ModelNotification) {
        let seconds:Double = notification.date.timeIntervalSince1970 - Date().timeIntervalSince1970
        print("seconds : \(seconds)")
        if seconds < 30 {
            let alert = UIAlertController(title: "알림", message: "30초 미만입니다.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = notification.title
        notificationContent.body = notification.content
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: notification.uuid.uuidString, content: notificationContent, trigger: trigger)
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: \(error)")
                self.notificationList.removeAll(where: { notification.uuid == $0.uuid })
                let alert = UIAlertController(title: "", message: "등록에 실패하였습니다.", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.notificationList.append(notification)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func removeNotification(_ notification:ModelNotification) {
        self.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [notification.uuid.uuidString])
        self.notificationList.removeAll(where: { notification.uuid == $0.uuid })
    }
    

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableCell
        let notification = self.notificationList[indexPath.row]
        cell.setData(notification: notification)
        return cell
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let identifier = notification.request.identifier
        
        completionHandler([.banner, .badge, .sound])
    }
}
