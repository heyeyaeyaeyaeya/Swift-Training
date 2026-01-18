//
//  main.swift
//  Swift Training
//
//  Created by Zero Sum on 16.01.2026.
//

import Foundation

var userName: String = ""
var userSurname: String = ""
var userAge: Int = 0
var acceptUserAgreement: Bool = false

setUserName(&userName, to: "John")
setUserSurname(&userSurname, to: "Snow")
setUserAge(&userAge, to: 18)
setAcceptUserAgreement(&acceptUserAgreement, to: true)

print(
    registerUser(
        userName: userName,
        userSurname: userSurname,
        userAge: userAge,
        acceptUserAgreement: acceptUserAgreement
    )
)

let isUserNameValidResult = isUserNameValid(userName)
if !isUserNameValidResult {
    print("User name is invalid")
}

let isUserAgeValidResult = isUserAgeValid(userAge)
if !isUserAgeValidResult {
    print("User age is invalid")
}

let isUserAgreementAcceptedResult = isUserAgreementAccepted(acceptUserAgreement)
if !isUserAgreementAcceptedResult {
    print("User agreement is not accepted")
}
