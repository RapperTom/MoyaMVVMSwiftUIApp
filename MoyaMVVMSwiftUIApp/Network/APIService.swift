//
//  APIService.swift
//  MoyaMVVMSwiftUIApp
//
//  Created by caiwanhong on 2025/8/1.
//

// Network/APIService.swift
import Moya
import Foundation

/// 网络请求相关错误枚举
enum APIError: Error {
    /// HTTP 响应状态码不在成功范围（200...299）时返回，携带具体状态码
    case invalidStatusCode(Int)
    
    /// JSON 解析失败时返回，携带具体的解码错误信息
    case decodingError(DecodingError)
    
    /// 网络请求本身失败时返回，比如断网、超时等，携带底层错误
    case networkError(Error)
    
    /// 其他未知错误的兜底，携带错误信息
    case unknown(Error)
}

class APIService<T: TargetType> {
    // 1. 定义了一个 MoyaProvider，负责实际发起网络请求
    private let provider: MoyaProvider<T>

    // 2. JSON 解码器，配置了常用的解码策略
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase  // 下划线转驼峰
        decoder.dateDecodingStrategy = .iso8601              // ISO8601 格式的日期字符串自动转 Date
        return decoder
    }()

    // 3. 初始化方法，允许传入 stub 参数，控制是否用模拟数据
    init(stub: Bool = false) {
        if stub {
            // 4. 如果是测试模式，使用立即返回模拟数据的 provider
            provider = MoyaProvider<T>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            // 5. 否则使用默认的 provider，正常发起网络请求
            provider = MoyaProvider<T>()
        }
    }

    // 6. 发送请求的异步方法，支持 await 调用，返回泛型 D，要求遵守 Decodable
    func request<D: Decodable>(_ target: T, type: D.Type) async throws -> D {
        // 7. 使用 Swift 的 async/await 的桥接，将回调包装成异步函数
        try await withCheckedThrowingContinuation { continuation in
            // 8. 调用 MoyaProvider 发起请求，传入 target（API 路径、参数等）
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    // 9. 判断 HTTP 状态码是否是 2xx，非 2xx 就抛错
                    guard (200...299).contains(response.statusCode) else {
                        continuation.resume(throwing: APIError.invalidStatusCode(response.statusCode))
                        return
                    }
                    do {
                        // 10. 用 JSONDecoder 把服务器返回的 Data 解码成模型 D
                        let decoded = try self.decoder.decode(D.self, from: response.data)
                        // 11. 成功就通过 continuation 把结果返回给调用者
                        continuation.resume(returning: decoded)
                    } catch let decodingError as DecodingError {
                        // 12. 解码出错，包装成 decodingError 抛出
                        continuation.resume(throwing: APIError.decodingError(decodingError))
                    } catch {
                        // 13. 其他错误用 unknown 包装抛出
                        continuation.resume(throwing: APIError.unknown(error))
                    }
                case .failure(let error):
                    // 14. 请求失败，网络错误包装抛出
                    continuation.resume(throwing: APIError.networkError(error))
                }
            }
        }
    }
}

