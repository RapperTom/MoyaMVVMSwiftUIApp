//
//  UserAPI.swift
//  MoyaMVVMSwiftUIApp
//
//  Created by caiwanhong on 2025/8/1.
//

// Network/UserAPI.swift
import Moya
import Foundation

enum UserAPI {
    case getUsers
    case getUserDetail(id: Int)
}

extension UserAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }

    var path: String {
        switch self {
        case .getUsers:
            return "/users"
        case .getUserDetail(let id):
            return "/users/\(id)"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var sampleData: Data {
        return Data()
    }
}


