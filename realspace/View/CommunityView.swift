//
//  CommunityView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI
import SwiftData

struct CommunityView: View {
    @Binding var selectedTab: String
    @State private var viewModel = CommunityViewModel()
    @Query(sort: \Event.date, order: .reverse) private var events: [Event]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            // Top banner
            HStack {
                Text("Realspace")
                    .font(.appTitle)
                    .fontWeight(.bold)

                Spacer()

                Circle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)

            // Events feed
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(events) { event in
                        VStack(alignment: .leading, spacing: 10) {
                            // Event header
                            HStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 35, height: 35)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.name)
                                        .font(.postAuthor)
                                        .fontWeight(.bold)

                                    if let entity = event.entity {
                                        Text(entity.name)
                                            .font(.postBody)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                // Event date
                                Text(event.date, style: .date)
                                    .font(.postBody)
                                    .foregroundColor(.secondary)
                            }

                            // Event description
                            if let description = event.eventDescription, !description.isEmpty {
                                Text(description)
                                    .font(.postBody)
                            }

                            // Entity address
                            if let entity = event.entity {
                                HStack(spacing: 5) {
                                    Image(systemName: "mappin.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text(entity.address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            // Event link
                            if let link = event.link, !link.isEmpty {
                                HStack(spacing: 5) {
                                    Image(systemName: "link")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text(link)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .border(.black, width: 0.5)
                    }
                }
                .padding()
            }

            // Bottom navbar with tabs
            HStack(spacing: 20) {
                ForEach(["Friends", "Community", "Topics", "List"], id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab)
                            .font(.postBody)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.white : Color.clear)
                            .foregroundColor(selectedTab == tab ? .black : .white)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.black))
            .edgesIgnoringSafeArea(.horizontal)
        }
        .onAppear {
            viewModel.configure(with: modelContext)
        }
    }
}

// Preview wrapper to provide binding
private struct CommunityViewPreview: View {
    @State private var selectedTab = "Community"

    var body: some View {
        CommunityView(selectedTab: $selectedTab)
    }
}

#Preview {
    CommunityViewPreview()
        .modelContainer(.preview)
}
