//
//  UserViewModel.swift
//  MoyaMVVMSwiftUIApp
//
//  Created by caiwanhong on 2025/8/1.
//

// ViewModel/UserViewModel.swift
import Foundation

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = APIService<UserAPI>()

    @MainActor
    func fetchUsers() async {
        isLoading = true
        do {
            let result = try await service.request(.getUsers, type: [User].self)
            users = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}


