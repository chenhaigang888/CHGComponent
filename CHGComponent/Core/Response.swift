//
//  Response.swift
//  Response
//
//  Created by hogan on 2021/7/28.
//

import Foundation

/// 请求错误码，模块应该避开此状态码
enum ErrResultCode:Int {
    case targetNotFound = 404 //请求的Target不存在
    case methodNotFound = 405 //请求的方法不存在
}

/// 返回结果协议
public protocol ResponseProtocol {
    associatedtype T: Codable
    
    /// 客户模块请求码，主要用来标记客户模块自己的请求，客户模块发送什么就返回什么
    var requestCode: Int { get set }
    
    /// 结果码,服务模块返回
    var resultCode: Int { get set }
    
    /// 服务模块返回的数据
    var resultData: T? { get set }
    
}

/// 返回结果
public struct Response<T: Codable>: ResponseProtocol {
    public var requestCode: Int
    
    public var resultCode: Int
    
    public var resultData: T?
    
    public typealias T = T
    
    
}
