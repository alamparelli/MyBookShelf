//
//  StatsView.swift
//  MyBookShelf
//
//  Visual statistics and charts showing reading progress
//

import Charts
import SwiftData
import SwiftUI

/// Displays reading statistics with bar and pie chart visualizations
struct StatsView: View {
    enum StatCharts: String, CaseIterable {
        case bar, pie
    }
    
    @State private var selectedView = StatCharts.bar
    @Query var books: [Book]
    
    @Environment(AppDelegate.self) var appDelegate

    
    var inProgress: Int {
        let bookss = books.filter { $0.status == .reading }
        return bookss.count
    }
    
    var completed: Int {
        let bookss = books.filter { $0.status == .read }
        return bookss.count
    }
    
    var notStarted: Int {
        let bookss = books.filter { $0.status == .unread }
        return bookss.count
    }
    
    var stats: [(name: String, count: Int)] {
        return [
            (name: "To Read", count: notStarted),
            (name: "Reading", count: inProgress),
            (name: "Finished", count: completed)
        ]
    }
    
    var body: some View {
        @Bindable var appDelegate = appDelegate
        NavigationStack (path: $appDelegate.navigationPath) {
            VStack {
                if books.isEmpty {
                    NavigationLink {
                        AddBookView()
                    } label: {
                        ContentUnavailableView {
                            Label("Nothing yet here...", systemImage: "book.closed")
                                .foregroundStyle(.accent)
                        } description: {
                            Text("Add a book to start enjoying some statistics.")
                                .foregroundStyle(.accent)
                        }
                    }
                } else {
                    VStack {
                        Picker(selection: $selectedView.animation()) {
                            ForEach(StatCharts.allCases, id: \.self) { view in
                                Text(view.rawValue.capitalized)
                            }
                        } label: {
                            Text("Choose View")
                        }
                        .pickerStyle(.segmented)
                        
                        switch selectedView {
                        case .bar:
                            Chart{
                                BarMark(
                                    x: .value("Total Count", stats[0].count),
                                    y: .value("Shape Type", stats[0].name),
                                    height: 25
                                )
                                .foregroundStyle(.blue)
                                .cornerRadius(10)
                                .annotation(position: .trailing) {
                                    Text("\(stats[0].count)")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                
                                BarMark(
                                    x: .value("Total Count", stats[1].count),
                                    y: .value("Shape Type", stats[1].name),
                                    height: 25
                                )
                                .foregroundStyle(.green)
                                .cornerRadius(10)
                                .annotation(position: .trailing) {
                                    Text("\(stats[1].count)")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                
                                BarMark(
                                    x: .value("Total Count", stats[2].count),
                                    y: .value("Shape Type", stats[2].name),
                                    height: 25
                                )
                                .foregroundStyle(.orange)
                                .cornerRadius(10)
                                .annotation(position: .trailing) {
                                    Text("\(stats[2].count)")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                            .chartLegend(.hidden)
                            .chartXAxis {
                                AxisMarks() { _ in
                                }
                            }
                            .chartYAxis {
                                AxisMarks() { _ in
                                    AxisValueLabel()
                                        .font(.headline)
                                }
                            }
                            .frame(height: 200)
                            .transition(.slide)
                            .padding()
                        case .pie:
                            Chart(stats, id: \.name ) { name, count in
                                SectorMark(
                                    angle: .value("Value", count),
                                    innerRadius: .ratio(0.6),
                                    outerRadius: .inset(10),
                                    angularInset: 1
                                )
                                .foregroundStyle(by: .value("Status Category", name))
                                .annotation (position: .overlay) {
                                    Text("\(count)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                }
                                .cornerRadius(2)
                            }
                            .frame(height: 300)
                            .chartLegend(alignment: .center)
                            .transition(.slide)
                            .padding()
                        }
                        
                        Spacer()
                    }
                    .padding()

                }
            }
            .navigationTitle("Stats")
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationDestination(for: String.self) { book in
                BookDetailView(bookId: book)
            }
            .background(.creamBackground)
        }
    }
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.accent]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.accent]
    }
}

#Preview {
    StatsView()
}
