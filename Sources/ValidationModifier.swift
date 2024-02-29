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
    func validation(_ container: ValidationContainer,
                    errorView: AnyView? = nil,
                    fontSize: CGFloat = 10,
                    horizontalPadding: CGFloat = 20,
                    callback: ((Bool)->())? = nil) -> some View {
        self.modifier(ValidationModifier(isFieldValid: callback,
                                         container: container,
                                        fontSize: fontSize,
                                        horizontalPadding: horizontalPadding,
                                        errorView: errorView))
    }
}

/// A modifier for applying the validation to a view.
public struct ValidationModifier: ViewModifier {
    @State var latestValidation: Validation = .success
    
    public var isFieldValid:((Bool)->())?

    public let container: ValidationContainer
    
    public let fontSize: CGFloat
    public let horizontalPadding: CGFloat
    public let errorView: AnyView?

    public init(isFieldValid: ((Bool)->())? = nil,
                container: ValidationContainer,
                fontSize: CGFloat = 10,
                horizontalPadding: CGFloat = 20,
                errorView: AnyView? = nil) {
        self.isFieldValid = isFieldValid
        self.container = container
        self.fontSize = fontSize
        self.horizontalPadding = horizontalPadding
        self.errorView = errorView
    }

    public func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content
            validationMessage
        }.onReceive(container.publisher) { validation in
            self.latestValidation = validation
            
            if let isValid = isFieldValid {
                switch validation {
                    case .failure(_): isValid(false)
                    case .success: isValid(true)
                }
            }
        }.onReceive(container.subject) { validation in
            self.latestValidation = validation
            
            if let isValid = isFieldValid {
                switch validation {
                    case .failure(_): isValid(false)
                    case .success: isValid(true)
                }
            }
        }
    }

    public var validationMessage: some View {
        switch latestValidation {
        case .success:
            return AnyView(EmptyView())
        case .failure(let message):
            if let errorView = errorView {
                return errorView
            }
            let textView = Text(message)
                .foregroundColor(Color.red)
                .font(Font.custom(CustomFont.MontserratRegular.rawValue, size: self.fontSize))
                .padding(.horizontal, self.horizontalPadding)
                .fixedSize(horizontal: false, vertical: true)
            return AnyView(textView)
        }
    }
}


public enum CustomFont: String {
    case MontserratSemiBold = "Montserrat-SemiBold"
    case MontserratRegular = "Montserrat-Regular"
    case MontserratMedium = "Montserrat-Medium"
}
