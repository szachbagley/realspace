//
//  ListView.swift
//  realspace
//
//  Created by Zach Bagley on 10/3/25.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Binding var selectedTab: String
    @State private var viewModel = ListViewModel()
    @Query(sort: \ListItem.createdAt, order: .reverse) private var listItems: [ListItem]
    @Query(sort: \User.createdAt) private var users: [User]
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

                // Add button
                HStack {
                    Spacer()
                    Button(action: createListItem) {
                        Text("Add")
                            .font(.postBody)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(.black))
                    }
                    .disabled(!canAdd)
                    .opacity(canAdd ? 1.0 : 0.5)
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
                    LazyVStack(spacing: 15) {
                        ForEach(listItems) { item in
                            HStack(spacing: 5) {
                                Text(item.action)
                                    .font(.postBody)

                                Text(item.subject)
                                    .font(.postBody)
                                    .fontWeight(.bold)

                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .border(.black, width: 0.5)
                        }
                    }
                    .padding()
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
        .onAppear {
            viewModel.configure(with: modelContext)
        }
    }

    // MARK: - Helper Functions

    private var canAdd: Bool {
        !viewModel.itemSubject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func getCurrentUser() -> User {
        // Try to get an existing user, or create a sample user
        if let existingUser = users.first {
            return existingUser
        } else {
            let newUser = User(username: "sampleuser", displayName: "Sample User")
            modelContext.insert(newUser)
            try? modelContext.save()
            return newUser
        }
    }

    private func createListItem() {
        guard canAdd else { return }

        let user = getCurrentUser()

        let listItem = ListItem(
            action: viewModel.selectedAction,
            subject: viewModel.itemSubject,
            user: user
        )

        modelContext.insert(listItem)

        do {
            try modelContext.save()
            clearForm()
        } catch {
            print("Error saving list item: \(error)")
        }
    }

    private func clearForm() {
        viewModel.itemSubject = ""
        viewModel.selectedAction = "watch"
    }
}

// Preview wrapper to provide binding
private struct ListViewPreview: View {
    @State private var selectedTab = "List"

    var body: some View {
        ListView(selectedTab: $selectedTab)
    }
}

#Preview {
    ListViewPreview()
        .modelContainer(.preview)
}
