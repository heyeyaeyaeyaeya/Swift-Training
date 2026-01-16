//
//  Registration.swift
//  Swift Training
//
//  Created by Zero Sum on 16.01.2026.
//

func setUserName(_ userName: inout String, to newValue: String) {
    userName = newValue
}

func setUserSurname(_ userSurname: inout String, to newValue: String) {
    userSurname = newValue
}

func setUserAge(_ userAge: inout Int, to newValue: Int) {
    userAge = newValue
}

func setAcceptUserAgreement(_ acceptUserAgreement: inout Bool, to newValue: Bool) {
    acceptUserAgreement = newValue
}

func registerUser(
    userName: String,
    userSurname: String,
    userAge: Int,
    acceptUserAgreement: Bool
) -> Bool {
    isUserNameValid(userName) &&
    isUserSurnameValid(userSurname) &&
    isUserAgeValid(userAge) &&
    isUserAgreementAccepted(acceptUserAgreement)
}
