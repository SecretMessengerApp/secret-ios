//
//  String+timestamp.swift
//  Wire-iOS
//

import UIKit

extension String {
    
    func getFormatTime() -> String {
        let fullDateFormat = DateFormatter()
        fullDateFormat.timeStyle = .short
        fullDateFormat.dateStyle = .long
        let createDate = fullDateFormat.string(from: Date(timeIntervalSince1970: Double(self) ?? 0))
        return createDate
    }
    

    public var timeStampSeconds: String {
        let date = NSDate()
        let timeInterval: TimeInterval = date.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }

    public var timeStamp: String {
        let date = NSDate()
        let timeInterval: TimeInterval = date.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}


extension Int {
    
    public func formatTime() -> String {
        let m: Int = self % 60
        let f: Int = Int(self/60)
        let currentTiem = f.to02String() + ":\(m.to02String())"
        return currentTiem
    }
    
    func to02String() -> String {
        return String(format: "%02d", self)
    }
}
