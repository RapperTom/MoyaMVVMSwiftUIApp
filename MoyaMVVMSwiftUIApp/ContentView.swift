//
//  ContentView.swift
//  MoyaMVVMSwiftUIApp
//
//  Created by caiwanhong on 2025/8/1.
//

// View/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("加载中...")
                } else if let error = viewModel.errorMessage {
                    Text("错误：\(error)")
                        .foregroundColor(.red)
                } else {
                    List(viewModel.users) { user in
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("用户列表")
        }
        .task {
            await viewModel.fetchUsers()
        }
    }
}


#Preview {
    ContentView()
}
