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

let isRegistered = registerUser(
    userName: userName,
    userSurname: userSurname,
    userAge: userAge,
    acceptUserAgreement: acceptUserAgreement
)

if isRegistered {
    print("✅ Registration success")
} else {
    print("❌ Registration failed")

    if !isUserNameValid(userName) {
        print("- User name is invalid")
    }

    if !isUserSurnameValid(userSurname) {
        print("- User surname is invalid")
    }

    if !isUserAgeValid(userAge) {
        print("- User age is invalid")
    }

    if !isUserAgreementAccepted(acceptUserAgreement) {
        print("- User agreement is not accepted")
    }
}
