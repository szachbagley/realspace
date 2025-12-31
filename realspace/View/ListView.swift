//
//  ListView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI

struct ListView: View {
    @Binding var selectedTab: String
    @StateObject private var viewModel = ListViewModel()
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

            // Description text
            VStack(alignment: .leading, spacing: 5) {
                Text("Your Personal Wishlist")
                    .font(.postAuthor)
                    .fontWeight(.bold)
                Text("Track things you want to watch, read, or visit. Make items public to share them on your profile and inspire others.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // Add item field
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 5) {
                    Text("I want to")
                        .font(.postBody)

                    Menu {
                        ForEach(viewModel.actions, id: \.self) { action in
                            Button(action) {
                                viewModel.selectedAction = action
                            }
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Text(viewModel.selectedAction)
                                .font(.postBody)
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.black))
                    }

                    TextField("subject", text: $viewModel.itemSubject)
                        .font(.postBody)
                        .textFieldStyle(PlainTextFieldStyle())
                }

                // Share toggle
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isPublic ? "globe" : "lock.fill")
                        .font(.caption)
                        .foregroundColor(viewModel.isPublic ? .blue : .gray)

                    Toggle(isOn: $viewModel.isPublic) {
                        Text(viewModel.isPublic ? "Public - Visible on your profile" : "Private - Only you can see this")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }

                // Add button
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await viewModel.createListItem()
                        }
                    } label: {
                        if viewModel.isCreatingItem {
                            ProgressView()
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                        } else {
                            Text("Add")
                                .font(.postBody)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color(.black))
                        }
                    }
                    .disabled(viewModel.isCreatingItem || !viewModel.canCreateItem)
                    .opacity(viewModel.canCreateItem && !viewModel.isCreatingItem ? 1.0 : 0.5)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .border(.black, width: 0.5)
            .padding(.horizontal)
            .padding(.top, 15)

            // List items
            VStack(alignment: .leading, spacing: 10) {
                Text("I want to...")
                    .font(.postAuthor)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 20)

                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.listItems, id: \.id) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 5) {
                                        Text(item.action)
                                            .font(.postBody)

                                        Text(item.subject)
                                            .font(.postBody)
                                            .fontWeight(.bold)

                                        Spacer()

                                        // Public/Private indicator
                                        Image(systemName: item.isPublic ? "globe" : "lock.fill")
                                            .font(.caption2)
                                            .foregroundColor(item.isPublic ? .blue : .gray)

                                        Button {
                                            Task {
                                                await viewModel.deleteListItem(item)
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.caption)
                                                .foregroundColor(.red)
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
                    await viewModel.loadListItems()
                }
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
            await viewModel.loadListItems()
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = "List"

    ListView(selectedTab: $selectedTab)
        .environmentObject(AuthManager.shared)
}
