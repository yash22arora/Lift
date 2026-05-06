// NumberInputField.swift
// Lift — Numeric input for weight and reps in the Active Workout screen

import SwiftUI

struct NumberInputField: View {
    let placeholder: String
    let unit: String?
    @Binding var value: String
    var isError: Bool = false

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(spacing: 4) {
                TextField(placeholder, text: $value)
                    .font(.liftDataMd)
                    .foregroundStyle(Color.liftText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($isFocused)
                    .frame(maxWidth: .infinity)

                if let unit {
                    Text(unit)
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                        .tracking(0.5)
                        .textCase(.uppercase)
                }
            }
            .padding(.horizontal, Spacing.sm)
            .frame(height: ComponentSize.inputHeight)
            .background(Color.liftSurface)
            .cornerRadius(Radius.sm)

            // Bottom border: neon on focus, pink on error, none otherwise
            Rectangle()
                .frame(height: BorderWidth.thick)
                .foregroundStyle(
                    isError ? Color.liftAccent :
                    isFocused ? Color.liftPrimary :
                    Color.clear
                )
                .animation(.liftFast, value: isFocused)
                .animation(.liftFast, value: isError)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        HStack {
            NumberInputField(placeholder: "100", unit: "KG", value: .constant("100"))
            NumberInputField(placeholder: "8", unit: "REPS", value: .constant(""))
        }
        HStack {
            NumberInputField(placeholder: "0", unit: "KG", value: .constant("abc"), isError: true)
        }
    }
    .padding()
    .background(Color.liftBackground)
}
