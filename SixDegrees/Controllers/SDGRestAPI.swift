//
//  SDGRestAPI.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 02/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import SwiftyJSON
import Alamofire
import FBSDKLoginKit

public class SDGRestAPI {

    private static let baseURL: NSURL = NSURL(string: "https://graph.facebook.com/v2.5/")!

    enum ContentType: String {
        case JSON = "application/json"
        case JPEG = "image/jpeg"
    }

    static let sharedClient: SDGRestAPI = SDGRestAPI()

    class func request(
        method method: Alamofire.Method = .GET,
               path: String,
               parameters: [String: AnyObject]? = nil,
               contentType: ContentType = .JSON,
               encoding: ParameterEncoding = .URL,
               additionalHeaders: [String: String] = [:]
        ) -> Request {

        let URLString = SDGRestAPI.baseURL.URLByAppendingPathComponent(path)

        // Configure headers
        var headers: [String: String] = [:]
        headers["Content-Type"] = contentType.rawValue
        for (key, value) in additionalHeaders {
            headers[key] = value
        }
        return Alamofire.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
    }

    private func simpleRequest(method method: Alamofire.Method = .GET, path: String, parameters: [String: AnyObject]? = nil, completionBlock: ((result: JSON?, error: NSError?) -> Void)?) {

        SDGRestAPI.request(method: method, path: path, parameters: parameters, contentType: .JSON, encoding: .URL, additionalHeaders: [:]).responseJSON { (response: Response<AnyObject, NSError>) in
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

    func getUser(withUserID userID: String, completionBlock: ((user: SDGUser?, error: NSError?) -> Void)?) {
        let path: String = "\(userID)/"

        var params: [String : AnyObject] = [:]
        params["fields"] = "id,name,gender,picture"

        if let tokenString = FBSDKAccessToken.currentAccessToken().tokenString {
            params["access_token"] = tokenString
        }

        // Used for testing
//        params["access_token"] = "CAACEdEose0cBAGFCfPNUDJg74X6Gv6IPfmhNlNX0LGmoHJX3l1PyJYfeuMZBZB1uYrGZAg9oSpXX34AGbiZATaMjTPp5cVElsMXhkCoqZC1MBXSKaAuWyDDSf2pwKH5jDfQO1kluS2RdPNebLDhf11jASeyXXTTPzaVAaVktqWGAZBFFK45qAuxqem0MZCTFn6kVZBl3pYTXHvicny9CmhphZAsSS7GAQS0YZD"

//        SDGRestAPI.request(method: .GET, path: path, parameters: params, contentType: .JSON, encoding: .URL, additionalHeaders: [:]).responseJSON { (response: Response<AnyObject, NSError>) in
//
//            if let error: NSError = response.result.error {
//                completionBlock?(user: nil, error: error)
//                return
//            }
//
//            if let value = response.result.value {
//                let json: JSON = JSON(value)
//
//                // Returns error if key expired etc.
//                if json["error"].dictionary != nil {
//                    completionBlock?(user: nil, error: nil)
//                    return
//                }
//
//                if let user: SDGUser = SDGUser(json: json) {
//                    completionBlock?(user: user, error: nil)
//                    return
//                }
//            }
//            completionBlock?(user: nil, error: nil)
//        }
    }

    // Get list of mutual friends with user id
    func getMutualFriends(forUserId userId: String, completionBlock:((friends: [SDGUser]?, error: NSError?) -> Void) ) {
        let path: String = "\(userId)/"

        var params: [String : AnyObject] = [:]
        params["fields"] = "context.fields(mutual_friends)" //"id,name,gender,picture"

        // Used for testing
//        params["access_token"] = "CAACEdEose0cBAGFCfPNUDJg74X6Gv6IPfmhNlNX0LGmoHJX3l1PyJYfeuMZBZB1uYrGZAg9oSpXX34AGbiZATaMjTPp5cVElsMXhkCoqZC1MBXSKaAuWyDDSf2pwKH5jDfQO1kluS2RdPNebLDhf11jASeyXXTTPzaVAaVktqWGAZBFFK45qAuxqem0MZCTFn6kVZBl3pYTXHvicny9CmhphZAsSS7GAQS0YZD"
        if let tokenString = FBSDKAccessToken.currentAccessToken().tokenString {
            params["access_token"] = tokenString
        }

        SDGRestAPI.request(method: .GET, path: path, parameters: params, contentType: .JSON, encoding: .URL, additionalHeaders: [:]).responseJSON { (response: Response<AnyObject, NSError>) in

            if let error: NSError = response.result.error {
                completionBlock(friends: nil, error: error)
                return
            }

            var friends: [SDGUser] = []

            if let value = response.result.value {
                let json: JSON = JSON(value)

                // Returns error if key expired etc.
                if json["error"].dictionary != nil {
                    completionBlock(friends: nil, error: nil)
                    return
                }

                if let mutualFriendsData: [JSON] = json["context"]["mutal_friends"]["data"].array {

                    var totalCount: Int = mutualFriendsData.count
                    var count: Int = 0

                    for mutualFriend: JSON in mutualFriendsData {
                        let userId: String = mutualFriend["id"].string!

                        self.getUser(withUserID: userId, completionBlock: { (user, error) in
                            if let user = user {
                                count += 1
                                friends.append(user)
                            } else {
                                totalCount -= 1
                            }
                        })
                    }
                    if count == totalCount {
                        completionBlock(friends: friends, error: nil)
                    } else {
                        completionBlock(friends: nil, error: nil)
                    }
                } else {
                    completionBlock(friends: nil, error: nil)
                }
            } else {
                completionBlock(friends: nil, error: nil)
            }
        }
    }

}