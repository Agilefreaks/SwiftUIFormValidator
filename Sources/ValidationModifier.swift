//
//  ValidationModifier.swift
//  SwiftUI-Validation
//
// Created by Shaban on 24/05/2021.
//  Copyright © 2020 Sha. All rights reserved.
//

import Foundation
import SwiftUI

public struct ValidationContainer {
    public let publisher: ValidationPublisher
    public let subject: ValidationSubject
}

public extension View {

    ///A modifier used for validating a root publisher.
    /// Whenever the publisher changes, the value will be validated
    /// and propagated to this view.
    /// In case it's invalid, an error message will be displayed under the view
    ///
    /// - Parameter container:
    /// - Returns:
    func validation(_ container: ValidationContainer, callback: @escaping (Bool)->()) -> some View {
        self.modifier(ValidationModifier(isFieldValid: callback, container: container))
    }

}

/// A modifier for applying the validation to a view.
public struct ValidationModifier: ViewModifier {
    @State var latestValidation: Validation = .success
    
    public var isFieldValid:(Bool)->()

    public let container: ValidationContainer

    public init(isFieldValid: @escaping (Bool)->(), container: ValidationContainer) {
        self.isFieldValid = isFieldValid
        self.container = container
    }

    public func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
            validationMessage
        }.onReceive(container.publisher) { validation in
            self.latestValidation = validation
            
            switch validation {
                case .failure(_):self.isFieldValid(false)
                case .success: self.isFieldValid(true)
            }
        }.onReceive(container.subject) { validation in
            self.latestValidation = validation
            
            switch validation {
                case .failure(_):self.isFieldValid(false)
                case .success: self.isFieldValid(true)
            }
        }
    }

    public var validationMessage: some View {
        switch latestValidation {
        case .success:
            return AnyView(EmptyView())
        case .failure(let message):
            let text = Text(message)
                    .foregroundColor(Color.red)
                    .font(.caption)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
            return AnyView(text)
        }
    }
}
