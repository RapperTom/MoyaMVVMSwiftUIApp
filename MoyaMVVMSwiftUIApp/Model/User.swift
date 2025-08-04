//
//  User.swift
//  MoyaMVVMSwiftUIApp
//
//  Created by caiwanhong on 2025/8/1.
//

// Model/User.swift
import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
}

