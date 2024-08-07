//
//  HorizontalBarChart.swift
//  PokeDex
//
//  Created by Maraj Hossain on 7/8/24.
//

import Charts
import SwiftUI

private struct Entry: Identifiable {
    var id = UUID()
    let stat: String
    let start: Int
    let end: Int

//    let id = UUID()
//    let period: String
//    let amount: Int
}

struct HorizontalBarChart: View {
    fileprivate let data: [Entry] = [
        .init(stat: "HP", start: 50, end: 100),
        .init(stat: "HP", start: 60, end: 100)
//        .init(period: "Today", start: 50, ),
//        .init(period: "This Week", amount: 60),
//        .init(period: "This Month", amount: 65)
    ]

    var body: some View {
        GroupBox {
            Chart(data) { item in
                BarMark(
                    x: .value("HP", <#T##value: Plottable##Plottable#>)
                    x: .value("Amount", item.amount),
                    y: .value("Period", item.period),
                    width: .fixed(8)
                )
//                .annotation(position: .trailing) {
//                    Text(item.amount.formatted())
//                        .foregroundColor(.secondary)
//                        .font(.caption)
//                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.footnote)
                }
            }
        }
    }
}

struct HorizontalBarChart_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalBarChart()
    }
}
