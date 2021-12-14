//
//  ContentView.swift
//  Hours
//
//  Created by Ariel Steiner on 08/12/2021.
//

import SwiftUI
import CoreData

struct HoursView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.day, ascending: false)],
        predicate: Item.thisMonthPred,
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        VStack {
            Group {
                Text("Hours")
                Text(Date(), formatter: titleFormatter)
            }.font(.title)
            Divider()
            NavigationView {
                List {
                    ForEach(items) { item in
                        VStack {
                            HStack {
                                Text(item.day!, formatter: dayFormatter)
                                if let end = item.end, let begin = item.begin {
                                    Text(String(format: "- %.1fh" ,
                                                (end.timeIntervalSince(begin))/3600))
                                }
                            }
                            Group {
                                HStack {
                                    if let begin = item.begin {
                                        Text(begin, formatter: timeFormatter)
                                    } else {
                                        Text("missing")
                                    }
                                    Spacer()
                                    Text("enter")
                                }
                                HStack {
                                    if let end = item.end {
                                        Text(end, formatter: timeFormatter)
                                    } else {
                                        Text("missing")
                                    }
                                    Spacer()
                                    Text("exit")
                                }
                            }
                            .font(.subheadline.smallCaps())
                        }
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.begin = Date() - TimeInterval(3600)
            newItem.end = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let titleFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM YYYY"
    return formatter
}()

private let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE dd/M/yyyy"
    return formatter
}()

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
}()

struct HoursView_Previews: PreviewProvider {
    static var previews: some View {
        HoursView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension Item {
    static var thisMonthPred : NSPredicate {
        let thisMonthComponents = Calendar.current.dateComponents([.year,.month], from: Date())
        let aMonth = DateComponents(month: 1)
        guard let beginningOfMonth = Calendar.current.date(from: thisMonthComponents),
              let endOfMonth = Calendar.current.date(byAdding: aMonth, to: beginningOfMonth) else {
                  return NSPredicate(value: true)
              }
        let pred = NSPredicate(
            format: "begin >= %@ AND begin < %@ OR end >= %@ AND end < %@",
            beginningOfMonth as NSDate, endOfMonth as NSDate,
            beginningOfMonth as NSDate, endOfMonth as NSDate)
        return pred
    }
}
