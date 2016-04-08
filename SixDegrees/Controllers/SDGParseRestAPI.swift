//
//  SDGParseRestAPI.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 07/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import SwiftyJSON
import Alamofire
import FBSDKLoginKit

public class SDGParseRestAPI {

    private static let baseURL: NSURL = NSURL(string: "https://api.parse.com/1/")!

    enum ContentType: String {
        case JSON = "application/json"
    }

    static let sharedClient: SDGParseRestAPI = SDGParseRestAPI()

    class func request(
        method method: Alamofire.Method = .GET,
               path: String,
               parameters: [String: AnyObject]? = nil,
               contentType: ContentType = .JSON,
               encoding: ParameterEncoding = .URL,
               additionalHeaders: [String: String] = [:]
        ) -> Request {

        let URLString = SDGParseRestAPI.baseURL.URLByAppendingPathComponent(path)

        // Configure headers
        var headers: [String: String] = [:]
        headers["Content-Type"] = contentType.rawValue
        headers["X-Parse-Application-Id"] = "UlkLiA4PGLhRUHelE6l9sUGSGl9VQUGUrai2Cnyj"
        headers["X-Parse-REST-API-Key"] = "Gu8ZULBlIahbs4MjFQtm68h2ntN5WoFxAyLASENO"

        for (key, value) in additionalHeaders {
            headers[key] = value
        }
        return Alamofire.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
    }

    private func simpleRequest(method method: Alamofire.Method = .GET, path: String, parameters: [String: AnyObject]? = nil, completionBlock: ((result: JSON?, error: NSError?) -> Void)?) {

        SDGParseRestAPI.request(method: method, path: path, parameters: parameters, contentType: .JSON, encoding: .URL, additionalHeaders: [:]).responseJSON { (response: Response<AnyObject, NSError>) in
            if response.response?.statusCode == 404 {
                completionBlock?(result: JSON([:]), error: nil)
                return
            }
            if let error: NSError = response.result.error {
                completionBlock?(result: nil, error: error)
                return
            }
            // No error, check for result
            if let value = response.result.value {
                let json: JSON = JSON(value)
                completionBlock?(result: json, error: nil)
                return
            }

            // Unable to get JSON
            let error: NSError = NSError(domain: "Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("No JSON response found.", comment: "No JSON response found.")])
            completionBlock?(result: nil, error: error)
            return
        }
    }

    func getUsers() {
        let path = "users"

        SDGParseRestAPI.request(method: .GET, path: path, parameters: nil, contentType: .JSON, encoding: .URL, additionalHeaders: [:]).responseJSON { (response: Response<AnyObject, NSError>) in

        }
    }

    // "Sign Up" device with the device's uuid to parse, to be able to get access to the user data.
    func signUp() {
        let path = "users"
        let username: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
        let password: String = UIDevice.currentDevice().identifierForVendor!.UUIDString

        var params: [String : AnyObject] = [:]
        params["username"] = username
        params["password"] = password

        SDGParseRestAPI.request(method: .POST, path: path, parameters: params, contentType: .JSON, encoding: .JSON, additionalHeaders: [:]).responseJSON { (response: Response<AnyObject, NSError>) in
            print(response.result.value)
        }
    }

    func login() {
        let path = "login"
        let username: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
        let password: String = UIDevice.currentDevice().identifierForVendor!.UUIDString

        var params: [String : AnyObject] = [:]
        params["username"] = username
        params["password"] = password

        SDGParseRestAPI.request(method: .GET, path: path, parameters: params, contentType: .JSON, encoding: .URL, additionalHeaders: [:]).responseJSON { (response: Response<AnyObject, NSError>) in
            print(response.result.value)
        }
    }
}





