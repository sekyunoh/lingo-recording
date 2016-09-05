//
//  API.swift
//  lingo
//
//  Created by Taehyun Park on 1/4/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import XCGLogger
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif

/**
 RxCocoa URL errors.
 */
public enum APIError
: ErrorType {
  /**
   Unknown error occurred.
   */
  case Unknown
  case BadRequest(message: String?)
  /**
   Response is not NSHTTPURLResponse
   */
  case NonHTTPResponse(response: NSURLResponse)
  /**
   Response is not successful. (not in `200 ..< 300` range)
   */
  case HTTPRequestFailed(response: NSHTTPURLResponse, data: NSData?)
  /**
   Deserialization error.
   */
  case DeserializationError(error: ErrorType)
  
  case Unauthorized
}


class API {
  static let instance = API()
  static let URL = NSURL(string: App.endPoint)!
  static let baseURL = NSURLRequest(URL: NSURL(string: App.endPoint)!)
  
  let $: Dependencies = Dependencies.instance
  
  var token: String? {
    return SessionManager.instance.token
  }
  
  var userId: Int? {
    return SessionManager.instance.userId
  }
  
  var appDelegate: AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
  }
  
  var editionId: Int? {
    return SessionManager.instance.editionManager?.editionId
  }
  
  var log: XCGLogger {
    return appDelegate.log
  }
  
  let loading = ActivityIndicator()
  
  private init() {
    
  }
  
  //MARK: SignIn
  func login(params: [String: AnyObject]) -> Observable<ObjectResponse<User>> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/login"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    return responseObject(Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0)
  }
  
  //MARK: Signup
  
  func validateSerial(serial: String) -> Observable<Serial?> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/validate"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    return responseObject(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["serial":serial]).0).map { $0.data }
  }
  
  func teachersBySchoolId(schoolId: Int) -> Observable<[Teacher]?> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/school/\(schoolId)/teachers"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
    return responseArray(mutableURLRequest).map { $0.data }
  }
  
  func signup(params: [String: AnyObject]) -> Observable<ObjectResponse<AuthUser>> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/register"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    return responseObject(Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0)
  }
  
  //MARK: Profile
  
  func profile() -> Observable<ObjectResponse<Profile>> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/profile"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
    return responseObject(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!]).0)
  }
  
  
  func teachersByUserId() -> Observable<[Teacher]?> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/teachers/all"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
    return responseArray(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!]).0).map { $0.data }
  }
  
  func changePassword(form: NSData) -> Observable<Response> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/profile/password"))
    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    mutableURLRequest.HTTPBody = form
    return request(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!]).0)
  }
  
  //MARK: Launcher
  func getSeries() -> Observable<ArrayResponse<Series>> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/series"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
    return responseArray(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!]).0)
  }
  
  //MARK: Published
  func downloadWordResource(publishedId: Int, resourceName: String, progress: ((Int64, Int64, Int64) -> Void)?, completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Void) {
    let downloadURL = "\(App.resource)/v1.0/user/\(userId!)/published/\(publishedId)/resource?token=\(token!)"
    self.log.debug("downloadURL=\(downloadURL)")
    Alamofire.download(Alamofire.Method.GET, downloadURL) {  temporaryURL, response in
      let fileURL = Resources.url(resourceName)
      Resources.remove(resourceName)
      self.log.debug("fileURL=\(fileURL)")
      return fileURL
      }
      .progress(progress)
      .response(completionHandler: completionHandler)
  }
  
  func getWords(publishedId: Int) -> Observable<ArrayResponse<PublishedGroup>> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/published/\(publishedId)/groups/words"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
    return responseArray(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!]).0)
  }
  
  //MARK: Edition
  func getEdition(publishedId: Int) -> Observable<ObjectResponse<Edition>> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/edition"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    return responseObject(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!, "publishedId": publishedId]).0)
  }
  
  func learnGroup(groupId: Int, timestamp: Int = Int(NSDate().timeIntervalSince1970 * 1000)) -> Observable<Response> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/edition/\(editionId!)/learnedgroup"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    return request(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!, "groupId": groupId,
      "timestamp" : timestamp]).0)
  }
  
  func learnWord(groupWordId: Int, timestamp: Int = Int(NSDate().timeIntervalSince1970 * 1000)) -> Observable<Response> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/edition/\(editionId!)/learned"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    return request(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!, "groupWordId": groupWordId,
      "timestamp" : timestamp]).0)
  }
  
  func wrongLearningWord(wordId: Int, timestamp: Int = Int(NSDate().timeIntervalSince1970 * 1000)) -> Observable<Response> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/edition/\(editionId!)/wrong"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    return request(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest,
      parameters: [
        "token":token!,
        "wordId": wordId,
        "timestamp" : timestamp]).0)
  }
  
  
  func starWord(wordId: Int, timestamp: Int = Int(NSDate().timeIntervalSince1970 * 1000)) -> Observable<Response> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/edition/\(editionId!)/starred"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    return request(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest,
      parameters: [
        "token":token!,
        "wordId": wordId,
        "timestamp" : timestamp]).0)
  }

  func unstarWord(wordId: Int, timestamp: Int = Int(NSDate().timeIntervalSince1970 * 1000)) -> Observable<Response> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/edition/\(editionId!)/starred"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.DELETE.rawValue
    return request(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest,
      parameters: [
        "token":token!,
        "wordId": wordId,
        "timestamp" : timestamp]).0)
  }
  
  // MARK: Quiz
  func getAvailableQuizzes() -> Observable<ArrayResponse<Quiz>> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/edition/\(editionId!)/quizzes/available"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
    return responseArray(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!]).0)
  }
  
  func getQuiz(id: Int) -> Observable<ObjectResponse<Quiz>> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/quiz/\(id)"))
    mutableURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
    return responseObject(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!]).0)
  }
  
  func submitQuiz(id: Int, form: NSData) -> Observable<Response> {
    let mutableURLRequest = NSMutableURLRequest(URL: API.URL.URLByAppendingPathComponent("/v1.0/user/\(userId!)/userquiz/\(id)"))

    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    mutableURLRequest.HTTPBody = form
    return request(Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: ["token":token!]).0)
  }

  
  // MARK: Common
  
  private func responseObject<T: Mappable>(urlRequest: URLRequestConvertible) -> Observable<ObjectResponse<T>> {
    return request(urlRequest)
  }
  
  private func responseArray<T: Mappable>(urlRequest: URLRequestConvertible) -> Observable<ArrayResponse<T>> {
    return request(urlRequest)
  }
  
  private func request<T: Response>(urlRequest: URLRequestConvertible) -> Observable<T> {
    return Observable.create { observer in
      let request = Alamofire.request(urlRequest).responseObject(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), completionHandler:  {(response: Alamofire.Response<T, NSError>) in
        if let error = response.result.error {
          observer.on(.Error(error))
          return
        }
        
        guard let result = response.result.value else {
          observer.on(.Error(APIError.Unknown))
          return
        }
        
        switch result.status {
        case 200:
          self.log.debug("onNext=\(result)")
          observer.on(.Next(result))
          observer.on(.Completed)
        case 401:
          observer.on(.Error(APIError.Unauthorized))
        default:
          observer.on(.Error(APIError.BadRequest(message: result.message)))
        }
      })
      return AnonymousDisposable {      request.cancel()      }
      }
      .trackActivity(loading)
      .subscribeOn($.backgroundWorkScheduler)
  }
}