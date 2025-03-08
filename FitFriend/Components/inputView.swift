import SwiftUI

struct inputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    let isSecureField: Bool  // Make it a variable to be passed

    // Provide a default value in the initializer
    init(text: Binding<String>, title: String, placeholder: String, isSecureField: Bool = false) {
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self.isSecureField = isSecureField
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(Color(.black))
                .fontWeight(.semibold)
                .font(.footnote)

            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }

            Divider()
                .background(Color.black)
        }
    }
}

#Preview {
    inputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com", isSecureField: false)
}
