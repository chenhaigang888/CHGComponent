//
//  OpenBase.swift
//  OpenBase
//
//  Created by hogan on 2021/7/23.
//

import UIKit

public typealias ResponseBlock<Result: Codable> = (_ response: Response<Result>)->Void

/// controller基础协议
public protocol OpenBase {
    
    /// 意图对象
    var intent: Intent? { get set }
    
    /// 设置返回码和返回结果
    func setResult<ResultData: Codable>(resultCode: Int?, resultData: ResultData?)
    
    /// 请求一个目标对象
    func request(with targetIntent: Intent)
    
    /// 请求一个目标对象
    func request<Result: Codable>(with targetIntent: Intent, resultType: Result.Type, for responseBlock: ResponseBlock<Result>?)

}


private var intentKey: Void?

extension OpenBase {
    
    public func request(with targetIntent: Intent){
        if targetIntent.parent == nil {
            targetIntent.parent = self
        }
        
        if let parentVC = targetIntent.parent as? UIViewController,
           let target = targetIntent.target as? UIViewController.Type {
            var targetObj = target.init()
            targetObj.intent = targetIntent
            if targetIntent.openWay == .push {
                parentVC.navigationController?.pushViewController(targetObj, animated: targetIntent.animated ?? true)
            } else if targetIntent.openWay == .present {
                parentVC.present(targetObj, animated: targetIntent.animated ?? true, completion: nil)
            }
        } else if let target = targetIntent.target as? NSObject.Type, var targetObj = target.init() as? OpenBase {
            targetObj.intent = targetIntent
            if let method = targetIntent.method {
                let selector = NSSelectorFromString(method)
                let obj = targetObj as AnyObject
                if class_getInstanceMethod(target, selector) != nil {
                    _ = obj.perform(selector, with: nil, with: 0) as AnyObject
                } else {
                    print("\(target.self)的方法 \"\(method)\" 不存在")
                    targetIntent.responseBlock?(Response(requestCode: targetIntent.requestCode ?? 0, resultCode: ErrResultCode.methodNotFound.rawValue, resultData: nil))
                }
            } else {
                print("缺少参数")
            }
        } else {
            print("Intent的参数target不能为空")
            targetIntent.responseBlock?(Response(requestCode: targetIntent.requestCode ?? 0, resultCode: ErrResultCode.targetNotFound.rawValue, resultData: nil))
        }
    }
    
    public func request<Result: Codable>(with targetIntent: Intent, resultType: Result.Type, for responseBlock: ResponseBlock<Result>? = nil) {
        targetIntent.responseBlock = {(response)in
            var result:Result? = nil
            if let data = response.resultData {
                result = try! JSONDecoder().decode(resultType.self, from: data)
            }
            responseBlock?(Response(requestCode: response.requestCode, resultCode: response.resultCode, resultData: result))
        }
        request(with: targetIntent)
    }
    
    public var intent: Intent? {
        get {
            return objc_getAssociatedObject(self, &intentKey) as? Intent
        }
        set {
            objc_setAssociatedObject(self, &intentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func setResult<ResultData>(resultCode: Int?, resultData: ResultData?) where ResultData : Decodable, ResultData : Encodable {
        intent?.responseBlock?(Response(requestCode: intent?.requestCode ?? 0,
                                        resultCode: resultCode ?? 0,
                                        resultData: try! JSONEncoder().encode(resultData)))
    }
}
