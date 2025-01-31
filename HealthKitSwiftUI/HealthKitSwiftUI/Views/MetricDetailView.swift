//
//  MetricDetailView.swift
//  HealthKitSwiftUI
//
//  Created by Biswajyoti Saha on 29/01/25.
//

import Charts
import SwiftUI

struct MetricDetailView: View {
    @StateObject var healthKit: HealthKitManager = .shared
    let metric: HealthMetric
    @State private var selectedData: ChartData?
    
    var records: [HealthRecord] {
        healthKit.healthData[metric] ?? []
    }
    
    var body: some View {
        VStack {
            Chart(records) { record in
                BarMark(
                    x: .value("Date", record.date, unit: .day),
                    y: .value("Value", record.value)
                )
                .foregroundStyle(metric.color.gradient)
            }
            .frame(height: 200)
            .padding()
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(.rect)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    onDragChangeInChart(value, proxy: proxy, geometry: geometry)
                                }
                                .onEnded { _ in
                                    selectedData = nil
                                }
                        )
                    if let selected = selectedData {
                        chartBubble(selected, geometry)
                    }
                }
            }
            List(records) { record in
                HStack {
                    Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                    Text("\(Int(record.value)) \(metric.unit)")
                        .foregroundStyle(metric.color)
                }
                .navigationTitle(metric.rawValue)
                .refreshable {
                    await healthKit.fetchData(for: metric)
                }
            }
        }
    }
    
    private func findClosestRecord(at xPosition: CGFloat, proxy: ChartProxy, size: CGSize) -> HealthRecord? {
        let plotWidth = size.width
        let barWidth = plotWidth / CGFloat(records.count)
        
        var closestRecord: HealthRecord?
        var minDistance: CGFloat = .infinity
        for record in records {
            guard let xPos = proxy.position(forX: record.date) else {continue}
            
            let barCenter = xPos + (barWidth / 2)
            let distance = abs(barCenter - xPosition)
            if distance < minDistance {
                minDistance = distance
                closestRecord = record
            }
        }
        return closestRecord
    }
    
    private func onDragChangeInChart(_ value: DragGesture.Value, proxy: ChartProxy, geometry: GeometryProxy){
        let xPosition = value.location.x
        if let record = findClosestRecord(at: xPosition, proxy: proxy, size: geometry.size) {
            let plotWidth = geometry.size.width
            let barWidth = plotWidth / CGFloat(records.count)
            let barX = (proxy.position(forX: record.date) ?? 0) + (barWidth / 2)
            let barHeight = proxy.position(forY: 0)! - (proxy.position(forY: record.value) ?? 0)
            
            selectedData = ChartData(date: record.date, values: record.value, barX: barX, barHeight: barHeight)
        }
    }
    
    private func chartBubble(_ selected: ChartData, _ geometry: GeometryProxy) -> some View {
        Group {
            Rectangle()
                .fill(metric.color.opacity(0.8))
                .frame(width: 2)
                .position(x: selected.barX, y: geometry.size.height / 2)
                .frame(height: geometry.size.height)
            VStack {
                Text(selected.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(metric.color)
                Text("\(Int(selected.values)) \(metric.unit)")
                    .font(.headline)
                    .foregroundStyle(metric.color)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8, style: . continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 2)
            }
            .position(
                x: selected.barX,
                y: max(40, geometry.size.height - selected.barHeight - 50)
            )
        }
    }
}

//#Preview {
//    MetricDetailView()
//}
