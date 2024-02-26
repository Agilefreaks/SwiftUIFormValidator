//
// Created by Shaban on 25/05/2021.
// Copyright (c) 2021 sha. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    // 4
    @ObservedObject var formInfo = FormInfo()
    @State var isSaveDisabled = true
    
    @State var isFirstNameError: Bool = false
    
    @State var isError: CurrentErrorField = CurrentErrorField(isError: false, message: "blblbblbl")

    var body: some View {
        NavigationView {
            VStack {

                Section(header: Text("Name")) {
                    TextField("First Name", text: $formInfo.firstName)
                        .border(isFirstNameError ? .red : .blue)
                        .validation(formInfo.firstNameValidation, errorView: AnyView(ErrorFieldView(errorState: $isError))) { isValid in
                                self.isFirstNameError = !isValid
                        
                        }
                           // 5

                    TextField("Middle Names", text: $formInfo.middleNames)

                    TextField("Last Name", text: $formInfo.lastNames)
//                            .validation(formInfo.lastNamesValidation)
                }

//                Section(header: Text("Password")) {
//                    TextField("Password", text: $formInfo.password)
//                            .validation(formInfo.passwordValidation)
//                    TextField("Confirm Password", text: $formInfo.confirmPassword)
//                }
//
//                Section(header: Text("Personal Information")) {
//                    DatePicker(
//                            selection: $formInfo.birthday,
//                            displayedComponents: [.date],
//                            label: { Text("Birthday") }
//                    ).validation(formInfo.birthdayValidation)
//                }
//
//                Section(header: Text("Address")) {
//                    TextField("Street Number or Name", text: $formInfo.street)
//                            .validation(formInfo.streetValidation)
//
//                    TextField("First Line", text: $formInfo.firstLine)
//                            .validation(formInfo.firstLineValidation)
//
//                    TextField("Second Line", text: $formInfo.secondLine)
//
//                    TextField("Country", text: $formInfo.country)
//                }

                Button(action: {
                   let valid = formInfo.form.triggerValidation()
                    print("Form valid: \(valid)")
                }, label: {
                    HStack {
                        Text("Submit")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                    }
                })
//                You can disable the button, and only enable it when the form is valid
//                        .disabled(isSaveDisabled)
            }.padding()
                    .navigationBarTitle("Form")
//                   observe the form validation and enable submit button only if it's valid
                    .onReceive(formInfo.form.$allValid) { isValid in
                        self.isSaveDisabled = !isValid
                    }
                    // React to validation messages changes
                    .onReceive(formInfo.form.$validationMessages) { messages in
                        print(messages)
                    }

        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




import SwiftUI
struct ErrorFieldView: View {
    @Binding var errorState: CurrentErrorField

    var onTapErrorField = {}

    func attributedString(message: String) -> AttributedString {
        var result = AttributedString(message)
        if errorState.type == .warning {
            result.underlineStyle = Text.LineStyle(
                pattern: .solid, color: .green
            )
        }
        return result
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(self.errorState.type == .warning ? .yellow : .orange)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(self.errorState.type == .warning ? .green : .red)

                Text(attributedString(message: self.errorState.message))
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(self.errorState.type == .warning ? .green : .red)
                    .font(.title)

                Spacer()
            }.padding(.horizontal, 16)
                .padding(.vertical, 14)
        }.padding(.top, 4)
            .onTapGesture {
                if errorState.type == .warning {
                    self.onTapErrorField()
                }
            }
            .frame(height: 48)
    }
}

struct CurrentErrorField {
    var isError: Bool
    var message: String
    var description: String?
    var type: FieldErrorType = .error
}

enum FieldErrorType {
    case error
    case warning
}
