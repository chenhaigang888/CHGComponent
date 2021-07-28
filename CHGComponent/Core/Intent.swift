//
//  Intent.swift
//  Intent
//
//  Created by hogan on 2021/7/23.
//

import Foundation

/// 意图
open class Intent {
    
    public typealias ResponseBlock = (_ response: Response<Data>)->Void
    
    /// 打开页面的方式
    public enum OpenWay {
        case push
        case present
    }
    
    public init(parent: OpenBase? = nil,
                targetClass: String,
                method: String? = nil,
                requestCode: Int? = 0,
                openWay: OpenWay? = .present,
                animated: Bool? = true,
                responseBlock: ResponseBlock? = nil) {
        self.parent = parent
        self.method = method
        self.requestCode = requestCode
        self.openWay = openWay
        self.animated = animated
        self.responseBlock = responseBlock
        if let cls = NSClassFromString(targetClass) {
            self.target = cls
        }
    }
    
    /// 当前
    open var parent: Any?
    
    /// 需要打开的页面的类
    open var target: AnyClass?
    
    open var method: String?
    
    /// 是否显示动画
    open var animated: Bool?
    
    /// 用于标记被请求对象（不限于ViewController）
    open var requestCode: Int?
    
    /// 被请求对象返回的结果码
    open var resultCode: Int?
    
    /// 需要向目标（不限于ViewController）传递的参数
    private var params: Data?
    
    /// 返回数据的block
    open var responseBlock: ResponseBlock?
    
    /// 打开方式
    open var openWay: OpenWay? = .present
    
    /// 对需要传递的参数进行处理
    open func setParams<Params: Codable>(params: Params) {
        self.params = try? JSONEncoder().encode(params)
    }
    
    /// 将传递的参数转换成需要的类型
    /// - Returns: 
    open func getParams<T:Codable>(t: T.Type) -> T? {
        guard let params = params else { return nil }
        return try? JSONDecoder().decode(t.self, from: params)
    }
}




