//
//  TableCell.swift
//  NotificationTest
//
//  Created by ParkJonghyun on 2021/02/24.
//

import UIKit

class TableCell: UITableViewCell {
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(notification:ModelNotification) {
        self.contentLbl.text = notification.content
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd, HH:mm:dd"
        self.dateLbl.text = dateFormat.string(from: notification.date)
    }

}
