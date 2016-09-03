//
//  Models.swift
//  lingo
//
//  Created by Taehyun Park on 2/2/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthUser: Mappable {
  var id: Int!
  var grade: String!
  var role: String!
  var token: String!
  
  required init?(_ map: Map) {
    
  }
  
  init(id: Int, token: String, role: String, grade: String) {
    self.id = id
    self.token = token
    self.role = role
    self.grade = grade
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    grade <- map["grade"]
    role <- map["role"]
    token <- map["token"]
  }
}

class User : AuthUser {
  var email: String!
  var name: String!
  var studentId: String!
  var gender: String!
  var schoolId: Int!
  
  
  override func mapping(map: Map) {
    super.mapping(map)
    email <- map["email"]
    name <- map["name"]
    studentId <- map["studentId"]
    gender <- map["gender"]
    schoolId <- map["schoolId"]
  }
}

struct Device: Mappable {
  var name: String!
  var os: String!
  var sdkVersion: Int!
  var appVersion: Int!
  var token: String!
  
  init?(_ map: Map) {
    
  }
  
  // Mappable
  mutating func mapping(map: Map) {
    name <- map["name"]
    os <- map["os"]
    sdkVersion <- map["sdkVersion"]
    appVersion <- map["appVersion"]
    token <- map["token"]
  }
  
}

struct School: Mappable {
  var name: String!
  var location: String!
  var grade: String!
  
  init?(_ map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    name <- map["name"]
    location <- map["location"]
    grade <- map["grade"]
  }
  
}

class Serial: Mappable, CustomDebugStringConvertible {
  var schoolId: Int!
  var school: School!
  var serial: String!
  var securityRole: String!
  
  required init?(_ map: Map) {
    
  }
  
  func mapping(map: Map) {
    schoolId <- map["schoolId"]
    school <- map["school"]
    serial <- map["serial"]
    securityRole <- map["securityRole"]
  }
  
  var debugDescription:String {
    return Mapper().toJSONString(self, prettyPrint: true)!
  }
}

public struct Teacher: Mappable, Hashable, CustomStringConvertible {
  var id: Int!
  var name: String!
  var intro: String!
  
  public init?(_ map: Map) {
    
  }
  
  public mutating func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    intro <- map["studentId"]
  }
  
  public var hashValue: Int {
    return id
  }
  
  public var description: String{
    return "\(name) 선생님 (\(intro))"
  }
}


public func ==(lhs: Teacher, rhs: Teacher) -> Bool {
  return lhs.id == rhs.id
}


public struct Profile: Mappable {
  var id: Int!
  var email: String!
  var studentId: String!
  var school: School!
  var teachers: [Int]!
  
  public init?(_ map: Map) {
    
  }
  
  public mutating func mapping(map: Map) {
    id <- map["id"]
    email <- map["email"]
    studentId <- map["studentId"]
    school <- map["school"]
    teachers <- map["teachers"]
  }
  
}