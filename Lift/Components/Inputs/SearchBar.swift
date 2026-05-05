// SearchBar.swift
// Lift — Exercise search field with clear button

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isFocused ? Color.liftPrimary : Color.liftMuted)
                .animation(.liftFast, value: isFocused)

            TextField("", text: $text, prompt: Text(placeholder)
                .font(.liftBodyMd)
                .foregroundColor(.liftMuted)
            )
            .font(.liftBodyMd)
            .foregroundStyle(Color.liftText)
            .focused($isFocused)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                    HapticService.lightImpact()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.liftMuted)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: ComponentSize.searchBarHeight)
        .background(Color.liftSurface)
        .cornerRadius(Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(
                    isFocused ? Color.liftPrimary.opacity(0.5) : Color.liftBorder,
                    lineWidth: BorderWidth.thin
                )
                .animation(.liftFast, value: isFocused)
        )
        .animation(.liftFast, value: text.isEmpty)
    }
}

#Preview {
    SearchBar(text: .constant(""), placeholder: "SEARCH MOVEMENTS")
        .padding()
        .background(Color.liftBackground)
}
