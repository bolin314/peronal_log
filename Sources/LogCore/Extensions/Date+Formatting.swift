import Foundation

extension Date {
    public var shortDisplay: String {
        formatted(date: .abbreviated, time: .shortened)
    }

    public var timeOnly: String {
        formatted(date: .omitted, time: .shortened)
    }

    public var relativeDayDisplay: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return formatted(date: .abbreviated, time: .omitted)
        }
    }
}
