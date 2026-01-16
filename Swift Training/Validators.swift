//
//  Validators.swift
//  Swift Training
//
//  Created by Zero Sum on 16.01.2026.
//

import Foundation

func isUserNameValid(_ userName: String) -> Bool {
    !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

func isUserAgeValid(_ userAge: Int) -> Bool {
    userAge > 0
}

func isUserAgreementAccepted(_ acceptUserAgreement: Bool) -> Bool {
    acceptUserAgreement
}
