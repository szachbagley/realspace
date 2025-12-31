//
//  CommunityView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

struct CommunityView: View {
    @Binding var selectedTab: String
    @StateObject private var viewModel = CommunityViewModel()
    @EnvironmentObject var authManager: AuthManager

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

            // Error message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            // Events feed
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.events, id: \.id) { event in
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

                                        Text(event.entity.name)
                                            .font(.postBody)
                                            .foregroundColor(.secondary)
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
                                HStack(spacing: 5) {
                                    Image(systemName: "mappin.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text(event.entity.address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
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
            }
            .refreshable {
                await viewModel.loadEvents()
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
        .task {
            await viewModel.loadEvents()
            await viewModel.loadEntities()
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = "Community"

    CommunityView(selectedTab: $selectedTab)
        .environmentObject(AuthManager.shared)
}
